"""
Servicio de Memoria Progresiva del Alumno (Vectorial / Embeddings con nomic-embed-text).

Permite almacenar y recuperar debilidades pedagógicas (fonemas que se le atragantan,
patrones gramaticales recurrentes, lagunas de vocabulario) mediante búsqueda semántica
rápida (<20ms). 

Evita reenviar historiales masivos al LLM, reduciendo la ventana de contexto y
acelerando la inferencia en la GPU RTX 2060.
"""
import os
import json
import time
import math
import logging
import asyncio
from typing import List, Dict, Any, Optional
import httpx

from app.config import settings

logger = logging.getLogger("english_brain.memory")

_EMBED_CACHE: Dict[str, List[float]] = {}


def _cosine_similarity(v1: List[float], v2: List[float]) -> float:
    if not v1 or not v2 or len(v1) != len(v2):
        return 0.0
    dot = sum(a * b for a, b in zip(v1, v2))
    norm1 = math.sqrt(sum(a * a for a in v1))
    norm2 = math.sqrt(sum(b * b for b in v2))
    if norm1 == 0.0 or norm2 == 0.0:
        return 0.0
    return dot / (norm1 * norm2)


class ProgressiveMemoryService:
    def __init__(self, ollama_url: Optional[str] = None, model: str = "nomic-embed-text"):
        self.ollama_url = (ollama_url or settings.OLLAMA_URL).rstrip("/")
        self.model = model
        self._client = httpx.AsyncClient(timeout=httpx.Timeout(5.0, connect=1.5))
        self._memory_dir = os.path.join(settings.AUDIO_CACHE_DIR, "student_memory")
        os.makedirs(self._memory_dir, exist_ok=True)

    async def get_embedding(self, text: str) -> Optional[List[float]]:
        """Genera el vector de embedding usando nomic-embed-text en Ollama."""
        text_clean = text.strip()
        if not text_clean:
            return None
        if text_clean in _EMBED_CACHE:
            return _EMBED_CACHE[text_clean]

        try:
            url = f"{self.ollama_url}/api/embeddings"
            resp = await self._client.post(
                url,
                json={"model": self.model, "prompt": text_clean}
            )
            if resp.status_code == 200:
                vec = resp.json().get("embedding")
                if vec and isinstance(vec, list):
                    if len(_EMBED_CACHE) < 5000:
                        _EMBED_CACHE[text_clean] = vec
                    return vec
        except Exception as e:
            logger.debug(f"Ollama embedding ({self.model}) no disponible: {e}")
        
        return None

    def _get_user_file(self, user_id: str) -> str:
        clean_id = "".join(c for c in user_id if c.isalnum() or c in ("-", "_")) or "default_user"
        return os.path.join(self._memory_dir, f"{clean_id}.json")

    def _load_user_memories(self, user_id: str) -> List[Dict[str, Any]]:
        path = self._get_user_file(user_id)
        if not os.path.exists(path):
            return []
        try:
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning(f"Error leyendo memoria de alumno {user_id}: {e}")
            return []

    def _save_user_memories(self, user_id: str, items: List[Dict[str, Any]]):
        path = self._get_user_file(user_id)
        try:
            with open(path, "w", encoding="utf-8") as f:
                json.dump(items, f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.warning(f"Error guardando memoria de alumno {user_id}: {e}")

    async def record_weakness(
        self,
        user_id: str,
        flaw_type: str,
        text: str,
        details: Optional[str] = None,
        weight: float = 1.0
    ):
        """Registra una debilidad o patrón de error en segundo plano (asíncrono)."""
        if not user_id or not text:
            return
        
        embedding = await self.get_embedding(f"{flaw_type}: {text}. {details or ''}")
        memories = self._load_user_memories(user_id)
        
        # Si ya existe un registro similar, actualizamos peso y timestamp
        now = time.time()
        for m in memories:
            if m.get("flaw_type") == flaw_type and m.get("text", "").lower() == text.lower():
                m["weight"] = round(m.get("weight", 1.0) + weight, 2)
                m["updated_at"] = now
                m["occurrences"] = m.get("occurrences", 1) + 1
                if details:
                    m["details"] = details
                if embedding and not m.get("embedding"):
                    m["embedding"] = embedding
                self._save_user_memories(user_id, memories)
                return

        # Registro nuevo
        item = {
            "id": f"mem_{int(now*1000)}",
            "flaw_type": flaw_type, # 'phoneme_flaw' | 'grammar_error' | 'vocab_gap' | 'fluency_hesitation'
            "text": text,
            "details": details or "",
            "weight": weight,
            "occurrences": 1,
            "created_at": now,
            "updated_at": now,
            "embedding": embedding
        }
        memories.append(item)
        if len(memories) > 200:
            # Poda de memorias antiguas con bajo peso
            memories.sort(key=lambda x: (x.get("weight", 1.0), x.get("updated_at", 0)), reverse=True)
            memories = memories[:200]
        self._save_user_memories(user_id, memories)

    async def find_relevant_weaknesses(
        self,
        user_id: str,
        query: str,
        top_k: int = 3,
        min_similarity: float = 0.45
    ) -> List[Dict[str, Any]]:
        """Recupera en <20ms las debilidades más relevantes para el contexto o pregunta actual."""
        memories = self._load_user_memories(user_id)
        if not memories:
            return []

        query_vec = await self.get_embedding(query)
        scored = []

        for m in memories:
            vec = m.get("embedding")
            if query_vec and vec:
                sim = _cosine_similarity(query_vec, vec)
            else:
                # Fallback por coincidencia léxica / palabras clave si no hay vector
                q_words = set(query.lower().split())
                m_words = set(m.get("text", "").lower().split())
                overlap = len(q_words & m_words)
                sim = 0.5 if overlap > 0 else 0.1
            
            if sim >= min_similarity:
                scored.append((sim, m))

        scored.sort(key=lambda x: x[0], reverse=True)
        return [
            {
                "flaw_type": item["flaw_type"],
                "text": item["text"],
                "details": item.get("details", ""),
                "similarity": round(score, 3),
                "occurrences": item.get("occurrences", 1),
            }
            for score, item in scored[:top_k]
        ]


memory_service = ProgressiveMemoryService()
