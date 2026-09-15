"""Routes STT and feedback to the GPU worker when available, else to the
NAS fallback. Wraps calls so a failing accelerator degrades gracefully."""
import logging
from typing import List, Dict, Tuple

from app.schemas import LLMEvaluationResult
from app.services.worker_health import worker_health
from .base import ENGINE_FAST, ENGINE_STANDARD
from .stt_providers import GpuWhisperProvider, LocalCpuWhisperProvider
from .feedback_providers import OllamaFeedbackProvider, RuleBasedFeedbackProvider

logger = logging.getLogger("english_brain.providers.router")


class ProviderRouter:
    def __init__(self):
        self._gpu_stt = GpuWhisperProvider()
        self._local_stt = LocalCpuWhisperProvider()
        self._ollama_fb = OllamaFeedbackProvider()
        self._rule_fb = RuleBasedFeedbackProvider()

    async def transcribe(self, audio_bytes: bytes, filename: str = "answer.m4a") -> Tuple[str, str]:
        if await worker_health.stt_online():
            try:
                text = await self._gpu_stt.transcribe(audio_bytes, filename)
                return text, ENGINE_FAST
            except Exception as exc:  # noqa: BLE001
                logger.warning("GPU STT failed, falling back to NAS: %s", exc)
        text = await self._local_stt.transcribe(audio_bytes, filename)
        return text, ENGINE_STANDARD

    async def evaluate(
        self,
        question_text: str,
        user_transcript: str,
        conversation_history: List[Dict[str, str]],
    ) -> Tuple[LLMEvaluationResult, str]:
        if await worker_health.llm_online():
            try:
                result = await self._ollama_fb.evaluate(
                    question_text, user_transcript, conversation_history
                )
                return result, ENGINE_FAST
            except Exception as exc:  # noqa: BLE001
                logger.warning("GPU LLM failed, falling back to rule-based: %s", exc)
        result = await self._rule_fb.evaluate(
            question_text, user_transcript, conversation_history
        )
        return result, ENGINE_STANDARD


provider_router = ProviderRouter()
