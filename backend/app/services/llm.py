"""
LlmService — Servicio central de inferencia LLM.

Usa RobustOllamaClient (circuit-breaker + TTL cache) en lugar de httpx directo.
Registra cada llamada en LlmInteractionLog para el bucle de auto-aprendizaje.

Modelos:
  phi4-mini: DEFAULT — feedback pedagogico rapido en espanol (~61 tok/s)
  lito-fast: ADVANCED — tutor personalizado para analisis profundo (~57 tok/s)
  qwen3:4b : BACKUP — razonamiento extendido para generacion de contenido
"""
import json
import logging
import uuid
from typing import Optional

from pydantic import BaseModel, ValidationError
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.schemas import LLMEvaluationResult, PronunciationFeedback
from app.providers.ollama_provider import get_ollama_client
from app.services.memory_service import memory_service

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────────────────────────────────────
# System prompts
# ──────────────────────────────────────────────────────────────────────────────

INTERVIEW_SYSTEM_PROMPT = """You are a senior technical interviewer and expert English communication coach for Spanish-speaking software engineers.
Analyze the candidate's answer and respond ONLY with a valid JSON object (no markdown, no extra text):
{
  "interviewer_reply": "Natural follow-up question or comment as interviewer (in English)",
  "grammar_corrections": [{"original": "...", "correction": "...", "explanation": "..."}],
  "vocabulary_suggestions": [{"term": "...", "context": "...", "alternatives": ["..."]}],
  "overall_score": 8,
  "fluency_feedback": "Specific actionable advice on STAR structure, metrics, and delivery in Spanish",
  "pronunciation_feedback": {
    "score": 85,
    "clarity": "Excellent|Good|Moderate|Needs Practice",
    "mispronounced_or_difficult_words": ["scalable", "asynchronous"],
    "phonetic_tips": ["/ˈskeɪ.lə.bəl/ — Evita la 'e' de apoyo inicial: pronuncia la 's' continua limpia; 'ca' suena /keɪ/."],
    "filler_words_detected": []
  }
}

SCORING & COACHING GUIDELINES:
1. overall_score (1-10): 1-3 = off-topic, too brief (<2 sentences); 4-6 = understandable but generic, missing measurable impact; 7-8 = solid STAR answer with clear action and outcome; 9-10 = concise STAR + quantifiable metric + C1 technical diction.
2. grammar_corrections: Only correct ACTUAL mistakes. If there are none, return []. Never hallucinate errors.
3. pronunciation_feedback: Identify tricky English technical terms or common Spanish-speaker phoneme pitfalls (e.g., initial /s/ vs /es/, silent letters, short vs long vowels /iː/ vs /ɪ/, /θ/ vs /s/, /v/ vs /b/, -ed endings). Provide IPA and practical tongue/mouth pronunciation tips in Spanish.
4. Language constraints: 'interviewer_reply' MUST be in English. All explanations, tips, and 'fluency_feedback' MUST be in Spanish."""

GRAMMAR_SYSTEM_PROMPT = """Eres Lito, tutor experto de inglés para hispanohablantes.
Tu tarea es analizar y corregir errores gramaticales en frases en inglés.

REGLA OBLIGATORIA DE IDIOMA:
El campo "explanation" DEBE ESTAR 100% EN ESPAÑOL claro, empático y pedagógico. NUNCA escribas la explicación en inglés. Explica exactamente en qué consiste el fallo gramatical (tiempos verbales, preposiciones, concordancia, orden de palabras, etc.) para que el alumno hispanohablante lo comprenda de inmediato.

Responde ÚNICAMENTE con JSON válido:
{
  "has_errors": true,
  "original": "frase original",
  "corrected": "frase corregida en inglés",
  "error_type": "verb_tense|preposition|subject_verb|article|word_order|double_negative|passive_voice|other",
  "explanation": "Explicación clara y pedagógica en ESPAÑOL (máximo 2-3 frases) explicando por qué está mal y cómo se usa correctamente la estructura.",
  "example_correct": "Otra frase de ejemplo correcta en inglés",
  "cefr_level": "A2|B1|B2|C1"
}

EJEMPLOS:
Entrada: "I has three years working with Python"
Salida: {"has_errors": true, "original": "I has three years working with Python", "corrected": "I have been working with Python for three years", "error_type": "verb_tense", "explanation": "Para expresar la duración de una acción continua se usa 'have been + -ing' acompañado de 'for'. Además, el pronombre 'I' concuerda con 'have' y no con 'has'.", "example_correct": "They have been using Docker for two years.", "cefr_level": "B1"}

Entrada: "It strictly necessary that we implement a cache"
Salida: {"has_errors": true, "original": "It strictly necessary that we implement a cache", "corrected": "It is strictly necessary that we implement a cache layer", "error_type": "subject_verb", "explanation": "Falta el verbo 'to be' ('is' o la contracción 'it's') para conectar el sujeto impersonal con el adjetivo 'strictly necessary'.", "example_correct": "It is important that we review the pull request.", "cefr_level": "B2"}"""


VOCABULARY_SYSTEM_PROMPT = """Eres un diccionario pedagogico de ingles para hispanohablantes.
Responde SOLO con JSON valido:
{
  "word": "palabra en ingles",
  "ipa": "/pronunciacion/",
  "translation": "traduccion en espanol",
  "cefr_level": "A1|A2|B1|B2|C1|C2",
  "definition": "definicion en espanol (max 1 frase)",
  "examples": ["Frase de ejemplo 1 en ingles", "Frase de ejemplo 2 en ingles"],
  "synonyms": ["sinonimo1", "sinonimo2"],
  "collocations": ["collocacion comun 1", "collocacion comun 2"],
  "memory_tip": "Truco mnemotecnico para recordarla"
}

EJEMPLO
Entrada: "scalable"
Salida: {"word": "scalable", "ipa": "/skeilebl/", "translation": "escalable", "cefr_level": "B2", "definition": "Que puede crecer o soportar mas carga sin perder rendimiento.", "examples": ["We designed a scalable architecture.", "The service must be scalable to millions of users."], "synonyms": ["expandable", "extensible"], "collocations": ["scalable architecture", "highly scalable"], "memory_tip": "scale (escala) + -able: que se puede escalar."}"""

AUDIO_ANALYSIS_PROMPT = """Eres Lito, tutor de ingles. Analiza esta transcripcion de audio del alumno y responde SOLO con JSON:
{
  "grammar_errors": [{"original": "...", "correction": "...", "explanation": "..."}],
  "pronunciation_issues": ["palabra dificil 1", "palabra dificil 2"],
  "fluency_score": 75,
  "vocabulary_level": "A2|B1|B2|C1",
  "feedback": "Retroalimentacion constructiva en espanol (2-3 frases)",
  "strengths": ["Punto fuerte 1", "Punto fuerte 2"],
  "improvements": ["Area de mejora 1", "Area de mejora 2"]
}

fluency_score 0-100 por CEFR: <40=A1-A2, 40-60=B1, 60-80=B2, 80-100=C1+. Si la transcripcion es correcta deja grammar_errors vacio; no inventes errores. feedback en espanol.

EJEMPLO
Transcripcion: "Yesterday I go to the office and I fix the bug in the API"
Salida: {"grammar_errors": [{"original": "Yesterday I go", "correction": "Yesterday I went", "explanation": "Pasado simple para accion terminada: go -> went."}], "pronunciation_issues": [], "fluency_score": 55, "vocabulary_level": "B1", "feedback": "Ideas claras y vocabulario tecnico correcto; revisa el pasado simple.", "strengths": ["Uso correcto de terminos tecnicos (API, bug)"], "improvements": ["Conjuga en pasado simple las acciones terminadas"]}"""

FREE_TALK_SYSTEM_PROMPT = """You are Lito, a senior technical colleague and charismatic English speaking coach for Spanish-speaking software engineers.
You are having an open, fluid conversational practice (Free Talk).
TOPIC: {topic}
TARGET CEFR LEVEL: {target_level}

RULES:
1. 'reply': Speak natural, engaging spoken English (1-3 sentences maximum). Sound like a real conversational partner — react authentically, share a concise thought, and ask a relevant question to keep the conversation flowing.
2. 'grammar_corrections': Only flag actual mistakes that hinder clarity or sound unnatural. Keep explanation in SPANISH (concise 1-2 lines). If no errors, return [].
3. 'vocabulary_suggestions': Suggest 1-2 more natural or high-level technical/business terms related to their answer.
4. 'pronunciation_tips': For tricky technical terms used, provide IPA and a helpful phonetic tip in Spanish.
5. 'fluency_score': 0-100 rating for conversational fluency.

Output ONLY valid JSON:
{{
  "reply": "Conversational reply in English...",
  "grammar_corrections": [
    {{"original": "...", "correction": "...", "explanation": "..."}}
  ],
  "vocabulary_suggestions": [
    {{"term": "...", "context": "...", "alternatives": ["..."]}}
  ],
  "pronunciation_tips": [
    {{"word": "...", "ipa": "/.../", "tip": "..."}}
  ],
  "fluency_score": 85
}}"""


# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

_INTERVIEW_FEWSHOT = [
    {"role": "user", "content": "Question: Tell me about a technical challenge. Candidate: In my last job I have worked on a API that was slow, so I add a cache and it improve a lot."},
    {"role": "assistant", "content": json.dumps({
        "interviewer_reply": "Nice. Which cache did you use, and how did you measure the improvement?",
        "grammar_corrections": [
            {"original": "I have worked on a API", "correction": "I worked on an API", "explanation": "Pasado simple para un trabajo terminado; an ante sonido vocalico."},
            {"original": "it improve a lot", "correction": "it improved a lot", "explanation": "Pasado simple: improve -> improved."}
        ],
        "vocabulary_suggestions": [
            {"term": "cache hit ratio", "context": "Metric to quantify cache effectiveness.", "alternatives": ["latency reduction", "throughput"]}
        ],
        "overall_score": 6,
        "fluency_feedback": "Buena idea, pero anade una metrica concreta (p. ej. latencia -40%) para subir a 8+.",
        "pronunciation_feedback": {
            "score": 80,
            "clarity": "Good",
            "mispronounced_or_difficult_words": ["cache", "API"],
            "phonetic_tips": ["/kæʃ/ — 'cache' rima con 'cash', la 'e' final es muda; evita decir 'keish' o 'caché'."],
            "filler_words_detected": []
        }
    }, ensure_ascii=False)},
]


# ── Esquemas de salida del LLM (structured outputs de Ollama). Todos los campos
#    son REQUIRED: el modelo se ve forzado a rellenarlos (adios a cefr_level null). ──
class _GrammarLLMOut(BaseModel):
    has_errors: bool
    original: str
    corrected: str
    error_type: str
    explanation: str
    example_correct: str
    cefr_level: str


class _VocabLLMOut(BaseModel):
    word: str
    ipa: str
    translation: str
    cefr_level: str
    definition: str
    examples: list[str]
    synonyms: list[str]
    collocations: list[str]
    memory_tip: str


_GRAMMAR_SCHEMA = _GrammarLLMOut.model_json_schema()
_VOCAB_SCHEMA = _VocabLLMOut.model_json_schema()


def _extract_json(text: str) -> Optional[dict]:
    """Extrae el primer bloque JSON valido de una cadena de texto."""
    import re
    # Intenta parsear directamente
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    # Busca bloque entre llaves
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(0))
        except json.JSONDecodeError:
            pass
    return None


def _sanitize_interview_eval(data: dict) -> dict:
    """Corrige tipos y valores antes de validar con Pydantic para evitar reintentos innecesarios."""
    if not isinstance(data, dict):
        return data
    d = dict(data)
    # overall_score
    if "overall_score" in d:
        try:
            d["overall_score"] = int(float(str(d["overall_score"]).strip() or 7))
        except Exception:
            d["overall_score"] = 7
        d["overall_score"] = max(0, min(10, d["overall_score"]))

    # pronunciation_feedback
    pf = d.get("pronunciation_feedback")
    if isinstance(pf, dict):
        pf_copy = dict(pf)
        score_raw = pf_copy.get("score")
        if score_raw is None or score_raw == "" or not str(score_raw).strip().replace(".", "", 1).isdigit():
            pf_copy["score"] = 80
        else:
            try:
                pf_copy["score"] = max(0, min(100, int(float(str(score_raw).strip()))))
            except Exception:
                pf_copy["score"] = 80
        if not pf_copy.get("clarity") or not isinstance(pf_copy.get("clarity"), str):
            pf_copy["clarity"] = "Good"
        d["pronunciation_feedback"] = pf_copy
    elif pf is not None:
        d["pronunciation_feedback"] = None

    return d


# ──────────────────────────────────────────────────────────────────────────────
# LlmService
# ──────────────────────────────────────────────────────────────────────────────

class LlmService:
    """
    Servicio central de inferencia LLM.
    Usa RobustOllamaClient para circuit-breaker, TTL cache y metricas GPU.
    Todos los metodos retornan None si el worker no esta disponible
    (la capa superior decide el fallback apropiado).
    """

    def __init__(self) -> None:
        self._grammar_cache: dict[str, dict] = {}

    async def get_student_profile_prompt(self, user_id: str, db: Optional[AsyncSession] = None) -> str:
        """Construye el bloque de perfil de debilidades dinámico del alumno para inyectar en el system prompt."""
        weak_phonemes: list[str] = []
        weak_grammar: list[str] = []

        # 1. Consultar base de datos si está disponible
        if db and user_id:
            try:
                from sqlalchemy import select
                from app.models import UserPhonemeProgress, Mistake
                p_stmt = select(UserPhonemeProgress.phoneme).where(
                    UserPhonemeProgress.user_id == user_id,
                    UserPhonemeProgress.attempts >= 2,
                    UserPhonemeProgress.wilson_lower_bound < 0.65
                ).limit(5)
                p_res = await db.execute(p_stmt)
                weak_phonemes = [str(r[0]) for r in p_res.fetchall()]

                m_stmt = select(Mistake.correction_type).where(
                    Mistake.user_id == user_id
                ).group_by(Mistake.correction_type).limit(4)
                m_res = await db.execute(m_stmt)
                weak_grammar = [str(r[0]) for r in m_res.fetchall() if r[0]]
            except Exception as e:
                logger.debug(f"Error consultando debilidades de usuario {user_id}: {e}")

        # 2. Complementar con memorias vectoriales si faltan datos
        if not weak_phonemes or not weak_grammar:
            memories = memory_service._load_user_memories(user_id)
            for m in memories:
                ftype = m.get("flaw_type", "")
                txt = m.get("text", "")
                if ftype == "phoneme_flaw" and txt and len(weak_phonemes) < 5:
                    weak_phonemes.append(txt)
                elif ftype == "grammar_error" and txt and len(weak_grammar) < 4:
                    weak_grammar.append(txt)

        phonemes_str = ", ".join(weak_phonemes) if weak_phonemes else "/θ/, /dʒ/, /æ/ (en observación)"
        grammar_str = ", ".join(weak_grammar) if weak_grammar else "Tiempos perfectos y conectores ejecutivos"

        return f"""
[PERFIL DEL ESTUDIANTE]
- Nivel: C1 Profesional
- Fonemas débiles detectados: {phonemes_str}
- Puntos gramaticales recurrentes: {grammar_str}
Instrucción: Si el alumno comete un error en alguno de sus puntos débiles, prioriza darle un micro-ajuste anatómico claro en español y un ejemplo en inglés de contexto ejecutivo."""

    # ── Evaluacion de turno de entrevista ─────────────────────────────────────

    async def evaluate_turn(
        self,
        question_text: str,
        user_transcript: str,
        conversation_history: list[dict] | None = None,
        max_retries: int = 2,
        db: Optional[AsyncSession] = None,
        session_id: str = "",
        user_id: str = "default_user",
    ) -> LLMEvaluationResult:
        ollama = get_ollama_client()

        if await ollama.is_available():
            # Recuperar debilidades relevantes del alumno (<20ms via nomic-embed-text)
            weaknesses = await memory_service.find_relevant_weaknesses(user_id, f"{question_text} {user_transcript}", top_k=2)
            student_context = ""
            if weaknesses:
                items = [f"- {w['flaw_type']}: {w['text']}" for w in weaknesses]
                student_context = "\nStudent History Notes (prioritize correcting if triggered):\n" + "\n".join(items)

            profile_block = await self.get_student_profile_prompt(user_id, db=db)
            system_prompt = f"{INTERVIEW_SYSTEM_PROMPT}\n\n{profile_block}"

            user_content = f"Question: {question_text}\nCandidate: {user_transcript}{student_context}"
            messages = [{"role": "system", "content": system_prompt}]
            messages.extend(_INTERVIEW_FEWSHOT)  # ejemplo dorado: calibra nota y correcciones
            if conversation_history:
                messages.extend(conversation_history[-4:])
            messages.append({"role": "user", "content": user_content})

            for attempt in range(max_retries + 1):
                result = await ollama.chat(messages=messages, temperature=0.3, fmt="json", num_ctx=3072, num_predict=450)
                if not result:
                    break

                raw = result.get("response", "")
                parsed = _extract_json(raw)
                if parsed:
                    try:
                        sanitized = _sanitize_interview_eval(parsed)
                        validated = LLMEvaluationResult.model_validate(sanitized)
                        # Log de telemetria
                        await self._log_interaction(
                            db=db, session_id=session_id, user_id=user_id,
                            user_transcript=user_transcript,
                            system_prompt=INTERVIEW_SYSTEM_PROMPT,
                            user_prompt=user_content,
                            response_text=validated.interviewer_reply,
                            model_name=result.get("model_used", settings.OLLAMA_MODEL),
                            latency_ms=result.get("latency_ms"),
                            eval_count=result.get("eval_count"),
                            eval_duration_sec=result.get("eval_duration_sec"),
                            tokens_per_second=result.get("tokens_per_sec"),
                            detected_intent="interview_evaluation",
                        )
                        return validated
                    except ValidationError as e:
                        logger.warning(f"LLM JSON invalido intento {attempt+1}: {e}")
                        if attempt < max_retries:
                            messages.append({
                                "role": "user",
                                "content": "CRITICAL: Output ONLY valid JSON matching the schema. No markdown."
                            })

        return self._mock_evaluation(question_text, user_transcript)

    # ── Verificacion gramatical ───────────────────────────────────────────────

    async def check_grammar(
        self,
        sentence: str,
        db: Optional[AsyncSession] = None,
        user_id: str = "default_user",
    ) -> Optional[dict]:
        """Corrige un error gramatical y devuelve JSON estructurado o None si offline."""
        clean_s = sentence.strip()
        if clean_s in self._grammar_cache:
            return self._grammar_cache[clean_s]

        ollama = get_ollama_client()
        if not await ollama.is_available():
            return None

        result = await ollama.generate_feedback(
            prompt=sentence,
            system_prompt=GRAMMAR_SYSTEM_PROMPT,
            temperature=0.15,
            fmt=_GRAMMAR_SCHEMA,
            num_ctx=1536,
            num_predict=180,
        )
        if not result:
            return None

        parsed = _extract_json(result.get("response", ""))
        if parsed:
            if len(self._grammar_cache) > 200:
                self._grammar_cache.clear()
            self._grammar_cache[clean_s] = parsed
            await self._log_interaction(
                db=db, user_id=user_id, user_transcript=sentence,
                system_prompt=GRAMMAR_SYSTEM_PROMPT, user_prompt=sentence,
                response_text=str(parsed), model_name=result.get("model_used", ""),
                latency_ms=result.get("latency_ms"), eval_count=result.get("eval_count"),
                eval_duration_sec=result.get("eval_duration_sec"),
                tokens_per_second=result.get("tokens_per_sec"),
                detected_intent="grammar_check",
            )
        return parsed

    # ── Explicacion de vocabulario ────────────────────────────────────────────

    async def explain_vocabulary(
        self,
        word: str,
        db: Optional[AsyncSession] = None,
        user_id: str = "default_user",
    ) -> Optional[dict]:
        """Devuelve definicion pedagogica de una palabra o None si offline."""
        ollama = get_ollama_client()
        if not await ollama.is_available():
            return None

        result = await ollama.generate_feedback(
            prompt=f"Explain the English word: {word}",
            system_prompt=VOCABULARY_SYSTEM_PROMPT,
            temperature=0.2,
            fmt=_VOCAB_SCHEMA,
            num_ctx=1536,
            num_predict=220,
        )
        if not result:
            return None

        parsed = _extract_json(result.get("response", ""))
        if parsed:
            await self._log_interaction(
                db=db, user_id=user_id, user_transcript=word,
                system_prompt=VOCABULARY_SYSTEM_PROMPT, user_prompt=word,
                response_text=str(parsed), model_name=result.get("model_used", ""),
                latency_ms=result.get("latency_ms"), eval_count=result.get("eval_count"),
                eval_duration_sec=result.get("eval_duration_sec"),
                tokens_per_second=result.get("tokens_per_sec"),
                detected_intent="vocabulary_lookup",
            )
        return parsed

    # ── Analisis de audio (transcripcion ya hecha) ────────────────────────────

    async def analyze_transcript(
        self,
        transcript: str,
        context_type: str = "speaking",
        db: Optional[AsyncSession] = None,
        user_id: str = "default_user",
    ) -> Optional[dict]:
        """Analisis pedagogico de una transcripcion de audio."""
        ollama = get_ollama_client()
        if not await ollama.is_available():
            return None

        context_note = {
            "dictation": "El alumno estaba haciendo un ejercicio de dictado.",
            "speaking": "El alumno estaba practicando conversacion libre.",
            "shadowing": "El alumno estaba haciendo shadowing de un audio.",
            "pronunciation": "El alumno estaba practicando pronunciacion.",
        }.get(context_type, "")

        prompt = f"{context_note}\nTranscripcion del alumno: {transcript}"

        result = await ollama.generate_feedback(
            prompt=prompt,
            system_prompt=AUDIO_ANALYSIS_PROMPT,
            temperature=0.2,
            fmt="json",
        )
        if not result:
            return None

        parsed = _extract_json(result.get("response", ""))
        if parsed:
            await self._log_interaction(
                db=db, user_id=user_id, user_transcript=transcript,
                system_prompt=AUDIO_ANALYSIS_PROMPT, user_prompt=prompt,
                response_text=str(parsed), model_name=result.get("model_used", ""),
                latency_ms=result.get("latency_ms"), eval_count=result.get("eval_count"),
                eval_duration_sec=result.get("eval_duration_sec"),
                tokens_per_second=result.get("tokens_per_sec"),
                detected_intent=f"audio_analysis_{context_type}",
            )
        return parsed

    # ── Log de telemetria ─────────────────────────────────────────────────────

    # ── Conversacion Libre (Free Talk) ────────────────────────────────────────

    async def free_talk_turn(
        self,
        user_transcript: str,
        conversation_history: Optional[list[dict]] = None,
        topic: str = "General Tech & Architecture",
        target_level: str = "B2",
        db: Optional[AsyncSession] = None,
        user_id: str = "default_user",
    ) -> dict:
        """
        Genera un turno fluido de conversación libre con feedback no invasivo,
        sugerencias de vocabulario técnico y fonética.
        """
        ollama = get_ollama_client()
        system_prompt = FREE_TALK_SYSTEM_PROMPT.format(topic=topic, target_level=target_level)

        if await ollama.is_available():
            messages = [{"role": "system", "content": system_prompt}]
            if conversation_history:
                # Mantener los últimos 6 turnos para no saturar contexto
                messages.extend(conversation_history[-6:])
            messages.append({"role": "user", "content": user_transcript})

            result = await ollama.chat(
                messages=messages,
                temperature=0.4,
                fmt="json",
                num_ctx=2048,
                num_predict=350,
            )
            if result and result.get("response"):
                parsed = _extract_json(result["response"])
                if parsed and "reply" in parsed:
                    await self._log_interaction(
                        db=db,
                        user_id=user_id,
                        user_transcript=user_transcript,
                        system_prompt=system_prompt,
                        user_prompt=user_transcript,
                        response_text=result["response"],
                        model_name=result.get("model_used", ""),
                        latency_ms=result.get("latency_ms"),
                        eval_count=result.get("eval_count"),
                        eval_duration_sec=result.get("eval_duration_sec"),
                        tokens_per_second=result.get("tokens_per_sec"),
                        detected_intent="free_talk",
                    )
                    return {
                        "reply": parsed.get("reply", ""),
                        "grammar_corrections": parsed.get("grammar_corrections", []),
                        "vocabulary_suggestions": parsed.get("vocabulary_suggestions", []),
                        "pronunciation_tips": parsed.get("pronunciation_tips", []),
                        "fluency_score": parsed.get("fluency_score", 80),
                        "engine_used": "fast",
                    }

        # Fallback offline amigable y contextual
        fallback_replies = [
            f"That's a very relevant point regarding {topic.lower()}. How would you structure that from a high-level perspective?",
            f"Interesting! When working on {topic.lower()}, what are the main bottlenecks or trade-offs you typically anticipate?",
            "Makes total sense. Could you walk me through a specific real-world scenario where you applied that approach?",
        ]
        import random
        return {
            "reply": random.choice(fallback_replies),
            "grammar_corrections": [],
            "vocabulary_suggestions": [],
            "pronunciation_tips": [],
            "fluency_score": 80,
            "engine_used": "standard",
        }

    async def _log_interaction(
        self,
        db: Optional[AsyncSession],
        user_transcript: str,
        system_prompt: str,
        user_prompt: str,
        response_text: str,
        model_name: str,
        latency_ms: Optional[float],
        eval_count: Optional[int],
        eval_duration_sec: Optional[float],
        tokens_per_second: Optional[float],
        detected_intent: str = "",
        session_id: str = "",
        user_id: str = "default_user",
    ) -> None:
        if db is None:
            return
        try:
            from app.models import LlmInteractionLog
            log = LlmInteractionLog(
                session_id=session_id or str(uuid.uuid4()),
                user_id=user_id,
                user_transcript=user_transcript,
                detected_intent=detected_intent,
                system_prompt_used=system_prompt[:2000],
                user_prompt_used=user_prompt[:2000],
                model_name=model_name,
                response_text=response_text[:4000],
                engine_used="fast",
                latency_ms=latency_ms,
                eval_count=eval_count,
                eval_duration_sec=eval_duration_sec,
                tokens_per_second=tokens_per_second,
            )
            db.add(log)
            await db.flush()
        except Exception as exc:
            logger.warning(f"Error guardando LlmInteractionLog: {exc}")

    # ── Mock fallback ─────────────────────────────────────────────────────────

    def _mock_evaluation(self, question_text: str, user_transcript: str) -> LLMEvaluationResult:
        # Degradado HONESTO: si el LLM no está disponible o no devolvió JSON válido,
        # NO inventamos correcciones ni una nota (eso creaba tarjetas FSRS fantasma
        # de errores que el alumno nunca cometió). Score 0 = "no evaluado".
        return LLMEvaluationResult(
            interviewer_reply="Thanks for your answer. Let's continue — could you give a specific example with the result you achieved?",
            grammar_corrections=[],
            vocabulary_suggestions=[],
            overall_score=0,
            fluency_feedback=(
                "El evaluador con IA no está disponible ahora mismo, así que esta respuesta no se ha puntuado. "
                "Conéctate al worker GPU para recibir corrección detallada."
            ),
            pronunciation_feedback=PronunciationFeedback(
                score=0, clarity="Unavailable",
                mispronounced_or_difficult_words=[],
                phonetic_tips=[],
                filler_words_detected=[],
            ),
        )


llm_service = LlmService()
