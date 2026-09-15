"""
Backend i18n module using Babel/gettext.
Translations are loaded once at startup and reused per request.
Usage:
    from app.i18n import gettext, get_locale
    lang = get_locale(request)
    msg = gettext("auth.invalid_credentials", lang=lang)
"""
import os
import logging
from babel.support import Translations

logger = logging.getLogger("english_brain.i18n")

_translations: dict = {}
_locale_dir = os.path.join(os.path.dirname(__file__), "locales")


def load_translations() -> None:
    """Load all translations into memory. Call once at startup."""
    global _translations
    for lang in ["es", "en"]:
        try:
            t = Translations.load(_locale_dir, [lang], domain="messages")
            _translations[lang] = t
            logger.info(f"Loaded translations for: {lang}")
        except Exception as exc:
            logger.warning(f"Could not load translations for {lang}: {exc}")
            _translations[lang] = None


def get_locale(request) -> str:
    """Resolve language from Accept-Language header or fallback to 'es'."""
    accept = request.headers.get("Accept-Language", "es")
    # Parse first preference: 'es-ES,es;q=0.9,en;q=0.8' -> 'es'
    lang = accept.split(",")[0].split(";")[0].split("-")[0].strip().lower()
    return lang if lang in _translations else "es"


def gettext(msg_id: str, lang: str = "es") -> str:
    """
    Translate a message ID into the target language.
    Falls back to English, then returns the raw ID if all else fails.
    """
    t = _translations.get(lang)
    if t is not None:
        translated = t.gettext(msg_id)
        if translated != msg_id:
            return translated
    # Fallback to English
    t_en = _translations.get("en")
    if t_en is not None:
        translated_en = t_en.gettext(msg_id)
        if translated_en != msg_id:
            return translated_en
    # Last resort: return the message ID itself
    return msg_id


# Convenient alias
_ = gettext
