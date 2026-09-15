from datetime import datetime, timezone
import json
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.database import Base

def utc_now():
    return datetime.now(timezone.utc)

class Question(Base):
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True, index=True)
    category = Column(String(50), index=True)  # hr, tech, vocab
    difficulty = Column(String(20), default="junior")  # junior, mid, senior
    title = Column(String(200), nullable=False)
    text = Column(Text, nullable=False)
    model_answer = Column(Text, nullable=True)
    tips = Column(Text, nullable=True)

    # Pedagogy taxonomy (nullable, backward-compatible)
    track = Column(String(20), nullable=True)            # speaking, listening, grammar, vocabulary, writing
    scenario = Column(String(40), nullable=True)         # foundations, technical_interview, hr_interview, ...
    objective_id = Column(String(64), nullable=True)     # communicative objective
    difficulty_band = Column(String(10), nullable=True)  # A2-B1, B1-B2, B2-C1, C1

    turns = relationship("Turn", back_populates="question")


class Session(Base):
    __tablename__ = "sessions"

    id = Column(String(64), primary_key=True, index=True)
    user_id = Column(String(64), default="default_user", index=True)
    started_at = Column(DateTime, default=utc_now)
    completed_at = Column(DateTime, nullable=True)
    status = Column(String(20), default="active")  # active, completed

    turns = relationship("Turn", back_populates="session", cascade="all, delete-orphan")


class Turn(Base):
    __tablename__ = "turns"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String(64), ForeignKey("sessions.id"), nullable=False, index=True)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=True)
    audio_path = Column(String(255), nullable=True)
    transcript = Column(Text, nullable=False)
    ai_reply_text = Column(Text, nullable=False)
    ai_reply_audio_path = Column(String(255), nullable=True)
    feedback_json = Column(Text, nullable=False)  # Serialized JSON
    created_at = Column(DateTime, default=utc_now)

    session = relationship("Session", back_populates="turns")
    question = relationship("Question", back_populates="turns")
    mistakes = relationship("Mistake", back_populates="turn", cascade="all, delete-orphan")


class Mistake(Base):
    __tablename__ = "mistakes"

    id = Column(Integer, primary_key=True, index=True)
    turn_id = Column(Integer, ForeignKey("turns.id"), nullable=False, index=True)
    category = Column(String(50), default="grammar")  # grammar, vocabulary, pronunciation
    original = Column(Text, nullable=False)
    correction = Column(Text, nullable=False)
    explanation = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=utc_now)

    turn = relationship("Turn", back_populates="mistakes")
    card = relationship("Card", back_populates="mistake", uselist=False, cascade="all, delete-orphan")


class Card(Base):
    """
    FSRS (Free Spaced Repetition Scheduler) Flashcard model
    States:
    0 = New
    1 = Learning
    2 = Review
    3 = Relearning
    """
    __tablename__ = "cards"

    id = Column(Integer, primary_key=True, index=True)
    mistake_id = Column(Integer, ForeignKey("mistakes.id"), nullable=True, unique=True)
    front = Column(Text, nullable=False)
    back = Column(Text, nullable=False)
    
    # FSRS core variables
    state = Column(Integer, default=0)  # 0=New, 1=Learning, 2=Review, 3=Relearning
    difficulty = Column(Float, default=0.0)
    stability = Column(Float, default=0.0)
    due_date = Column(DateTime, default=utc_now, index=True)
    last_review = Column(DateTime, nullable=True)
    reps = Column(Integer, default=0)
    lapses = Column(Integer, default=0)
    
    exported_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=utc_now)

    # Pedagogy: generalized FSRS ingestion (per-user, any source)
    user_id = Column(String(64), default="user-ivan", index=True)
    source_type = Column(String(30), default="interview_mistake")  # interview_mistake, vocabulary, grammar, listening
    item_type = Column(String(30), default="sentence_correction")  # word_meaning, sentence_correction, audio_recognition, irregular_verb_form, interview_opener, phrase_completion
    unit_id = Column(String(64), nullable=True)
    skill = Column(String(20), default="speaking")

    mistake = relationship("Mistake", back_populates="card")


class ExternalResource(Base):
    __tablename__ = "external_resources"

    id = Column(String(64), primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    original_url = Column(String(500), nullable=False)
    source_name = Column(String(50), default="awesome-english")  # awesome-english, leatex-gist
    resource_type = Column(String(50), default="tool")  # podcast, course, youtube, tool, exercise, book, article
    skill = Column(String(50), default="listening")  # listening, speaking, grammar, vocabulary, reading, writing, pronunciation, interview
    domain = Column(String(50), default="tech_english")  # general_english, tech_english, interview_english
    level = Column(String(20), default="B1-B2")  # A2, B1, B2, C1, All
    tags = Column(Text, default="[]")  # Serialized JSON list of tags
    transcript_available = Column(Boolean, default=False)
    spanish_support = Column(Boolean, default=False)
    estimated_minutes = Column(Integer, default=15)
    recommended_for = Column(String(255), nullable=True)
    spanish_notes = Column(Text, nullable=True)
    status = Column(String(20), default="imported")  # imported, reviewed, published
    collection_id = Column(String(64), ForeignKey("resource_collections.id"), nullable=True)
    created_at = Column(DateTime, default=utc_now)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)

    collection = relationship("ResourceCollection", back_populates="resources")
    unit_links = relationship("UnitResourceLink", back_populates="resource", cascade="all, delete-orphan")


class ResourceCollection(Base):
    __tablename__ = "resource_collections"

    id = Column(String(64), primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    icon = Column(String(50), default="bookmark")
    color = Column(String(20), default="#0D9488")
    order_index = Column(Integer, default=0)
    created_at = Column(DateTime, default=utc_now)

    resources = relationship("ExternalResource", back_populates="collection")


class ResourceTag(Base):
    __tablename__ = "resource_tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, index=True)
    category = Column(String(50), default="tech")


class UnitResourceLink(Base):
    __tablename__ = "unit_resource_links"

    id = Column(Integer, primary_key=True, index=True)
    resource_id = Column(String(64), ForeignKey("external_resources.id"), nullable=False, index=True)
    target_type = Column(String(20), nullable=False)  # unit, pack, question
    target_id = Column(String(64), nullable=False, index=True)  # e.g. unit-1-junior, backend
    relevance_note = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=utc_now)

    resource = relationship("ExternalResource", back_populates="unit_links")


class ImportRun(Base):
    __tablename__ = "import_runs"

    id = Column(String(64), primary_key=True, index=True)
    source_name = Column(String(50), nullable=False)
    status = Column(String(20), default="completed")
    total_parsed = Column(Integer, default=0)
    total_imported = Column(Integer, default=0)
    total_published = Column(Integer, default=0)
    log_summary = Column(Text, nullable=True)
    started_at = Column(DateTime, default=utc_now)
    completed_at = Column(DateTime, nullable=True)


class PublishedSnapshot(Base):
    __tablename__ = "published_snapshots"

    id = Column(String(64), primary_key=True, index=True)
    version = Column(String(20), nullable=False)
    sha256_hash = Column(String(64), nullable=False)
    resource_count = Column(Integer, default=0)
    collection_count = Column(Integer, default=0)
    snapshot_json = Column(Text, nullable=False)
    created_at = Column(DateTime, default=utc_now)


class ResourceUsageLog(Base):
    __tablename__ = "resource_usage_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(64), default="default_user", index=True)
    resource_id = Column(String(64), ForeignKey("external_resources.id"), nullable=False, index=True)
    unit_id = Column(String(64), nullable=True, index=True)
    event_type = Column(String(50), default="open")  # open, completed, bookmark, audio_play
    duration_seconds = Column(Integer, default=0)
    created_at = Column(DateTime, default=utc_now)


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(String(64), primary_key=True, index=True)
    display_name = Column(String(100), nullable=False)
    email = Column(String(100), nullable=True)
    avatar_url = Column(String(255), nullable=True)
    target_level = Column(String(20), default="B2")  # A2, B1, B2, C1
    role_title = Column(String(100), default="Software Engineer")
    learning_goal = Column(String(100), default="interview_prep")  # interview_prep, daily_meetings, system_design, client_negotiation, general_fluency
    daily_goal_minutes = Column(Integer, default=20)
    total_xp = Column(Integer, default=0)
    streak_days = Column(Integer, default=0)
    pin_hash = Column(String(128), nullable=True)
    last_active_date = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=utc_now)

    @property
    def has_pin(self) -> bool:
        return bool(self.pin_hash)

    achievements = relationship("UserAchievement", back_populates="user", cascade="all, delete-orphan")
    daily_activities = relationship("UserDailyActivity", back_populates="user", cascade="all, delete-orphan")


class UserAchievement(Base):
    __tablename__ = "user_achievements"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(64), ForeignKey("user_profiles.id"), nullable=False, index=True)
    badge_key = Column(String(64), nullable=False, index=True)
    title = Column(String(100), nullable=False)
    description = Column(String(255), nullable=False)
    icon_name = Column(String(64), default="star")
    category = Column(String(50), default="general")
    unlocked_at = Column(DateTime, nullable=True)
    progress = Column(Float, default=0.0)  # 0.0 to 1.0
    is_unlocked = Column(Boolean, default=False)
    created_at = Column(DateTime, default=utc_now)

    user = relationship("UserProfile", back_populates="achievements")


class UserDailyActivity(Base):
    __tablename__ = "user_daily_activities"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(64), ForeignKey("user_profiles.id"), nullable=False, index=True)
    activity_date = Column(String(10), nullable=False, index=True)  # YYYY-MM-DD
    xp_earned = Column(Integer, default=0)
    minutes_spent = Column(Integer, default=0)
    sessions_count = Column(Integer, default=0)
    words_practiced = Column(Integer, default=0)
    grammar_drills_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=utc_now)

    user = relationship("UserProfile", back_populates="daily_activities")


class ContentItem(Base):
    """
    Unified Content Item in the robust pipeline.
    States: raw -> normalized -> reviewed -> published (or rejected)
    """
    __tablename__ = "content_items"

    id = Column(String(64), primary_key=True, index=True)
    content_type = Column(String(30), nullable=False, index=True)  # interview_question, vocabulary_term, grammar_unit, shadowing_phrase
    status = Column(String(20), default="normalized", index=True)  # raw, normalized, reviewed, published, rejected
    
    # Pedagogical attributes
    cefr = Column(String(10), nullable=True, index=True)  # A1, A2, B1, B2, C1, C2
    scenario = Column(String(50), nullable=True, index=True)  # system_design, hr, backend_arch, etc.
    objective = Column(String(255), nullable=True)
    difficulty = Column(String(20), default="mid")  # junior, mid, senior, all
    source_type = Column(String(30), default="interview")  # interview, vocabulary, grammar, shadowing

    # Main payload (JSON string)
    payload_json = Column(Text, nullable=False)

    # Provenance & Licensing
    source_origin = Column(String(30), default="generated")  # original, generated, referenced
    source_url = Column(String(500), nullable=True)
    license = Column(String(30), default="own")  # own, reference_only
    imported_at = Column(DateTime, default=utc_now)
    reviewed_by = Column(String(64), nullable=True)
    review_notes = Column(Text, nullable=True)
    reviewed_at = Column(DateTime, nullable=True)

    # Versioning
    snapshot_version = Column(String(20), nullable=True, index=True)
    created_at = Column(DateTime, default=utc_now)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)


class ContentSnapshot(Base):
    """
    Versioned Snapshot of published content with SHA-256 manifest.
    """
    __tablename__ = "content_snapshots"

    id = Column(String(64), primary_key=True, index=True)
    version = Column(String(20), unique=True, nullable=False, index=True)  # v1.0.0, v1.1.0
    sha256_hash = Column(String(64), nullable=False)
    manifest_json = Column(Text, nullable=False)  # metadata, counts, hash
    snapshot_json = Column(Text, nullable=False)  # full payload array of published items
    item_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=utc_now)


class LlmInteractionLog(Base):
    """
    Registro completo de cada inferencia en el Worker GPU (Ollama).
    Sirve como base de datos de telemetría y bucle de auto-aprendizaje.

    Pipeline de mejora automática:
      - Fase 1: Filtra rows con user_feedback_score == 1 para Few-Shot dinámico.
      - Fase 2: Alimenta el dataset de curación para LoRA fine-tuning.
      - Fase 3: Permite detectar patrones de error frecuentes por error_tag.
    """
    __tablename__ = "llm_interaction_logs"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String(64), nullable=False, index=True)
    turn_id = Column(Integer, nullable=True)
    user_id = Column(String(64), default="default_user", index=True)
    created_at = Column(DateTime, default=utc_now)

    # ── Entrada del usuario ──────────────────────────────────────────
    user_transcript = Column(Text, nullable=False)
    detected_intent = Column(String(64), nullable=True)  # correction, vocabulary, grammar...

    # ── Contexto enviado al LLM ──────────────────────────────────────
    system_prompt_used = Column(Text, nullable=True)
    user_prompt_used = Column(Text, nullable=True)
    model_name = Column(String(64), nullable=False, default="lito-fast:latest")

    # ── Respuesta y métricas GPU ─────────────────────────────────────
    response_text = Column(Text, nullable=False)
    engine_used = Column(String(16), default="fast")  # "fast" (GPU) | "standard" (reglas)
    latency_ms = Column(Float, nullable=True)
    eval_count = Column(Integer, nullable=True)          # tokens generados
    eval_duration_sec = Column(Float, nullable=True)     # tiempo de generación
    tokens_per_second = Column(Float, nullable=True)     # eval_count / eval_duration_sec

    # ── Feedback del alumno (bucle de aprendizaje) ───────────────────
    user_feedback_score = Column(Integer, nullable=True)   # 1 (útil) | 0 (neutral) | -1 (confuso)
    user_repeated_prompt = Column(Boolean, default=False)
    error_tag = Column(String(64), nullable=True)          # grammar_tense, preposition, verb_do_make...
    notes = Column(Text, nullable=True)


class PronunciationAttempt(Base):
    """Intento de pronunciación evaluado (por usuario). Persistimos RESULTADO y
    METADATOS, nunca el audio crudo: solo un hash (repetibilidad/dedup) y la
    duración. Honesto: si falla STT/alignment NO se inventa nota."""
    __tablename__ = "pronunciation_attempts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(64), default="default_user", index=True)

    # Ejercicio
    term = Column(String(300), nullable=False)
    ipa = Column(String(300), nullable=True)
    category = Column(String(64), nullable=True, index=True)
    exercise_type = Column(String(20), default="single_word", index=True)  # single_word | short_phrase | guided_sentence

    # Señales de reconocimiento
    recognized = Column(Text, nullable=True)        # texto (STT) o /IPA/ oída
    target_ipa = Column(Text, nullable=True)
    heard_ipa = Column(Text, nullable=True)
    wrong_phonemes = Column(Text, nullable=True)    # coma-separado

    # Puntuaciones
    score = Column(Integer, default=0)
    text_score = Column(Integer, default=0)
    phonetic_score = Column(Integer, default=0)
    is_match = Column(Boolean, default=False)
    confidence = Column(Float, default=0.0)         # 0..1 fiabilidad de la medición

    # Trazabilidad / honestidad
    engine_used = Column(String(24), default="standard")          # wav2vec2-gpu | allosaurus-cpu | standard | unavailable
    processing_stage_failed = Column(String(24), nullable=True)   # stt | g2p | alignment | all | None
    audio_hash = Column(String(64), nullable=True)                # sha256 del audio (no guardamos el audio)
    audio_ms = Column(Integer, nullable=True)

    created_at = Column(DateTime, default=utc_now, index=True)


class PronunciationTermStats(Base):
    """Agregado por (usuario, término) para progreso y selección adaptativa.
    Se actualiza (upsert) en cada intento."""
    __tablename__ = "pronunciation_term_stats"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(64), index=True, nullable=False)
    term = Column(String(300), index=True, nullable=False)
    category = Column(String(64), nullable=True, index=True)
    exercise_type = Column(String(20), default="single_word")

    attempts = Column(Integer, default=0)
    best_score = Column(Integer, default=0)
    last_score = Column(Integer, default=0)
    avg_score = Column(Float, default=0.0)
    mastered = Column(Boolean, default=False)       # best>=85 y attempts>=2
    last_attempt_at = Column(DateTime, default=utc_now, index=True)


class ClientLog(Base):
    """Errores/eventos enviados por el cliente movil para depuracion remota."""
    __tablename__ = "client_logs"
    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime, default=utc_now, index=True)
    user_id = Column(String(64), default="anon", index=True)
    level = Column(String(16), default="error", index=True)
    tag = Column(String(64), nullable=True, index=True)
    message = Column(Text, nullable=False)
    context = Column(Text, nullable=True)
    platform = Column(String(32), nullable=True)
    app_version = Column(String(32), nullable=True)


class UserPhonemeProgress(Base):
    """Seguimiento fonético continuo por fonema y usuario.
    Calcula GOP continuo, Wilson Lower Bound 95%, decaimiento temporal y matriz de confusión direccional."""
    __tablename__ = "user_phoneme_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(64), index=True, nullable=False)
    phoneme = Column(String(16), index=True, nullable=False)  # ej. "TH_V", "IH", "AE", "V"

    attempts = Column(Integer, default=0)
    successes = Column(Integer, default=0)
    mean_gop = Column(Float, default=0.0)
    last_gop = Column(Float, default=0.0)
    recency_weighted_gop = Column(Float, default=0.0)
    wilson_lower_bound = Column(Float, default=0.0)

    confusion_map = Column(Text, default="{}")  # JSON: {"s": 4, "t": 1}
    last_practiced_at = Column(DateTime, default=utc_now, index=True)


class UserAudioBaseline(Base):
    """Guarda la pista de audio de referencia inicial (Día 1) y la última producida (Hoy) para comparación directa."""
    __tablename__ = "user_audio_baselines"

    id = Column(String(128), primary_key=True, index=True)  # f"{user_id}:{target_type}:{target_id}"
    user_id = Column(String(64), index=True, nullable=False)
    target_type = Column(String(20), default="word")  # word, sentence, probe
    target_id = Column(String(128), index=True, nullable=False)

    baseline_audio_path = Column(String(255), nullable=True)
    baseline_score = Column(Float, default=0.0)
    baseline_gop = Column(Float, default=0.0)
    baseline_created_at = Column(DateTime, default=utc_now)

    latest_audio_path = Column(String(255), nullable=True)
    latest_score = Column(Float, nullable=True)
    latest_gop = Column(Float, nullable=True)
    latest_updated_at = Column(DateTime, nullable=True)


class UserVoiceMeasurement(Base):
    """Historial generico y extensible de medidas de voz en cualquier zona.
    Una metrica nueva = un metric_key nuevo (sin cambiar el esquema); datos extra en extra_json."""
    __tablename__ = "user_voice_measurements"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(64), index=True, nullable=False)
    zone = Column(String(32), index=True, nullable=False)
    target_type = Column(String(32), default="word")
    target_id = Column(String(160), index=True, nullable=False)
    metric_key = Column(String(48), index=True, nullable=False)
    value = Column(Float, default=0.0)
    audio_path = Column(String(255), nullable=True)
    extra_json = Column(Text, nullable=True)
    created_at = Column(DateTime, default=utc_now, index=True)


class UserVoiceBaseline(Base):
    """Snapshot por (usuario, zona, target, metrica): Dia 1 (baseline), ultimo (hoy) y mejor marca."""
    __tablename__ = "user_voice_baselines"

    id = Column(String(200), primary_key=True, index=True)  # f"{user}:{zone}:{target_id}:{metric_key}"
    user_id = Column(String(64), index=True, nullable=False)
    zone = Column(String(32), index=True, nullable=False)
    target_type = Column(String(32), default="word")
    target_id = Column(String(160), index=True, nullable=False)
    metric_key = Column(String(48), index=True, nullable=False)

    baseline_value = Column(Float, default=0.0)
    baseline_audio_path = Column(String(255), nullable=True)
    baseline_created_at = Column(DateTime, default=utc_now)

    latest_value = Column(Float, nullable=True)
    latest_audio_path = Column(String(255), nullable=True)
    latest_updated_at = Column(DateTime, nullable=True)

    best_value = Column(Float, nullable=True)
    best_audio_path = Column(String(255), nullable=True)
    best_updated_at = Column(DateTime, nullable=True)

    attempts = Column(Integer, default=0)
    extra_json = Column(Text, nullable=True)
    label = Column(String(160), nullable=True)
