"""Provider abstractions for the hybrid architecture.

The NAS is the always-on core; an optional GPU laptop (RTX 2060) accelerates
STT and LLM feedback. Every request goes through a provider so the system
degrades gracefully to CPU/rule-based when the accelerator is offline.
"""
from abc import ABC, abstractmethod
from typing import List, Dict

from app.schemas import LLMEvaluationResult

# Engine labels surfaced to the client (shown discreetly in the UI).
ENGINE_FAST = "fast"          # GPU worker (faster-whisper CUDA / Ollama)
ENGINE_STANDARD = "standard"  # NAS CPU fallback (whisper.cpp / rule-based)


class STTProvider(ABC):
    engine: str = ENGINE_STANDARD

    @abstractmethod
    async def transcribe(self, audio_bytes: bytes, filename: str = "answer.m4a") -> str:
        ...


class FeedbackProvider(ABC):
    engine: str = ENGINE_STANDARD

    @abstractmethod
    async def evaluate(
        self,
        question_text: str,
        user_transcript: str,
        conversation_history: List[Dict[str, str]],
    ) -> LLMEvaluationResult:
        ...
