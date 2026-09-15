#!/usr/bin/env python3
"""Sync the app's offline fallback with the backend seeds (single source of truth).

Backend seed files in ``backend/app/seed`` are authoritative. This script:

  1. Validates each seed against the app's non-nullable JSON schema.
  2. Writes a byte-identical copy of each as a bundled Flutter asset under
     ``app/assets/seed`` (the offline fallback the providers parse with the
     exact same ``fromJson`` used for the live backend response).
  3. Regenerates the compiled-in ``ContentSeeds.interviewPacks`` Dart list from
     ``interview.json`` (between GENERATED sentinels) so the last-resort const
     can never drift behind the backend again.

Exits non-zero on any validation/drift problem (CI-friendly).

Usage:
    python tools/sync_offline_seeds.py            # validate + write assets + regen const
    python tools/sync_offline_seeds.py --check     # validate + report drift, write nothing
"""
from __future__ import annotations

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BACKEND_SEED = os.path.join(ROOT, "backend", "app", "seed")
APP_ASSET_SEED = os.path.join(ROOT, "app", "assets", "seed")
CONTENT_SEEDS_DART = os.path.join(ROOT, "app", "lib", "core", "pedagogy", "content_seeds.dart")

SEEDS = [
    {"src": "comprehension_seed.json", "dst": "comprehension.json", "schema": "comprehension"},
    {"src": "vocab.json",              "dst": "vocab.json",          "schema": "vocabulary"},
    {"src": "grammar.json",            "dst": "grammar.json",        "schema": "grammar"},
    {"src": "interview.json",          "dst": "interview.json",      "schema": "interview"},
]

_SCENARIOS = {"foundations", "dailyEnglish", "hrInterview", "technicalInterview",
              "debugging", "teamwork", "systemsDesign", "workplaceEnglish"}
_BANDS = {"a2b1", "b1b2", "b2c1", "c1"}
_MODES = {"guided", "checkpoint", "mock", "shadowing"}

SENT_START = "  // >>> GENERATED interviewPacks — do not edit by hand (tools/sync_offline_seeds.py)"
SENT_END = "  // <<< GENERATED interviewPacks"


def _load_items(path: str) -> list:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    items = data.get("items", []) if isinstance(data, dict) else data
    if not isinstance(items, list):
        raise ValueError(f"{os.path.basename(path)}: expected a list of items")
    return items


def _require(item: dict, keys: list, ctx: str, errors: list) -> None:
    for k in keys:
        if k not in item or item[k] is None:
            errors.append(f"{ctx}: missing required key '{k}'")


def validate(schema: str, items: list) -> list:
    errors: list = []
    if not items:
        return [f"[{schema}] seed is empty"]
    ids = [it.get("id") for it in items if isinstance(it, dict)]
    dupes = sorted({i for i in ids if ids.count(i) > 1})
    if dupes:
        errors.append(f"[{schema}] duplicate ids: {dupes}")
    for idx, it in enumerate(items):
        ctx = f"[{schema}] item #{idx} (id={it.get('id') if isinstance(it, dict) else '?'})"
        if not isinstance(it, dict):
            errors.append(f"{ctx}: not an object")
            continue
        if schema == "comprehension":
            _require(it, ["id"], ctx, errors)
            for qi, q in enumerate(it.get("questions", []) or []):
                if q.get("type") == "spoken" and not (q.get("keywords") or q.get("modelAnswer")):
                    errors.append(f"{ctx} q#{qi}: spoken question needs keywords or modelAnswer")
        elif schema == "vocabulary":
            _require(it, ["id", "title", "description", "iconCodePoint", "level",
                          "accentColorValue", "terms"], ctx, errors)
            if not isinstance(it.get("iconCodePoint"), int):
                errors.append(f"{ctx}: iconCodePoint must be int")
            if not isinstance(it.get("accentColorValue"), int):
                errors.append(f"{ctx}: accentColorValue must be int")
            for ti, t in enumerate(it.get("terms", []) or []):
                if not t.get("term"):
                    errors.append(f"{ctx} term#{ti}: missing 'term'")
        elif schema == "grammar":
            _require(it, ["id", "level", "title", "tag", "subtitle", "ruleSummary",
                          "comparisonExamples", "questions"], ctx, errors)
            for qi, q in enumerate(it.get("questions", []) or []):
                _require(q, ["id", "prompt", "options", "correctAnswer",
                             "spanishExplanation", "audioText"], f"{ctx} q#{qi}", errors)
                if not isinstance(q.get("id"), int):
                    errors.append(f"{ctx} q#{qi}: question id must be int")
        elif schema == "interview":
            _require(it, ["id", "scenario", "subtopic", "objectiveId", "band",
                          "mode", "domain"], ctx, errors)
            if it.get("scenario") not in _SCENARIOS:
                errors.append(f"{ctx}: unknown scenario '{it.get('scenario')}'")
            if it.get("band") not in _BANDS:
                errors.append(f"{ctx}: unknown band '{it.get('band')}'")
            if it.get("mode") not in _MODES:
                errors.append(f"{ctx}: unknown mode '{it.get('mode')}'")
            if it.get("domain") not in ("general", "tech"):
                errors.append(f"{ctx}: domain must be 'general' or 'tech'")
    return errors


def _dart_str(s) -> str:
    s = "" if s is None else str(s)
    s = s.replace("\\", "\\\\").replace("$", "\\$").replace("'", "\\'")
    return "'" + s + "'"


def _dart_str_list(xs) -> str:
    return "[" + ", ".join(_dart_str(x) for x in (xs or [])) + "]"


def _dart_int_list(xs) -> str:
    return "[" + ", ".join(str(int(x)) for x in (xs or [])) + "]"


def render_interview_const(packs: list) -> str:
    lines = [SENT_START, "  static const List<InterviewPack> interviewPacks = ["]
    for p in packs:
        lines += [
            "    InterviewPack(",
            f"      id: {_dart_str(p['id'])},",
            f"      scenario: LearningScenario.{p['scenario']},",
            f"      subtopic: {_dart_str(p['subtopic'])},",
            f"      objectiveId: {_dart_str(p['objectiveId'])},",
            f"      band: DifficultyBand.{p['band']},",
            f"      mode: PracticeMode.{p['mode']},",
            f"      questionIds: {_dart_int_list(p.get('questionIds'))},",
            f"      skills: {_dart_str_list(p.get('skills'))},",
            f"      estMinutes: {int(p.get('estMinutes', 8))},",
            f"      feedbackType: {_dart_str(p.get('feedbackType', ''))},",
            f"      domain: {_dart_str(p.get('domain', 'tech'))},",
            "    ),",
        ]
    lines += ["  ];", SENT_END]
    return "\n".join(lines)


def current_const_ids(dart: str) -> list:
    """Extract the ids currently declared in the interviewPacks region."""
    if SENT_START in dart and SENT_END in dart:
        block = dart[dart.index(SENT_START):dart.index(SENT_END)]
    else:
        m = re.search(r"static const List<InterviewPack> interviewPacks = \[(.*?)\n  \];",
                      dart, re.S)
        block = m.group(1) if m else ""
    return re.findall(r"id:\s*'([^']+)'", block)


def regen_interview_const(packs: list, check_only: bool) -> tuple:
    """Returns (changed_or_drift: bool, errors: list)."""
    if not os.path.exists(CONTENT_SEEDS_DART):
        return False, [f"[interview-const] not found: {CONTENT_SEEDS_DART}"]
    dart = open(CONTENT_SEEDS_DART, encoding="utf-8").read()
    want_ids = [p["id"] for p in packs]
    have_ids = current_const_ids(dart)
    drift = want_ids != have_ids

    if check_only:
        if drift:
            return True, [f"[interview-const] out of sync: const has {have_ids}, "
                          f"interview.json has {want_ids}"]
        return False, []

    new_block = render_interview_const(packs)
    if SENT_START in dart and SENT_END in dart:
        start = dart.index(SENT_START)
        end = dart.index(SENT_END) + len(SENT_END)
        new_dart = dart[:start] + new_block + dart[end:]
    else:
        # First run: replace the legacy hand-written named consts + list.
        start_anchor = "  static const InterviewPack foundationsA1 = InterviewPack("
        if start_anchor not in dart:
            return False, ["[interview-const] legacy anchor not found; manual review needed"]
        start = dart.index(start_anchor)
        list_anchor = "  static const List<InterviewPack> interviewPacks = ["
        li = dart.index(list_anchor, start)
        end = dart.index("\n  ];", li) + len("\n  ];")
        new_dart = dart[:start] + new_block + dart[end:]
    if new_dart != dart:
        open(CONTENT_SEEDS_DART, "w", encoding="utf-8").write(new_dart)
        return True, []
    return False, []


def main() -> int:
    check_only = "--check" in sys.argv
    if not os.path.isdir(BACKEND_SEED):
        print(f"ERROR: backend seed dir not found: {BACKEND_SEED}", file=sys.stderr)
        return 2
    os.makedirs(APP_ASSET_SEED, exist_ok=True)

    all_errors: list = []
    rows: list = []
    interview_items = None
    for s in SEEDS:
        src = os.path.join(BACKEND_SEED, s["src"])
        dst = os.path.join(APP_ASSET_SEED, s["dst"])
        if not os.path.exists(src):
            all_errors.append(f"[{s['schema']}] source seed missing: {s['src']}")
            rows.append((s["schema"], "MISSING", "-", "-"))
            continue
        items = _load_items(src)
        if s["schema"] == "interview":
            interview_items = items
        errs = validate(s["schema"], items)
        all_errors.extend(errs)
        status = "OK" if not errs else f"{len(errs)} ERR"
        wrote = "check" if check_only else "-"
        if not check_only and not errs:
            with open(dst, "w", encoding="utf-8") as f:
                json.dump(items, f, ensure_ascii=False, indent=2)
                f.write("\n")
            wrote = "written"
        rows.append((s["schema"], status, len(items), wrote))

    # Regenerate / check the compiled-in interview const.
    const_note = ""
    if interview_items is not None and not [e for e in all_errors if e.startswith("[interview]")]:
        changed, cerrs = regen_interview_const(interview_items, check_only)
        all_errors.extend(cerrs)
        if check_only:
            const_note = "DRIFT" if (changed or cerrs) else "in sync"
        else:
            const_note = "regenerated" if changed else "unchanged"

    w = max(len(r[0]) for r in rows)
    print(f"{'seed'.ljust(w)}  status   items  asset")
    print("-" * (w + 24))
    for name, status, n, wrote in rows:
        print(f"{name.ljust(w)}  {str(status).ljust(7)} {str(n).rjust(5)}  {wrote}")
    if const_note:
        print(f"\nContentSeeds.interviewPacks const: {const_note}")

    if all_errors:
        print("\nVALIDATION/DRIFT FAILED:", file=sys.stderr)
        for e in all_errors:
            print("  - " + e, file=sys.stderr)
        return 1
    print("\nAll seeds valid" + ("" if check_only else " and synced (assets + const)") + ".")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
