import os
import re
import json
import hashlib
import urllib.request
from datetime import datetime, timezone
import shutil
from sqlalchemy import select

from app.models import (
    ExternalResource,
    ResourceCollection,
    ResourceTag,
    UnitResourceLink,
    ImportRun,
    PublishedSnapshot,
)

SOURCES = {
    "awesome-english": {
        "url": "https://raw.githubusercontent.com/yvoronoy/awesome-english/main/readme.md",
        "cache_file": "awesome_english.md",
    },
    "leatex-gist": {
        "url": "https://gist.githubusercontent.com/LeaTex/ad81a4d24be49ddbb64ee0488d572e73/raw/68599dbaf94f225e2879dea8c42f2676ea2d1a73/learning_english.md",
        "cache_file": "leatex_gist.md",
    },
}

DEFAULT_SOURCES_DIR = os.path.join(
    os.path.dirname(os.path.dirname(__file__)), "seed", "sources"
)
SNAPSHOT_PATH = os.path.join(
    os.path.dirname(os.path.dirname(__file__)), "seed", "published_snapshot.json"
)
FLUTTER_ASSETS_SNAPSHOT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))),
    "app",
    "assets",
    "seed",
    "published_snapshot.json",
)


def utc_now():
    return datetime.now(timezone.utc)


def fetch_sources(sources_dir=DEFAULT_SOURCES_DIR, force_refresh=False):
    """
    Phase 1: Downloads the source markdowns or loads from cache if offline.
    """
    os.makedirs(sources_dir, exist_ok=True)
    fetched_data = {}

    for source_key, meta in SOURCES.items():
        cache_path = os.path.join(sources_dir, meta["cache_file"])
        content = None

        if not force_refresh and os.path.exists(cache_path):
            try:
                with open(cache_path, "r", encoding="utf-8") as f:
                    content = f.read()
            except Exception:
                content = None

        if not content:
            try:
                req = urllib.request.Request(
                    meta["url"], headers={"User-Agent": "Mozilla/5.0"}
                )
                with urllib.request.urlopen(req, timeout=10) as resp:
                    content = resp.read().decode("utf-8")
                with open(cache_path, "w", encoding="utf-8") as f:
                    f.write(content)
            except Exception:
                # Offline fallback if file already existed previously
                if os.path.exists(cache_path):
                    with open(cache_path, "r", encoding="utf-8") as f:
                        content = f.read()
                else:
                    content = ""

        fetched_data[source_key] = content

    return fetched_data


def parse_markdown(source_name, text):
    """
    Phase 2: Extracts headings, subsections, bullets and anchor links [Title](URL).
    """
    raw_items = []
    current_h1 = ""
    current_h2 = ""
    current_h3 = ""

    lines = text.splitlines()
    link_regex = re.compile(r"\[([^\]]+)\]\((https?://[^)]+)\)(?:\s*[-–—:]\s*(.*))?")

    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue

        if stripped.startswith("# "):
            current_h1 = stripped[2:].strip()
            current_h2 = ""
            current_h3 = ""
            continue
        elif stripped.startswith("## "):
            current_h2 = stripped[3:].strip()
            current_h3 = ""
            continue
        elif stripped.startswith("### "):
            current_h3 = stripped[4:].strip()
            continue

        # Check list item with link
        if stripped.startswith(("* ", "- ", "+ ", "1. ", "2. ", "3. ")):
            match = link_regex.search(stripped)
            if match:
                title = match.group(1).strip()
                url = match.group(2).strip()
                description = (match.group(3) or "").strip()

                raw_items.append({
                    "source_name": source_name,
                    "title": title,
                    "url": url,
                    "description": description,
                    "h1": current_h1,
                    "h2": current_h2,
                    "h3": current_h3,
                })

    return raw_items


def normalize_resources(raw_items):
    """
    Phase 3: Strongly types raw extracted items into canonical resource entities.
    Maps skills, domains, levels, formats and generates Spanish notes.
    """
    normalized = []
    seen_urls = set()

    for item in raw_items:
        url = item["url"]
        if url in seen_urls:
            continue
        seen_urls.add(url)

        title = item["title"]
        desc = item["description"]
        h2 = item["h2"].lower()
        h3 = item["h3"].lower()
        combined_text = f"{title} {desc} {h2} {h3}".lower()

        # Deduce skill
        skill = "listening"
        if "speaking" in combined_text or "pronunciation" in combined_text or "phonetics" in combined_text:
            skill = "speaking"
        elif "grammar" in combined_text:
            skill = "grammar"
        elif "vocab" in combined_text or "idiom" in combined_text or "phrasal" in combined_text:
            skill = "vocabulary"
        elif "read" in combined_text or "book" in combined_text:
            skill = "reading"
        elif "write" in combined_text or "writing" in combined_text:
            skill = "writing"
        elif "test" in combined_text or "quiz" in combined_text or "exercise" in combined_text:
            skill = "exercises_tests"
        elif "tool" in combined_text or "dictionary" in combined_text or "extension" in combined_text:
            skill = "tools"
        elif "watch" in combined_text or "youtube" in combined_text:
            skill = "watching"

        # Deduce resource_type
        res_type = "article"
        if "podcast" in combined_text or "radio" in combined_text:
            res_type = "podcast"
        elif "forvo" in combined_text or "youglish" in combined_text or "tool" in combined_text or "dictionary" in combined_text or "speechling" in combined_text:
            res_type = "tool"
        elif "youtube.com" in url or "youtu.be" in url or "ted.com" in url or "video" in combined_text:
            res_type = "youtube"
        elif "exercise" in combined_text or "test" in combined_text or "quiz" in combined_text:
            res_type = "exercise"
        elif "course" in combined_text or "mooc" in combined_text:
            res_type = "course"

        # Deduce domain
        is_interview_specific = any(k in combined_text for k in ["behavioral", "job interview", "hr interview", "star method", "career prep"])
        is_tech = any(k in combined_text for k in ["tech", "software", "code", "dev", "engineering", "system", "data", "architecture", "changelog", "syntax"])
        is_interview = any(k in combined_text for k in ["interview", "job", "career", "behavioral", "resume"])

        if is_interview_specific:
            domain = "interview_english"
        elif is_tech:
            domain = "tech_english"
        elif is_interview:
            domain = "interview_english"
        else:
            domain = "general_english"

        # Deduce level
        level = "B1-B2"
        if any(k in combined_text for k in ["advanced", "c1", "c2", "leadership", "executive"]):
            level = "C1"
        elif any(k in combined_text for k in ["beginner", "zero", "a1", "a2", "básico"]):
            level = "A2"
        elif any(k in combined_text for k in ["intermediate", "b1"]):
            level = "B1"

        # Deduce tags
        tags = []
        if is_tech:
            tags.append("tech")
        if is_interview:
            tags.append("interview")
        if "podcast" in combined_text:
            tags.append("podcast")
        if "pronunciation" in combined_text or "ipa" in combined_text:
            tags.append("pronunciation")
        if "grammar" in combined_text:
            tags.append("grammar")
        if "devops" in combined_text or "cloud" in combined_text:
            tags.append("devops")
        if "backend" in combined_text or "api" in combined_text:
            tags.append("backend")

        # Spanish notes generation
        spanish_notes = desc
        if not spanish_notes:
            if res_type == "podcast":
                spanish_notes = f"Podcast recomendado para entrenar comprensión auditiva y cadencia natural en {domain}."
            elif res_type == "tool":
                spanish_notes = f"Herramienta interactiva para practicar {skill} con retroalimentación inmediata."
            else:
                spanish_notes = f"Recurso complementario para afianzar {skill} en contexto profesional."

        slug_base = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
        resource_id = f"res-{slug_base[:32]}-{hashlib.md5(url.encode()).hexdigest()[:6]}"

        normalized.append({
            "id": resource_id,
            "title": title,
            "original_url": url,
            "source_name": item["source_name"],
            "resource_type": res_type,
            "skill": skill,
            "domain": domain,
            "level": level,
            "tags": json.dumps(tags),
            "transcript_available": "podcast" in res_type or "youtube" in res_type,
            "spanish_support": item["source_name"] == "leatex-gist" or "español" in combined_text,
            "estimated_minutes": 20 if res_type == "podcast" else (10 if res_type == "tool" else 15),
            "recommended_for": f"Refuerzo de {skill.capitalize()} ({domain.replace('_', ' ').capitalize()})",
            "spanish_notes": spanish_notes,
            "status": "imported",
        })

    return normalized


async def review_publish(db, normalized_items):
    """
    Phase 4: Curates items, organizes collections, marks top engineering resources as published,
    and links companion resources to Units and Packs.
    """
    # 1. Ensure standard Collections exist
    collections_data = [
        {
            "id": "tech-podcasts",
            "name": "Podcasts de Ingeniería & Arquitectura",
            "description": "Episodios y shows de audio para entrenar listening técnico y cadencia conversacional.",
            "icon": "podcasts",
            "color": "#0D9488",
            "order_index": 1,
        },
        {
            "id": "speaking-tools",
            "name": "Herramientas de Pronunciación & Fonética",
            "description": "Buscadores de pronunciación nativa en contexto real (YouGlish, Forvo, Speechling).",
            "icon": "record_voice_over",
            "color": "#F59E0B",
            "order_index": 2,
        },
        {
            "id": "interview-prep",
            "name": "Simulaciones y Casos de Entrevista Tech",
            "description": "Historias STAR, preguntas de behavioural y defensas de arquitectura.",
            "icon": "work",
            "color": "#F97316",
            "order_index": 3,
        },
        {
            "id": "grammar-reference",
            "name": "Guías de Gramática & Consultas Rápidas",
            "description": "Referencias estructurales para evitar errores comunes de hispanohablantes.",
            "icon": "menu_book",
            "color": "#38BDF8",
            "order_index": 4,
        },
        {
            "id": "dev-onboarding",
            "name": "Onboarding y Soporte en Español",
            "description": "Recursos puente seleccionados del Gist para iniciar con confianza desde cero.",
            "icon": "translate",
            "color": "#A855F7",
            "order_index": 5,
        },
    ]

    for col in collections_data:
        res = await db.execute(select(ResourceCollection).filter(ResourceCollection.id == col["id"]))
        existing_col = res.scalar_one_or_none()
        if not existing_col:
            db.add(ResourceCollection(**col))
    await db.commit()

    # 2. Curation criteria for publishing
    curated_count = 0
    for item in normalized_items:
        tags = json.loads(item["tags"])
        res_type = item["resource_type"]
        domain = item["domain"]
        source = item["source_name"]

        target_collection = None
        should_publish = False

        if res_type == "podcast" or "podcast" in tags:
            target_collection = "tech-podcasts"
            should_publish = True
        elif item["skill"] == "speaking" or "pronunciation" in tags or res_type == "tool":
            target_collection = "speaking-tools"
            should_publish = True
        elif domain == "interview_english" or "interview" in tags:
            target_collection = "interview-prep"
            should_publish = True
        elif item["skill"] == "grammar" or item["skill"] == "exercises_tests":
            target_collection = "grammar-reference"
            should_publish = True
        elif source == "leatex-gist":
            target_collection = "dev-onboarding"
            should_publish = True
        else:
            if len(item["title"]) > 3:
                should_publish = True
                target_collection = "tech-podcasts" if domain == "tech_english" else "dev-onboarding"

        item["collection_id"] = target_collection
        item["status"] = "published" if should_publish else "reviewed"

        # Insert or update in DB
        res = await db.execute(select(ExternalResource).filter(ExternalResource.id == item["id"]))
        existing = res.scalar_one_or_none()
        if not existing:
            db_res = ExternalResource(**item)
            db.add(db_res)
            if should_publish:
                curated_count += 1
        else:
            existing.status = item["status"]
            existing.collection_id = target_collection
            existing.spanish_notes = item["spanish_notes"]

    await db.commit()

    # 3. Create Unit and Pack links
    res = await db.execute(select(ExternalResource).filter(ExternalResource.status == "published"))
    published_resources = res.scalars().all()
    links_created = 0

    unit_mappings = [
        ("unit-1-junior", ["interview", "podcast", "grammar"]),
        ("unit-2-junior", ["tech", "podcast"]),
        ("unit-9-mid", ["tech", "backend", "architecture"]),
        ("unit-17-senior", ["architecture", "interview", "podcast"]),
        ("unit-25-staff", ["leadership", "interview", "podcast"]),
    ]

    pack_mappings = [
        ("foundations", ["grammar", "pronunciation"]),
        ("backend", ["backend", "tech", "podcast"]),
        ("frontend", ["tech", "podcast"]),
        ("databases", ["backend", "tech"]),
        ("devops", ["devops", "tech"]),
        ("teamwork", ["interview", "podcast"]),
        ("interviews", ["interview", "speaking"]),
    ]

    for unit_id, target_tags in unit_mappings:
        for r in published_resources:
            res_tags = json.loads(r.tags)
            if any(t in res_tags for t in target_tags):
                exists_res = await db.execute(
                    select(UnitResourceLink).filter(
                        UnitResourceLink.resource_id == r.id,
                        UnitResourceLink.target_id == unit_id,
                    )
                )
                if not exists_res.scalar_one_or_none():
                    db.add(UnitResourceLink(
                        resource_id=r.id,
                        target_type="unit",
                        target_id=unit_id,
                        relevance_note=f"Recurso complementario recomendado para {unit_id}",
                    ))
                    links_created += 1
                    break

    for pack_id, target_tags in pack_mappings:
        for r in published_resources:
            res_tags = json.loads(r.tags)
            if any(t in res_tags for t in target_tags):
                exists_res = await db.execute(
                    select(UnitResourceLink).filter(
                        UnitResourceLink.resource_id == r.id,
                        UnitResourceLink.target_id == pack_id,
                    )
                )
                if not exists_res.scalar_one_or_none():
                    db.add(UnitResourceLink(
                        resource_id=r.id,
                        target_type="pack",
                        target_id=pack_id,
                        relevance_note=f"Recurso complementario para el pack {pack_id}",
                    ))
                    links_created += 1
                    break

    await db.commit()
    return {"published_count": curated_count, "links_created": links_created}


async def snapshot_export(db, export_path=SNAPSHOT_PATH, flutter_dest=FLUTTER_ASSETS_SNAPSHOT):
    """
    Phase 5: Exports published resources, collections and links to a versioned JSON snapshot.
    Copies it to Flutter assets for offline bundling.
    """
    res = await db.execute(select(ResourceCollection).order_by(ResourceCollection.order_index))
    collections = res.scalars().all()

    res = await db.execute(select(ExternalResource).filter(ExternalResource.status == "published"))
    resources = res.scalars().all()

    res = await db.execute(select(UnitResourceLink))
    links = res.scalars().all()

    collections_json = [
        {
            "id": c.id,
            "name": c.name,
            "description": c.description,
            "icon": c.icon,
            "color": c.color,
            "order_index": c.order_index,
        }
        for c in collections
    ]

    resources_json = [
        {
            "id": r.id,
            "title": r.title,
            "original_url": r.original_url,
            "source_name": r.source_name,
            "resource_type": r.resource_type,
            "skill": r.skill,
            "domain": r.domain,
            "level": r.level,
            "tags": json.loads(r.tags),
            "transcript_available": r.transcript_available,
            "spanish_support": r.spanish_support,
            "estimated_minutes": r.estimated_minutes,
            "recommended_for": r.recommended_for,
            "spanish_notes": r.spanish_notes,
            "collection_id": r.collection_id,
        }
        for r in resources
    ]

    links_json = [
        {
            "id": l.id,
            "resource_id": l.resource_id,
            "target_type": l.target_type,
            "target_id": l.target_id,
            "relevance_note": l.relevance_note,
        }
        for l in links
    ]

    version = f"v{datetime.now().strftime('%Y%m%d%H%M')}"
    payload = {
        "version": version,
        "exported_at": utc_now().isoformat(),
        "resource_count": len(resources_json),
        "collection_count": len(collections_json),
        "collections": collections_json,
        "resources": resources_json,
        "unit_links": links_json,
    }

    serialized = json.dumps(payload, indent=2, ensure_ascii=False)
    sha256 = hashlib.sha256(serialized.encode("utf-8")).hexdigest()
    payload["sha256_hash"] = sha256

    snapshot_record = PublishedSnapshot(
        id=f"snapshot-{version}",
        version=version,
        sha256_hash=sha256,
        resource_count=len(resources_json),
        collection_count=len(collections_json),
        snapshot_json=serialized,
    )
    db.add(snapshot_record)
    await db.commit()

    # Write to backend seed
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    with open(export_path, "w", encoding="utf-8") as f:
        f.write(serialized)

    # Copy to Flutter assets
    try:
        os.makedirs(os.path.dirname(flutter_dest), exist_ok=True)
        shutil.copyfile(export_path, flutter_dest)
    except Exception as e:
        print(f"Notice: Flutter asset copy error: {e}")

    return {
        "version": version,
        "sha256_hash": sha256,
        "resource_count": len(resources_json),
        "collection_count": len(collections_json),
        "export_path": export_path,
    }


async def run_full_pipeline(db, force_refresh=False):
    """
    Executes all 5 phases sequentially:
    fetch -> parse -> normalize -> review_publish -> snapshot_export
    """
    start_time = utc_now()
    import_run = ImportRun(
        id=f"run-{int(datetime.now().timestamp())}",
        source_name="awesome-english+leatex-gist",
        status="running",
        started_at=start_time,
    )
    db.add(import_run)
    await db.commit()

    try:
        # Phase 1: Fetch
        sources = fetch_sources(force_refresh=force_refresh)

        # Phase 2: Parse
        raw_items = []
        for src_name, text in sources.items():
            parsed = parse_markdown(src_name, text)
            raw_items.extend(parsed)

        import_run.total_parsed = len(raw_items)

        # Phase 3: Normalize
        normalized = normalize_resources(raw_items)
        import_run.total_imported = len(normalized)

        # Phase 4: Review and Publish
        pub_result = await review_publish(db, normalized)
        import_run.total_published = pub_result["published_count"]

        # Phase 5: Export Snapshot
        snap_result = await snapshot_export(db)

        import_run.status = "completed"
        import_run.completed_at = utc_now()
        import_run.log_summary = f"Parsed: {len(raw_items)}, Normalized: {len(normalized)}, Published: {pub_result['published_count']}, Snapshot: {snap_result['version']}"
        await db.commit()

        return {
            "status": "success",
            "import_run_id": import_run.id,
            "total_parsed": len(raw_items),
            "total_imported": len(normalized),
            "published_count": pub_result["published_count"],
            "snapshot_version": snap_result["version"],
            "sha256": snap_result["sha256_hash"],
        }
    except Exception as e:
        import_run.status = "failed"
        import_run.log_summary = str(e)
        import_run.completed_at = utc_now()
        await db.commit()
        raise
