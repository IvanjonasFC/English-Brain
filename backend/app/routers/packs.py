from fastapi import APIRouter
from typing import List, Dict, Any, Optional
import os
import json

router = APIRouter(
    prefix="/packs",
    tags=["Packs"],
)

# Single source of truth for structured content lives in app/seed/*.json.
# The Flutter app fetches these endpoints and bundles a byte-identical copy of
# each seed as an offline asset (kept in sync by tools/sync_offline_seeds.py),
# so every content tab stays offline-first.
_SEED_DIR = os.path.join(os.path.dirname(__file__), "..", "seed")


def load_seed_json(filename: str) -> List[Dict[str, Any]]:
    """Load a seed file as a list. Accepts either a bare JSON list or a
    ``{"version": ..., "items": [...]}`` wrapper (comprehension uses the
    wrapper); always returns the item list."""
    seed_path = os.path.join(_SEED_DIR, filename)
    try:
        with open(seed_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except FileNotFoundError:
        return []
    if isinstance(data, dict):
        items = data.get("items", [])
        return items if isinstance(items, list) else []
    return data if isinstance(data, list) else []


@router.get("/interview", response_model=List[Dict[str, Any]])
def get_interview_packs(domain: Optional[str] = None):
    """Structured speaking/interview packs (seed/interview.json).

    Optional ``domain`` filters by tab ("general" | "tech"). Omitting it
    returns every pack (each carrying its own ``domain``) so the app can filter
    locally.
    """
    packs = load_seed_json("interview.json")
    if domain in ("general", "tech"):
        return [p for p in packs if p.get("domain") == domain]
    return packs


@router.get("/vocabulary", response_model=List[Dict[str, Any]])
def get_vocabulary_packs():
    """Vocabulary packs (seed/vocab.json)."""
    return load_seed_json("vocab.json")


@router.get("/grammar", response_model=List[Dict[str, Any]])
def get_grammar_units():
    """Grammar units (seed/grammar.json)."""
    return load_seed_json("grammar.json")
