from typing import List, Dict, Any, Optional
from dataclasses import dataclass, field


VALID_CEFR_LEVELS = {"A1", "A2", "B1", "B2", "C1", "C2"}
VALID_CEFR_BANDS = {"A1", "A2", "B1", "B2", "C1", "C2", "A1-A2", "A2-B1", "B1-B2", "B2-C1"}

CEFR_ORDER = {
    "A1": 1,
    "A2": 2,
    "B1": 3,
    "B2": 4,
    "C1": 5,
    "C2": 6,
}


@dataclass
class ValidationResult:
    is_valid: bool
    errors: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)


class ContentValidator:
    """
    Pedagogical & License Consistency Validator for English Brain Content Pipeline.
    """

    @staticmethod
    def validate_cefr(cefr: Optional[str], strict: bool = True) -> ValidationResult:
        if not cefr:
            if strict:
                return ValidationResult(is_valid=False, errors=["CEFR level is required for review approval."])
            return ValidationResult(is_valid=True, warnings=["CEFR level is missing in draft."])

        cefr_clean = cefr.strip().upper()
        if cefr_clean not in VALID_CEFR_BANDS and cefr_clean not in VALID_CEFR_LEVELS:
            return ValidationResult(
                is_valid=False,
                errors=[f"Invalid CEFR level '{cefr}'. Must be one of: {sorted(VALID_CEFR_BANDS)}"],
            )

        return ValidationResult(is_valid=True)

    @staticmethod
    def validate_license(license_str: Optional[str], payload: Dict[str, Any], source_url: Optional[str]) -> ValidationResult:
        """
        Licensing rule:
        - license == 'own': Full content ownership permitted.
        - license != 'own' (e.g. 'bbc', 'cambridge', 'british_council', 'referenced'):
          CANNOT contain copied copyrighted text. Must be reference-only with a valid source_url.
        """
        lic = (license_str or "own").strip().lower()

        if lic not in {"own", "reference_only", "creative_commons", "fair_use_reference"}:
            return ValidationResult(
                is_valid=False,
                errors=[f"Unrecognized license '{license_str}'. Must be 'own' or 'reference_only'."],
            )

        if lic != "own":
            if not source_url:
                return ValidationResult(
                    is_valid=False,
                    errors=["Non-own material must provide a valid 'sourceUrl' reference."],
                )
            # Check for excessive text length on non-own content (copyright prevention)
            text_len = len(str(payload.get("text") or payload.get("prompt") or payload.get("model_answer") or ""))
            if text_len > 350:
                return ValidationResult(
                    is_valid=False,
                    errors=[
                        "Non-own material contains extensive embedded text (>350 chars). "
                        "To respect licensing, store only reference metadata/links, not scraped content."
                    ],
                )

        return ValidationResult(is_valid=True)

    @staticmethod
    def audit_pack_consistency(items: List[Dict[str, Any]]) -> List[str]:
        """
        Consistency Auditor:
        Detects if a pack or track mixes widely disparate CEFR levels (e.g. A1 with C1)
        without pedagogical scaffolding.
        """
        warnings = []
        by_pack: Dict[str, List[str]] = {}

        for item in items:
            pack_key = item.get("scenario") or item.get("category") or "default"
            cefr = item.get("cefr")
            if cefr:
                # Normalize band like A2-B1 -> pick highest for ranking
                parts = cefr.upper().split("-")
                base_level = parts[-1].strip()
                if base_level in CEFR_ORDER:
                    by_pack.setdefault(pack_key, []).append(base_level)

        for pack_name, levels in by_pack.items():
            if len(levels) > 1:
                ranks = [CEFR_ORDER[lvl] for lvl in levels]
                min_rank = min(ranks)
                max_rank = max(ranks)
                # If disparity is 3 or more (e.g. A1 [1] and B2 [4], or A2 [2] and C1 [5])
                if max_rank - min_rank >= 3:
                    min_lvl = [k for k, v in CEFR_ORDER.items() if v == min_rank][0]
                    max_lvl = [k for k, v in CEFR_ORDER.items() if v == max_rank][0]
                    warnings.append(
                        f"Disparate CEFR gap in scenario '{pack_name}': mixes {min_lvl} and {max_lvl}. "
                        f"Consider splitting into separate Junior and Senior tracks."
                    )

        return warnings
