from fastapi import APIRouter
from typing import List, Dict, Any, Optional
import os
import json

router = APIRouter(
    prefix="/comprehension",
    tags=["Comprehension"],
)

# Reading & Listening pieces served to the Flutter app. Content lives in
# app/seed/comprehension_seed.json so it can be edited/expanded without code
# changes (the professional edit surface for volume). The app fetches this and
# falls back to its bundled Dart seed when the backend is unreachable, keeping
# the tab offline-first.
#   - domain: "general" | "tech"  -> the two segments in the Comprehension hub
#   - band:   "A1-A2" | "B1" | "B2" | "B2-C1" | "C1"
#   - each piece carries body (EN), bodyEs (ES translation) and questions
#     (mcq + spoken with keywords/modelAnswer).
_SEED_PATH = os.path.join(os.path.dirname(__file__), "..", "seed", "comprehension_seed.json")


def _load_items() -> List[Dict[str, Any]]:
    try:
        with open(_SEED_PATH, encoding="utf-8") as f:
            data = json.load(f)
        items = data.get("items", []) if isinstance(data, dict) else data
        return items if isinstance(items, list) else []
    except Exception:
        return []


@router.get("", response_model=List[Dict[str, Any]])
def get_comprehension(domain: Optional[str] = None, band: Optional[str] = None):
    """All comprehension pieces, optionally filtered by domain and/or band.

    Omitting the filters returns every piece (each carrying its own domain and
    band), so the app can filter locally as it already does for packs.
    """
    items = _load_items()
    if domain in ("general", "tech"):
        items = [p for p in items if p.get("domain") == domain]
    if band:
        items = [p for p in items if p.get("band") == band]
    return items
