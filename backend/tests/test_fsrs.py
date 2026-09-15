from datetime import datetime, timezone, timedelta
import pytest
from app.services.fsrs_service import fsrs_service

def test_fsrs_initial_review_good():
    """
    Reviewing a new card with 'Good' (rating=3) should initialize difficulty,
    stability, transition to Review state, and schedule a future due date.
    """
    now = datetime.now(timezone.utc)
    result = fsrs_service.schedule_review(
        current_state=0,  # New
        difficulty=0.0,
        stability=0.0,
        reps=0,
        lapses=0,
        last_review=None,
        rating=3,  # Good
        now=now
    )

    assert result["reps"] == 1
    assert result["lapses"] == 0
    assert result["difficulty"] > 0
    assert result["stability"] > 0
    assert result["scheduled_days"] >= 1
    assert result["due_date"] > now

def test_fsrs_again_failure_increments_lapses():
    """
    Reviewing a card with 'Again' (rating=1) should increment lapses,
    reset stability, and transition to relearning/learning.
    """
    now = datetime.now(timezone.utc)
    result = fsrs_service.schedule_review(
        current_state=2,  # Review
        difficulty=5.0,
        stability=10.0,
        reps=3,
        lapses=0,
        last_review=now - timedelta(days=10),
        rating=1,  # Again
        now=now
    )

    assert result["lapses"] == 1
    assert result["reps"] == 4
    assert result["state"] == 3  # Relearning
    assert result["difficulty"] >= 5.0  # Difficulty increases or stays high
