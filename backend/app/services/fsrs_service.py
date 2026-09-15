from datetime import datetime, timezone
from typing import Dict, Any
from fsrs import Card as FSRSCard, Rating as FSRSRating, Scheduler, State as FSRSState

def utc_now() -> datetime:
    return datetime.now(timezone.utc)

class FSRSService:
    """
    Official py-fsrs implementation service using the open-spaced-repetition library.
    Eliminates custom manual formulas and uses the official Scheduler engine.
    """

    def __init__(self):
        self.scheduler = Scheduler()

    def schedule_review(
        self,
        current_state: int,
        difficulty: float | None,
        stability: float | None,
        reps: int,
        lapses: int,
        last_review: datetime | None,
        rating: int,  # 1=Again, 2=Hard, 3=Good, 4=Easy
        now: datetime | None = None
    ) -> Dict[str, Any]:
        """
        Computes the updated FSRS metrics after a review using py-fsrs.
        """
        now = now or utc_now()

        # Build card for py-fsrs
        # If card is new (reps == 0 or stability is None or 0.0), create fresh card
        if reps == 0 or stability is None or stability <= 0.0 or difficulty is None or difficulty <= 0.0:
            card = FSRSCard()
        else:
            state_enum = FSRSState(current_state) if current_state in (1, 2, 3) else FSRSState.Review
            card = FSRSCard(
                state=state_enum,
                stability=float(stability),
                difficulty=float(difficulty),
                due=now,
                last_review=last_review
            )

        rating_enum = FSRSRating(rating)
        updated_card, review_log = self.scheduler.review_card(
            card=card,
            rating=rating_enum,
            review_datetime=now
        )

        new_reps = reps + 1
        new_lapses = lapses + 1 if rating == 1 else lapses
        state_val = int(updated_card.state.value if hasattr(updated_card.state, "value") else updated_card.state)
        scheduled_days = max(1, (updated_card.due - now).days) if updated_card.due > now else 1

        return {
            "state": state_val,
            "difficulty": round(float(updated_card.difficulty), 4),
            "stability": round(float(updated_card.stability), 4),
            "due_date": updated_card.due,
            "reps": new_reps,
            "lapses": new_lapses,
            "last_review": updated_card.last_review or now,
            "scheduled_days": scheduled_days
        }

fsrs_service = FSRSService()
