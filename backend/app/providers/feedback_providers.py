"""Feedback providers: Ollama LLM (GPU worker) and rule-based NAS fallback."""
import logging
from typing import List, Dict

from app.schemas import LLMEvaluationResult, PronunciationFeedback
from app.services.llm import llm_service
from .base import FeedbackProvider, ENGINE_FAST, ENGINE_STANDARD

logger = logging.getLogger("english_brain.providers.feedback")

_FILLERS = ["um", "uh", "erm", "like", "you know", "kind of", "sort of", "eh", "este"]


class OllamaFeedbackProvider(FeedbackProvider):
    """Rich feedback from a local LLM (Phi-4 Mini / Qwen 3 4B) on the GPU laptop."""
    engine = ENGINE_FAST

    async def evaluate(self, question_text, user_transcript, conversation_history):
        return await llm_service.evaluate_turn(
            question_text=question_text,
            user_transcript=user_transcript,
            conversation_history=conversation_history,
        )


class RuleBasedFeedbackProvider(FeedbackProvider):
    """Deterministic feedback when no GPU/LLM is available. No external calls."""
    engine = ENGINE_STANDARD

    async def evaluate(self, question_text, user_transcript, conversation_history):
        text = (user_transcript or "").lower()
        words = len((user_transcript or "").split())
        fillers = [f for f in _FILLERS if f in text]

        score = 7
        if words < 15:
            score = 5
        elif words > 40:
            score = 8
        if fillers:
            score = max(4, score - 1)

        note = (
            "Standard mode (GPU accelerator offline): basic feedback only. "
            "Aim for 2-4 clear sentences with a concrete result (STAR)."
        )
        if words < 15:
            note += " Your answer was short — add more detail."
        if fillers:
            note += f" Filler words detected: {', '.join(fillers)}."

        return LLMEvaluationResult(
            interviewer_reply=(
                "Thanks. Can you give a specific example, including the result you achieved?"
            ),
            grammar_corrections=[],
            vocabulary_suggestions=[],
            overall_score=score,
            fluency_feedback=note,
            pronunciation_feedback=PronunciationFeedback(
                score=80,
                clarity="Good",
                mispronounced_or_difficult_words=[],
                phonetic_tips=[],
                filler_words_detected=fillers,
            ),
        )
