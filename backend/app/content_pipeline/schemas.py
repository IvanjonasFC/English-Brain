from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field


def utc_now():
    return datetime.now(timezone.utc)


class OriginMetadata(BaseModel):
    source: str = Field(default="generated", description="original, generated, referenced")
    sourceUrl: Optional[str] = None
    license: str = Field(default="own", description="own, reference_only")
    importedAt: Optional[str] = None
    reviewedBy: Optional[str] = None
    reviewNotes: Optional[str] = None


class ContentItemIn(BaseModel):
    id: str
    type: str = Field(..., description="interview_question, vocabulary_term, grammar_unit, shadowing_phrase")
    cefr: Optional[str] = Field(None, description="A1, A2, B1, B2, C1, C2")
    scenario: Optional[str] = Field(None, description="system_design, hr, backend_arch, etc.")
    objective: Optional[str] = None
    difficulty: str = Field(default="mid", description="junior, mid, senior, all")
    source_type: str = Field(default="interview", description="interview, vocabulary, grammar, shadowing")
    payload: Dict[str, Any] = Field(..., description="Entity specific payload (e.g. title, prompt, answers, ipa, etc.)")
    origin: Optional[OriginMetadata] = None


class ContentItemReviewIn(BaseModel):
    action: str = Field(..., description="approve, reject, edit")
    cefr: Optional[str] = Field(None, description="Target CEFR level A1..C2 (mandatory for approve)")
    scenario: Optional[str] = None
    difficulty: Optional[str] = None
    reviewed_by: str = Field(default="user-ivan")
    review_notes: Optional[str] = None
    edited_payload: Optional[Dict[str, Any]] = None


class ContentItemOut(BaseModel):
    id: str
    content_type: str
    status: str
    cefr: Optional[str]
    scenario: Optional[str]
    objective: Optional[str]
    difficulty: str
    source_type: str
    payload: Dict[str, Any]
    source_origin: str
    source_url: Optional[str]
    license: str
    imported_at: datetime
    reviewed_by: Optional[str]
    review_notes: Optional[str]
    reviewed_at: Optional[datetime]
    snapshot_version: Optional[str]
    created_at: datetime
    updated_at: datetime


class BatchIngestIn(BaseModel):
    batch_name: Optional[str] = None
    items: List[ContentItemIn]


class BatchIngestResult(BaseModel):
    total_received: int
    normalized_count: int
    errors: List[str]


class ContentManifest(BaseModel):
    version: str
    created_at: str
    sha256_hash: str
    item_counts: Dict[str, int]
    total_items: int


class ContentDeltaResponse(BaseModel):
    current_version: str
    since_version: Optional[str]
    has_update: bool
    manifest: ContentManifest
    added: List[Dict[str, Any]]
    updated: List[Dict[str, Any]]
    removed_ids: List[str]
