import os
import random
import tempfile
import httpx
from typing import List, Dict, Any
from app.config import settings

try:
    import genanki
    HAVE_GENANKI = True
except ImportError:
    HAVE_GENANKI = False

# Consistent IDs for the English Coach deck and model
MODEL_ID = 1607392319
DECK_ID = 2059400110

ANKI_CSS = """
.card {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  font-size: 19px;
  text-align: left;
  color: #1e293b;
  background-color: #f8fafc;
  padding: 24px;
  border-radius: 12px;
  line-height: 1.6;
}
.tag-badge {
  display: inline-block;
  padding: 4px 10px;
  background-color: #e2e8f0;
  color: #475569;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.mistake-box {
  background-color: #fee2e2;
  border-left: 4px solid #ef4444;
  padding: 12px 16px;
  margin: 12px 0;
  border-radius: 4px;
  color: #991b1b;
  font-weight: 500;
}
.correction-box {
  background-color: #dcfce7;
  border-left: 4px solid #22c55e;
  padding: 12px 16px;
  margin: 12px 0;
  border-radius: 4px;
  color: #166534;
  font-weight: 600;
}
.explanation-box {
  background-color: #eff6ff;
  border-left: 4px solid #3b82f6;
  padding: 12px 16px;
  margin-top: 14px;
  border-radius: 4px;
  color: #1e40af;
  font-size: 16px;
}
"""

class AnkiService:
    def __init__(self):
        self.anki_connect_url = settings.ANKI_CONNECT_URL

    def generate_apkg(self, cards_data: List[Dict[str, Any]]) -> str:
        """
        Creates an .apkg Anki deck file containing the provided cards.
        Returns the absolute filepath to the created temporary file.
        """
        if not HAVE_GENANKI:
            raise RuntimeError("genanki package is required to export Anki decks.")

        anki_model = genanki.Model(
            MODEL_ID,
            'English Coach Card Model',
            fields=[
                {'name': 'Front'},
                {'name': 'Back'},
                {'name': 'Category'}
            ],
            templates=[
                {
                    'name': 'Card 1',
                    'qfmt': '<div class="tag-badge">{{Category}}</div><div class="mistake-box">{{Front}}</div>',
                    'afmt': '{{FrontSide}}<hr id="answer"><div class="correction-box">{{Back}}</div>'
                },
            ],
            css=ANKI_CSS
        )

        deck = genanki.Deck(DECK_ID, 'English Coach - Interview Mistakes & Vocabulary')

        for c in cards_data:
            note = genanki.Note(
                model=anki_model,
                fields=[
                    c.get("front", ""),
                    c.get("back", ""),
                    c.get("category", "Grammar")
                ]
            )
            deck.add_note(note)

        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".apkg")
        genanki.Package(deck).write_to_file(temp_file.name)
        return temp_file.name

    async def sync_to_ankiconnect(self, cards_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Connects directly to local AnkiConnect (port 8765) if Anki Desktop is running.
        """
        results = {"success": 0, "failed": 0, "errors": []}
        
        notes = []
        for c in cards_data:
            notes.append({
                "deckName": "English Coach - Interview Mistakes",
                "modelName": "Basic",
                "fields": {
                    "Front": f"<strong>[{c.get('category', 'Error')}]</strong><br>{c.get('front', '')}",
                    "Back": c.get('back', '')
                },
                "options": {
                    "allowDuplicate": False
                },
                "tags": ["english_coach", c.get("category", "interview")]
            })

        payload = {
            "action": "addNotes",
            "version": 6,
            "params": {
                "notes": notes
            }
        }

        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.post(self.anki_connect_url, json=payload)
                if resp.status_code == 200:
                    data = resp.json()
                    note_ids = data.get("result", [])
                    results["success"] = sum(1 for nid in note_ids if nid is not None)
                    results["failed"] = sum(1 for nid in note_ids if nid is None)
                    return results
        except Exception as e:
            results["errors"].append(str(e))

        return results

anki_service = AnkiService()
