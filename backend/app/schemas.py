from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict

# ==============================================================================
# LLM Strict Contract Schemas (Sacred Contract)
# ==============================================================================

class GrammarCorrection(BaseModel):
    original: str = Field(..., description="The user's original phrase with errors")
    correction: str = Field(..., description="The grammatically correct version")
    explanation: str = Field(..., description="Clear explanation of the grammar rule")

class VocabularySuggestion(BaseModel):
    term: str = Field(..., description="The word or idiom to learn or improve")
    context: str = Field(..., description="Example sentence or context of usage")
    alternatives: List[str] = Field(default_factory=list, description="Natural synonyms or better tech terms")

class PronunciationFeedback(BaseModel):
    score: int = Field(default=85, ge=0, le=100, description="Pronunciation clarity score 0-100")
    clarity: str = Field(default="Good", description="Rating: Excellent, Good, Moderate, Needs Practice")
    mispronounced_or_difficult_words: List[str] = Field(
        default_factory=list,
        description="Technical words with complex phonetics detected in answer"
    )
    phonetic_tips: List[str] = Field(
        default_factory=list,
        description="IPA phonetic guides and tips for difficult words"
    )
    filler_words_detected: List[str] = Field(
        default_factory=list,
        description="Filler words detected (um, uh, like, you know)"
    )

class LLMEvaluationResult(BaseModel):
    interviewer_reply: str = Field(
        ..., 
        description="Natural follow-up response or question in English by the interviewer"
    )
    grammar_corrections: List[GrammarCorrection] = Field(
        default_factory=list,
        description="List of grammatical errors identified in the user's response"
    )
    vocabulary_suggestions: List[VocabularySuggestion] = Field(
        default_factory=list,
        description="List of vocabulary enrichments and natural expressions"
    )
    overall_score: int = Field(
        ..., 
        ge=0, 
        le=10, 
        description="Performance score 0-10 (0 = no evaluado: STT/LLM no disponible)"
    )
    fluency_feedback: str = Field(
        ..., 
        description="Constructive note on fluency, pacing, and professional clarity"
    )
    pronunciation_feedback: Optional[PronunciationFeedback] = Field(
        default=None,
        description="Pronunciation clarity, tricky phonetics, and speech tips"
    )


# ==============================================================================
# API Endpoints Request / Response Schemas
# ==============================================================================

class QuestionOut(BaseModel):
    id: int
    category: str
    difficulty: str
    title: str
    text: str
    model_answer: Optional[str] = None
    tips: Optional[str] = None
    track: Optional[str] = None
    scenario: Optional[str] = None
    objective_id: Optional[str] = None
    difficulty_band: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

class SessionCreate(BaseModel):
    category: Optional[str] = "tech"
    initial_question_id: Optional[int] = None

class SessionOut(BaseModel):
    id: str
    user_id: str
    started_at: datetime
    completed_at: Optional[datetime] = None
    status: str
    initial_question: Optional[QuestionOut] = None
    initial_audio_url: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

class TurnOut(BaseModel):
    id: int
    session_id: str
    question_id: Optional[int]
    transcript: str
    ai_reply_text: str
    ai_reply_audio_url: Optional[str]
    evaluation: LLMEvaluationResult
    engine_used: Optional[str] = None  # "fast" (GPU), "standard" (CPU) or "hybrid"
    created_at: datetime

class MistakeOut(BaseModel):
    id: int
    turn_id: int
    category: str
    original: str
    correction: str
    explanation: str
    timestamp: datetime

    model_config = ConfigDict(from_attributes=True)

# ==============================================================================
# FSRS Flashcard Schemas
# ==============================================================================

class CardOut(BaseModel):
    id: int
    mistake_id: Optional[int] = None
    front: str
    back: str
    state: int  # 0=New, 1=Learning, 2=Review, 3=Relearning
    difficulty: float
    stability: float
    due_date: datetime
    last_review: Optional[datetime] = None
    reps: int
    lapses: int
    user_id: Optional[str] = None
    source_type: Optional[str] = "interview_mistake"
    item_type: Optional[str] = "sentence_correction"
    unit_id: Optional[str] = None
    skill: Optional[str] = "speaking"

    model_config = ConfigDict(from_attributes=True)

class CardReviewIn(BaseModel):
    rating: int = Field(..., ge=1, le=4, description="1=Again, 2=Hard, 3=Good, 4=Easy (FSRS Ratings)")

class CardIngestIn(BaseModel):
    front: str
    back: str
    source_type: str = "vocabulary"       # vocabulary, grammar, listening, interview_mistake
    item_type: str = "word_meaning"       # word_meaning, sentence_correction, audio_recognition, irregular_verb_form, interview_opener, phrase_completion
    unit_or_pack_id: Optional[str] = None
    skill: str = "vocabulary"

# ==============================================================================
# Stats & Auth Schemas
# ==============================================================================

class StatsOut(BaseModel):
    total_sessions: int
    total_turns: int
    total_mistakes: int
    cards_due_today: int
    total_cards: int
    streak_days: int
    mistakes_by_category: dict[str, int]
    weekly_activity: List[dict]

class WeeklyReportOut(BaseModel):
    week_range: str
    generated_at: datetime
    total_sessions: int
    total_turns: int
    total_mistakes: int
    mistakes_this_week: int = 0
    mistakes_last_week: int = 0
    markdown_report: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class LoginIn(BaseModel):
    api_key: str
    user_id: str | None = None

class WorkerRegisterIn(BaseModel):
    url: str
    models: Optional[List[str]] = None

# ==============================================================================
# Multi-User Profile & Analytics Schemas
# ==============================================================================

class UserProfileOut(BaseModel):
    id: str
    display_name: str
    email: Optional[str] = None
    avatar_url: Optional[str] = None
    target_level: str = "B2"
    role_title: str = "Software Engineer"
    learning_goal: str = "interview_prep"
    daily_goal_minutes: int = 20
    total_xp: int = 0
    streak_days: int = 0
    has_pin: bool = False
    last_active_date: Optional[datetime] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class UserProfileIn(BaseModel):
    id: Optional[str] = None
    display_name: str
    avatar_url: Optional[str] = None
    target_level: str = "B2"
    role_title: str = "Software Engineer"
    learning_goal: str = "interview_prep"
    daily_goal_minutes: int = 20
    pin: Optional[str] = None

class SkillScoresOut(BaseModel):
    grammar_score: int = 80
    vocabulary_score: int = 75
    listening_score: int = 85
    speaking_score: int = 78
    grammar_level: str = "B2"
    vocabulary_level: str = "B2"
    listening_level: str = "C1"
    speaking_level: str = "B2"

class AchievementOut(BaseModel):
    id: int
    badge_key: str
    title: str
    description: str
    icon_name: str
    category: str
    unlocked_at: Optional[datetime] = None
    progress: float = 0.0
    is_unlocked: bool = False

    model_config = ConfigDict(from_attributes=True)

class DailyActivityOut(BaseModel):
    date: str  # YYYY-MM-DD
    xp_earned: int = 0
    minutes_spent: int = 0
    sessions_count: int = 0
    words_practiced: int = 0
    grammar_drills_count: int = 0

class ProfileSummaryOut(BaseModel):
    profile: UserProfileOut
    total_xp: int
    weekly_xp: int
    streak_days: int
    total_minutes: int
    total_sessions: int
    completed_units: int
    mastered_words: int
    speaking_clarity_score: int
    listening_score: int
    skills: SkillScoresOut
    achievements: List[AchievementOut]
    activity_30d: List[DailyActivityOut]
    weekly_activity: List[dict]
    sync_status: str = "synced"
