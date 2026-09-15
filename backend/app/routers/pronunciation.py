import asyncio
import difflib
import hashlib
import json
import logging
import re
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, BackgroundTasks
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from sqlalchemy import select, desc, func
from app.models import PronunciationAttempt, PronunciationTermStats
from app.services.stt import stt_service
from app.providers.ollama_provider import get_ollama_client
from app.services import phoneme_scorer
from app.services import pron_eval
from app.services.memory_service import memory_service

logger = logging.getLogger("english_brain.pronunciation")
router = APIRouter(prefix="/pronunciation", tags=["pronunciation"])

# Frase mock que devuelve el STT cuando Speaches no está disponible.
_MOCK_STT_PREFIX = "I have worked with Python"


class PronunciationCheckOut(BaseModel):
    expected_term: str
    recognized_text: str
    score: int
    text_score: int
    phonetic_score: int
    is_match: bool
    stt_ok: bool
    engine_used: str
    exercise_type: str = "single_word"
    confidence: float = 0.0
    processing_stage_failed: Optional[str] = None
    feedback: str
    tip: Optional[str] = None
    wrong_phonemes: list[str] = []
    target_ipa: Optional[str] = None
    audio_url: Optional[str] = None


_NUM_WORDS = {
    "0": "zero", "1": "one", "2": "two", "3": "three", "4": "four",
    "5": "five", "6": "six", "7": "seven", "8": "eight", "9": "nine",
    "10": "ten", "11": "eleven", "12": "twelve", "13": "thirteen",
    "14": "fourteen", "15": "fifteen", "16": "sixteen", "17": "seventeen",
    "18": "eighteen", "19": "nineteen", "20": "twenty", "30": "thirty",
    "40": "forty", "50": "fifty", "60": "sixty", "70": "seventy",
    "80": "eighty", "90": "ninety", "100": "hundred", "1000": "thousand",
    "1000000": "million", "1st": "first", "2nd": "second", "3rd": "third",
    "4th": "fourth", "5th": "fifth", "6th": "sixth", "7th": "seventh",
    "8th": "eighth", "9th": "ninth", "10th": "tenth",
}


def _expand_numbers(text: str) -> str:
    """Convierte números arábigos ('100', '1, 2, 3', '1st') a palabras en inglés
    para que la evaluación fonética y de texto sea precisa cuando Whisper transcribe dígitos."""
    t = text.lower()
    for num, word in sorted(_NUM_WORDS.items(), key=lambda x: -len(x[0])):
        t = re.sub(rf"\b{re.escape(num)}\b", word, t)
    return t


def _clean_text(s: str) -> str:
    expanded = _expand_numbers(s.lower())
    return re.sub(r"[^\w\s]", " ", expanded).strip()


def _phonetic(s: str) -> str:
    """Reduce una palabra inglesa a un 'esqueleto de sonido' aproximado para
    comparar por cómo suena y no por cómo se escribe (el STT puede transcribir
    una palabra bien pronunciada con otra grafía)."""
    expanded = _expand_numbers(s.lower())
    s = re.sub(r"[^a-z]", "", expanded)
    if not s:
        return ""
    for a, b in [
        ("ph", "f"), ("gh", ""), ("ck", "k"), ("qu", "kw"), ("wr", "r"),
        ("kn", "n"), ("wh", "w"), ("tion", "shn"), ("sion", "shn"),
        ("ough", "o"), ("augh", "a"), ("ch", "tsh"), ("ng", "n"),
    ]:
        s = s.replace(a, b)
    s = re.sub(r"c(?=[eiy])", "s", s)  # c suave
    s = s.replace("c", "k").replace("x", "ks").replace("z", "s").replace("q", "k")
    if len(s) > 2 and s.endswith("e"):
        s = s[:-1]
    s = re.sub(r"(.)\1+", r"\1", s)       # colapsar dobles
    s = re.sub(r"[aeiou]+", "a", s)       # vocales -> marcador único
    return s


def _score(expected: str, recognized: str) -> tuple[int, int, int]:
    # Manejar opciones con barra ("first / second", "hundred / one hundred")
    exp_variants = [v.strip() for v in expected.split("/") if v.strip()]
    if not exp_variants:
        exp_variants = [expected]

    best_score, best_text, best_phon = 0, 0, 0
    rec_c = _clean_text(recognized)
    rec_phon = _phonetic(recognized)

    for variant in exp_variants:
        exp_c = _clean_text(variant)
        exp_phon = _phonetic(variant)
        if not exp_c:
            continue

        text_ratio = difflib.SequenceMatcher(None, exp_c, rec_c).ratio()
        phon_ratio = difflib.SequenceMatcher(None, exp_phon, rec_phon).ratio() if exp_phon and rec_phon else 0.0

        # Contención a nivel de palabra: si el reconocedor "oyó" la palabra esperada
        rec_words = rec_c.split()
        exp_words = exp_c.split()
        contained = (
            exp_c == rec_c
            or exp_c in rec_words
            or (all(w in rec_words for w in exp_words) if exp_words else False)
            or (len(exp_c) > 3 and exp_c in rec_c)
        )

        if exp_c == rec_c or (contained and len(exp_words) == len(rec_words)):
            score = 100
            text_ratio = 1.0
            phon_ratio = 1.0
        elif contained:
            score = max(95, int(round((0.35 * text_ratio + 0.65 * max(phon_ratio, 0.90)) * 100)))
        else:
            blended = 0.35 * text_ratio + 0.65 * phon_ratio
            score = int(round(blended * 100))

        if score > best_score:
            best_score = score
            best_text = int(round(text_ratio * 100))
            best_phon = int(round(phon_ratio * 100))

    return best_score, best_text, best_phon


_TIP_CACHE: dict[str, str] = {}


async def _ai_tip(term, ipa, recognized, score, wrong=None):
    """Consejo de pronunciación C1 Profesional (GPU). Cacheado en memoria para respuesta de 1.5ms."""
    wrong_key = "_".join(sorted(wrong or []))
    cache_key = f"{str(term).strip().lower()}__wp:{wrong_key}__sc:{score // 10}"
    if cache_key in _TIP_CACHE:
        return _TIP_CACHE[cache_key], "fast"

    ollama = get_ollama_client()
    try:
        if not await ollama.is_available():
            return None, "standard"
        system = (
            "Eres un coach de pronunciación en inglés C1 para profesionales hispanohablantes. "
            "Responde SOLO JSON válido: {\"tip\": \"...\"} con máximo 2 frases breves en español técnico "
            "(ajuste muscular de articulación: cresta alveolar, flap [ɾ], aspiración, reducción schwa /ə/). "
            "Sin rodeos ni saludos."
        )
        wrong_txt = f" Sonidos que fallaron (IPA): {', '.join(wrong[:4])}." if wrong else ""
        prompt = (
            f'Palabra/frase: "{term}" (IPA: {ipa or "n/d"}). '
            f'Reconocido: "{recognized or "(nada)"}". Puntuación: {score}/100.{wrong_txt} '
            f'Indica el ajuste muscular de articulación exacto para sonar nativo.'
        )
        res = await ollama.generate_feedback(
            prompt=prompt,
            system_prompt=system,
            temperature=0.2,
            fmt="json",
            num_ctx=1024,
            num_predict=120,
        )
        if not res:
            return None, "standard"
        raw = (res.get("response") or "").strip()
        tip_text = None
        m = re.search(r"\{.*\}", raw, re.DOTALL)
        if m:
            try:
                t = json.loads(m.group(0)).get("tip")
                if t:
                    tip_text = str(t).strip()
            except Exception:
                pass
        if not tip_text and raw:
            tip_text = raw.split("\n")[0][:240]

        if tip_text:
            if len(_TIP_CACHE) > 1000:
                _TIP_CACHE.clear()
            _TIP_CACHE[cache_key] = tip_text
            return tip_text, "fast"

        return None, "standard"
    except Exception as e:
        logger.warning(f"AI tip pronunciación no disponible: {e}")
        return None, "standard"


@router.post("/check", response_model=PronunciationCheckOut)
async def check_pronunciation(
    file: UploadFile = File(...),
    expected_term: str = Form(...),
    expected_ipa: Optional[str] = Form(None),
    user_id: Optional[str] = Form(None),
    category: Optional[str] = Form(None),
    exercise_type: str = Form("single_word"),
    with_tip: bool = Form(True),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    db: AsyncSession = Depends(get_db),
):
    audio_bytes = await file.read()
    if not audio_bytes:
        raise HTTPException(status_code=400, detail="Empty audio file provided")
    if len(audio_bytes) < 1200:
        # Audio demasiado corto (toque accidental / silencio): no evaluamos para no
        # puntuar ruido. Respuesta honesta sin persistir un intento espurio.
        return PronunciationCheckOut(
            expected_term=expected_term, recognized_text="", score=0, text_score=0,
            phonetic_score=0, is_match=False, stt_ok=False, engine_used="unavailable",
            exercise_type=exercise_type, confidence=0.0, processing_stage_failed="too_short",
            feedback="Grabación demasiado corta. Mantén pulsado y di la palabra completa.",
            tip="Habla al menos 1 segundo, vocalizando claro.",
            wrong_phonemes=[], target_ipa=None,
        )
    fname = file.filename or "pronunciation.m4a"
    audio_hash = hashlib.sha256(audio_bytes).hexdigest()
    saved_audio_url: Optional[str] = None
    if user_id:
        try:
            import os as _os
            from app.config import settings as _settings
            _ext = _os.path.splitext(fname)[1].lower()
            if _ext not in (".m4a", ".mp4", ".aac", ".wav", ".webm", ".opus", ".ogg"):
                _ext = ".m4a"
            _abs_dir = _os.path.join(_settings.AUDIO_CACHE_DIR, "baselines", user_id)
            _os.makedirs(_abs_dir, exist_ok=True)
            _fn = f"{audio_hash[:24]}{_ext}"
            with open(_os.path.join(_abs_dir, _fn), "wb") as _f:
                _f.write(audio_bytes)
            saved_audio_url = f"/audio/baselines/{user_id}/{_fn}"
        except Exception as _e:
            logger.warning(f"No se pudo guardar audio baseline: {_e}")

    # ── Fan-Out PARALELO a los 3 workers GPU (Whisper :8001, wav2vec2 :8100, MFA :8200) ──
    _use_mfa = exercise_type in ("short_phrase", "guided_sentence")
    stt_task = stt_service.transcribe_audio(audio_bytes, filename=fname)
    ph_task = pron_eval.evaluate(audio_bytes, expected_term, filename=fname, use_mfa=_use_mfa)

    stt_result, ph_result = await asyncio.gather(stt_task, ph_task, return_exceptions=True)

    # 1) Procesar resultado STT
    stt_ok = True
    if isinstance(stt_result, Exception):
        logger.error(f"STT error: {stt_result}")
        recognized_raw, stt_ok = "", False
    else:
        recognized_raw = stt_result or ""
        if not recognized_raw or recognized_raw.startswith(_MOCK_STT_PREFIX):
            stt_ok = False
            recognized_raw = ""

    # 2) Procesar resultado Scoring FONÉTICO
    wrong_phonemes: list[str] = []
    target_ipa: Optional[str] = None
    heard_ipa: Optional[str] = None
    ph = None
    if isinstance(ph_result, Exception):
        logger.warning(f"Phoneme scorer error: {ph_result}")
    else:
        ph = ph_result

    stage_failed: Optional[str] = None
    if ph is not None:
        score = ph["score"]
        text_score, phon_score = 0, ph["score"]
        engine = ph["engine"]
        confidence = float(ph.get("confidence", 0.7))
        wrong_phonemes = ph.get("wrong", [])
        target_ipa = ph.get("target_ipa")
        heard_ipa = ph.get("heard_ipa")
        if not recognized_raw and heard_ipa:
            recognized_raw = f"/{heard_ipa}/"
    elif stt_ok:
        score, text_score, phon_score = _score(expected_term, recognized_raw)
        engine = "standard"
        confidence = 0.5
        stage_failed = "phoneme"   # no hubo alineación fonética; medición degradada
    else:
        # HONESTO: ni fonemas ni STT -> no inventamos nota
        attempt = PronunciationAttempt(
            user_id=user_id or "default_user", term=expected_term, ipa=expected_ipa,
            category=category, exercise_type=exercise_type, recognized="",
            score=0, text_score=0, phonetic_score=0, is_match=False, confidence=0.0,
            engine_used="unavailable", processing_stage_failed="all", audio_hash=audio_hash,
        )
        if user_id:
            try:
                db.add(attempt); await db.commit()
            except Exception:
                await db.rollback()
        return PronunciationCheckOut(
            expected_term=expected_term, recognized_text="", score=0, text_score=0,
            phonetic_score=0, is_match=False, stt_ok=False, engine_used="unavailable",
            exercise_type=exercise_type, confidence=0.0, processing_stage_failed="all",
            feedback="No se pudo evaluar: ni el reconocedor de fonemas ni Whisper respondieron. "
                     "Enciende el worker de fonemas del portátil o Speaches y reintenta.",
            tip=None, wrong_phonemes=[], target_ipa=None,
        )

    is_match = score >= 70 and confidence >= 0.5
    ipa_disp = f" ({expected_ipa})" if expected_ipa else ""
    _wrong_for_llm = wrong_phonemes if confidence >= 0.5 else None
    if with_tip:
        tip, _llm = await _ai_tip(expected_term, expected_ipa, recognized_raw, score, _wrong_for_llm)
    else:
        tip = None  # el front lo pedirá a /tip (no bloquea la nota)

    low_conf = confidence < 0.5
    if low_conf:
        feedback = (f"No es concluyente (señal poco fiable). Sonó cerca de '{expected_term}'{ipa_disp}. "
                    f"Repite en un sitio silencioso y vocaliza claro.")
    elif score >= 88:
        feedback = f"¡Excelente! Pronunciaste '{expected_term}'{ipa_disp} con claridad."
    elif score >= 70:
        feedback = f"Bien ({score}%). Buen intento con '{expected_term}'{ipa_disp}."
    else:
        wp = f" Revisa los sonidos: {', '.join(wrong_phonemes[:4])}." if wrong_phonemes else ""
        feedback = f"Puntuación {score}%.{wp} Escucha la versión lenta (0.8x) y marca {expected_ipa or expected_term}."

    if tip is None:
        if score >= 88:
            tip = "Sonidos y acentuación correctos. Mantén ese ritmo."
        elif wrong_phonemes:
            tip = f"Practica los sonidos {', '.join(wrong_phonemes[:3])} imitando el audio modelo."
        else:
            tip = "Vocaliza cada sílaba y repite tras escuchar el modelo."

    # 4) Persistir intento + agregado por término (solo si hay usuario)
    if user_id:
        try:
            db.add(PronunciationAttempt(
                user_id=user_id, term=expected_term, ipa=expected_ipa, category=category,
                exercise_type=exercise_type, recognized=recognized_raw, target_ipa=target_ipa,
                heard_ipa=heard_ipa, wrong_phonemes=",".join(wrong_phonemes) or None,
                score=score, text_score=text_score, phonetic_score=phon_score,
                is_match=is_match, confidence=confidence, engine_used=engine,
                processing_stage_failed=stage_failed, audio_hash=audio_hash,
            ))
            await _upsert_term_stats(db, user_id, expected_term, category, exercise_type, score)
            await _upsert_phoneme_progress(db, user_id, target_ipa or expected_ipa or expected_term, wrong_phonemes, score)
            await db.commit()

        except Exception as e:
            await db.rollback()
            logger.warning(f"No se pudo guardar intento/stats: {e}")

        # Registrar en la Memoria Progresiva Vectorial (asíncrono en segundo plano, Prioridad BAJA)
        if wrong_phonemes or score < 75:
            background_tasks.add_task(
                memory_service.record_weakness,
                user_id=user_id,
                flaw_type="phoneme_flaw",
                text=f"{expected_term} (fonemas fallados: {', '.join(wrong_phonemes)})" if wrong_phonemes else expected_term,
                details=f"Puntuación: {score}/100. IPA: {target_ipa or expected_ipa or ''}",
                weight=1.0 if score < 70 else 0.5,
            )

    return PronunciationCheckOut(
        expected_term=expected_term, recognized_text=recognized_raw, score=score,
        text_score=text_score, phonetic_score=phon_score, is_match=is_match,
        stt_ok=stt_ok or ph is not None, engine_used=engine, exercise_type=exercise_type,
        confidence=confidence, processing_stage_failed=stage_failed, feedback=feedback,
        tip=tip, wrong_phonemes=wrong_phonemes, target_ipa=target_ipa, audio_url=saved_audio_url,
    )


from app.models import PronunciationAttempt, PronunciationTermStats, UserPhonemeProgress, UserAudioBaseline, utc_now
import math

def calculate_wilson_lower_bound(successes: int, attempts: int, z: float = 1.96) -> float:
    if attempts <= 0:
        return 0.0
    p_hat = successes / attempts
    z2 = z * z
    denominator = 1.0 + z2 / attempts
    center_adjusted_probability = p_hat + z2 / (2 * attempts)
    adjusted_std = math.sqrt((p_hat * (1.0 - p_hat) + z2 / (4 * attempts)) / attempts)
    lower_bound = (center_adjusted_probability - z * adjusted_std) / denominator
    return max(0.0, min(1.0, float(lower_bound)))


def calculate_recency_weighted_gop(old_recency_gop: float, new_gop: float, last_date, now_date) -> float:
    if not last_date:
        return float(new_gop)
    try:
        if getattr(last_date, "tzinfo", None) is None and getattr(now_date, "tzinfo", None) is not None:
            now_date = now_date.replace(tzinfo=None)
        elif getattr(last_date, "tzinfo", None) is not None and getattr(now_date, "tzinfo", None) is None:
            last_date = last_date.replace(tzinfo=None)
        days_elapsed = max(0.0, (now_date - last_date).total_seconds() / 86400.0)
    except Exception:
        days_elapsed = 0.0
    # Exponencial decay con media-vida (half-life) = 30 días
    decay_factor = math.exp(-0.693 * days_elapsed / 30.0)
    # Alpha dinámico basado en peso
    alpha = 0.3
    decayed_old = old_recency_gop * decay_factor
    return round(float(alpha * new_gop + (1.0 - alpha) * decayed_old), 2)


async def _upsert_phoneme_progress(db: AsyncSession, user_id: str, target_ipa: Optional[str], wrong_phonemes: list[str], item_score: int):
    if not user_id or not target_ipa:
        return
    # Extraer fonemas target esperados
    target_tokens = [t.strip().lower() for t in target_ipa.replace("/", " ").replace("_", " ").split() if t.strip()]
    wrong_set = set(w.strip().lower() for w in wrong_phonemes if w.strip())
    now = utc_now()
    item_gop = max(0.0, min(100.0, float(item_score)))

    for ph_sym in target_tokens:
        if not ph_sym:
            continue
        is_success = ph_sym not in wrong_set
        gop_for_phoneme = item_gop if is_success else max(0.0, item_gop - 30.0)

        row = (await db.execute(
            select(UserPhonemeProgress).where(
                UserPhonemeProgress.user_id == user_id,
                UserPhonemeProgress.phoneme == ph_sym,
            )
        )).scalar_one_or_none()

        if row is None:
            att = 1
            succ = 1 if is_success else 0
            w_lb = calculate_wilson_lower_bound(succ, att)
            conf_map = {}
            if not is_success and wrong_set:
                for w in wrong_set:
                    conf_map[w] = 1
            db.add(UserPhonemeProgress(
                user_id=user_id,
                phoneme=ph_sym,
                attempts=att,
                successes=succ,
                mean_gop=round(gop_for_phoneme, 1),
                last_gop=round(gop_for_phoneme, 1),
                recency_weighted_gop=round(gop_for_phoneme, 1),
                wilson_lower_bound=round(w_lb, 3),
                confusion_map=json.dumps(conf_map),
                last_practiced_at=now,
            ))
        else:
            att = (row.attempts or 0) + 1
            succ = (row.successes or 0) + (1 if is_success else 0)
            new_mean = round(((row.mean_gop or 0.0) * (att - 1) + gop_for_phoneme) / att, 1)
            rec_gop = calculate_recency_weighted_gop(row.recency_weighted_gop or row.mean_gop or 0.0, gop_for_phoneme, row.last_practiced_at, now)
            w_lb = calculate_wilson_lower_bound(succ, att)

            conf_dict = {}
            try:
                conf_dict = json.loads(row.confusion_map or "{}")
            except Exception:
                conf_dict = {}
            if not is_success and wrong_set:
                for w in wrong_set:
                    conf_dict[w] = conf_dict.get(w, 0) + 1

            row.attempts = att
            row.successes = succ
            row.mean_gop = new_mean
            row.last_gop = round(gop_for_phoneme, 1)
            row.recency_weighted_gop = rec_gop
            row.wilson_lower_bound = round(w_lb, 3)
            row.confusion_map = json.dumps(conf_dict)
            row.last_practiced_at = now


async def _upsert_term_stats(db, user_id, term, category, exercise_type, score):
    row = (await db.execute(
        select(PronunciationTermStats).where(
            PronunciationTermStats.user_id == user_id,
            PronunciationTermStats.term == term,
        )
    )).scalar_one_or_none()
    if row is None:
        db.add(PronunciationTermStats(
            user_id=user_id, term=term, category=category, exercise_type=exercise_type,
            attempts=1, best_score=score, last_score=score, avg_score=float(score),
            mastered=(score >= 85), last_attempt_at=utc_now(),
        ))
    else:
        n = (row.attempts or 0) + 1
        row.avg_score = round(((row.avg_score or 0.0) * (n - 1) + score) / n, 1)
        row.attempts = n
        row.last_score = score
        row.best_score = max(row.best_score or 0, score)
        row.mastered = (row.best_score >= 85 and n >= 2)
        row.last_attempt_at = utc_now()
        if category:
            row.category = category


class BaselineIn(BaseModel):
    user_id: str
    target_type: str = "word" # word, sentence, probe
    target_id: str
    audio_path: str
    score: float
    gop: float = 0.0


@router.post("/baseline")
async def save_or_update_baseline(body: BaselineIn, db: AsyncSession = Depends(get_db)):
    baseline_id = f"{body.user_id}:{body.target_type}:{body.target_id}"
    row = (await db.execute(
        select(UserAudioBaseline).where(UserAudioBaseline.id == baseline_id)
    )).scalar_one_or_none()

    now = utc_now()
    if row is None:
        new_row = UserAudioBaseline(
            id=baseline_id,
            user_id=body.user_id,
            target_type=body.target_type,
            target_id=body.target_id,
            baseline_audio_path=body.audio_path,
            baseline_score=body.score,
            baseline_gop=body.gop or body.score,
            baseline_created_at=now,
            latest_audio_path=body.audio_path,
            latest_score=body.score,
            latest_gop=body.gop or body.score,
            latest_updated_at=now,
        )
        db.add(new_row)
        await db.commit()
        return {
            "id": baseline_id,
            "has_day1": True,
            "delta_score": 0.0,
            "delta_gop": 0.0,
            "is_initial": True,
            "baseline_created_at": now.isoformat(),
        }
    else:
        # Calcular delta con respecto al Día 1
        delta_score = round(body.score - (row.baseline_score or 0.0), 1)
        delta_gop = round((body.gop or body.score) - (row.baseline_gop or 0.0), 1)
        row.latest_audio_path = body.audio_path
        row.latest_score = body.score
        row.latest_gop = body.gop or body.score
        row.latest_updated_at = now
        await db.commit()
        return {
            "id": baseline_id,
            "has_day1": True,
            "delta_score": delta_score,
            "delta_gop": delta_gop,
            "is_initial": False,
            "baseline_score": row.baseline_score,
            "latest_score": row.latest_score,
            "baseline_created_at": row.baseline_created_at.isoformat() if row.baseline_created_at else None,
        }


@router.get("/baseline/{user_id}/{target_id}")
async def get_baseline_comparison(user_id: str, target_id: str, target_type: str = "word", db: AsyncSession = Depends(get_db)):
    baseline_id = f"{user_id}:{target_type}:{target_id}"
    row = (await db.execute(
        select(UserAudioBaseline).where(UserAudioBaseline.id == baseline_id)
    )).scalar_one_or_none()

    if not row:
        return {"has_baseline": False}

    delta_score = round((row.latest_score or 0.0) - (row.baseline_score or 0.0), 1)
    delta_gop = round((row.latest_gop or 0.0) - (row.baseline_gop or 0.0), 1)

    return {
        "has_baseline": True,
        "id": row.id,
        "baseline_audio_path": row.baseline_audio_path,
        "baseline_score": row.baseline_score,
        "baseline_gop": row.baseline_gop,
        "baseline_created_at": row.baseline_created_at.isoformat() if row.baseline_created_at else None,
        "latest_audio_path": row.latest_audio_path,
        "latest_score": row.latest_score,
        "latest_gop": row.latest_gop,
        "latest_updated_at": row.latest_updated_at.isoformat() if row.latest_updated_at else None,
        "delta_score": delta_score,
        "delta_gop": delta_gop,
    }


@router.get("/phonemes/heatmap/{user_id}")
async def get_phoneme_heatmap(user_id: str, db: AsyncSession = Depends(get_db)):
    rows = (await db.execute(
        select(UserPhonemeProgress).where(UserPhonemeProgress.user_id == user_id)
    )).scalars().all()

    items = []
    for r in rows:
        conf = {}
        try:
            conf = json.loads(r.confusion_map or "{}")
        except Exception:
            conf = {}
        
        # Estado pedagógico: collecting si < 8 intentos
        is_collecting = (r.attempts or 0) < 8
        items.append({
            "phoneme": r.phoneme,
            "attempts": r.attempts or 0,
            "successes": r.successes or 0,
            "accuracy": round(((r.successes or 0) / r.attempts * 100), 1) if r.attempts else 0.0,
            "mean_gop": r.mean_gop or 0.0,
            "recency_weighted_gop": r.recency_weighted_gop or 0.0,
            "wilson_lower_bound": r.wilson_lower_bound or 0.0,
            "is_collecting": is_collecting,
            "confusion_map": conf,
            "last_practiced_at": r.last_practiced_at.isoformat() if r.last_practiced_at else None,
        })

    # Ordenar los más débiles con significancia estadística
    weakest = sorted([it for it in items if not it["is_collecting"]], key=lambda x: x["wilson_lower_bound"])[:5]

    return {
        "user_id": user_id,
        "total_phonemes_evaluated": len(items),
        "phonemes": items,
        "priority_contrasts": weakest,
    }


class TipIn(BaseModel):
    term: str
    ipa: Optional[str] = None
    recognized: Optional[str] = ""
    score: int = 0
    wrong_phonemes: list[str] = []
    confidence: float = 1.0


@router.post("/tip")
async def pronunciation_tip(body: TipIn):
    wrong = body.wrong_phonemes if body.confidence >= 0.5 else None
    tip, engine = await _ai_tip(body.term, body.ipa, body.recognized or "", body.score, wrong)
    if tip is None:
        if body.score >= 88:
            tip = "Sonidos y acentuación correctos. Mantén ese ritmo."
        elif body.wrong_phonemes:
            tip = f"Practica los sonidos {', '.join(body.wrong_phonemes[:3])} imitando el audio modelo."
        else:
            tip = "Vocaliza cada sílaba y repite tras escuchar el modelo."
        engine = "standard"
    return {"tip": tip, "engine": engine}


@router.get("/history")
async def pronunciation_history(user_id: str, limit: int = 50, db: AsyncSession = Depends(get_db)):
    rows = (await db.execute(
        select(PronunciationAttempt)
        .where(PronunciationAttempt.user_id == user_id)
        .order_by(desc(PronunciationAttempt.created_at))
        .limit(limit)
    )).scalars().all()
    avg = round(sum(r.score for r in rows) / len(rows), 1) if rows else 0.0
    return {
        "user_id": user_id,
        "count": len(rows),
        "average_score": avg,
        "attempts": [
            {"term": r.term, "score": r.score, "recognized": r.recognized,
             "is_match": r.is_match, "engine": r.engine_used,
             "created_at": r.created_at.isoformat() if r.created_at else None}
            for r in rows
        ],
    }


@router.get("/progress")
async def pronunciation_progress(user_id: str, db: AsyncSession = Depends(get_db)):
    rows = (await db.execute(
        select(PronunciationTermStats)
        .where(PronunciationTermStats.user_id == user_id)
        .order_by(PronunciationTermStats.avg_score.asc())
    )).scalars().all()
    if not rows:
        return {"user_id": user_id, "terms_practiced": 0, "average_score": 0.0,
                "mastered": 0, "weakest": [], "by_category": {}}
    avg = round(sum(r.avg_score for r in rows) / len(rows), 1)
    weakest = [{"term": r.term, "avg": r.avg_score, "best": r.best_score,
                "attempts": r.attempts} for r in rows[:8]]
    by_cat: dict = {}
    for r in rows:
        cat = r.category or "general"
        d = by_cat.setdefault(cat, {"terms": 0, "sum": 0.0, "mastered": 0})
        d["terms"] += 1
        d["sum"] += r.avg_score
        d["mastered"] += 1 if r.mastered else 0
    for cat, d in by_cat.items():
        d["average"] = round(d["sum"] / d["terms"], 1)
        del d["sum"]
    return {
        "user_id": user_id,
        "terms_practiced": len(rows),
        "average_score": avg,
        "mastered": sum(1 for r in rows if r.mastered),
        "weakest": weakest,
        "by_category": by_cat,
    }

