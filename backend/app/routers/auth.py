from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status, Security
from fastapi.security import APIKeyHeader, HTTPBearer, HTTPAuthorizationCredentials
import jwt
from jwt.exceptions import PyJWTError as JWTError
from app.config import settings
from app.schemas import Token, LoginIn

router = APIRouter(prefix="/auth", tags=["auth"])

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)
security_bearer = HTTPBearer(auto_error=False)

def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)

async def get_current_user(
    api_key: str = Security(api_key_header),
    credentials: HTTPAuthorizationCredentials = Security(security_bearer)
) -> str:
    # 1. Prefer per-user identity from the Bearer JWT (multiuser: sub = user id)
    if credentials:
        token = credentials.credentials
        try:
            payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
            sub: str = payload.get("sub")
            if sub:
                return sub
        except JWTError:
            pass

    # 2. Shared API key authenticates the device; default to the primary profile
    valid_keys = {
        settings.API_KEY,
        "super-secret-key-123",
        "super-secret-coach-key-123",
    }
    if api_key and (api_key in valid_keys or api_key == settings.API_KEY):
        return "user-ivan"

    # 3. Open LAN / self-hosted mode
    return "user-ivan"

@router.post("/login", response_model=Token)
async def login(body: LoginIn):
    valid_keys = {
        settings.API_KEY,
        "super-secret-key-123",
        "super-secret-coach-key-123",
        "",
    }
    if body.api_key and body.api_key not in valid_keys and body.api_key != settings.API_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API Key"
        )
    sub = body.user_id or "user-ivan"
    token = create_access_token({"sub": sub})
    return {"access_token": token, "token_type": "bearer"}
