import json
import logging
import os
import time
import uuid
from datetime import datetime, timezone
from logging.handlers import RotatingFileHandler
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

from app.config import settings

# Configure structured JSON logger
logger = logging.getLogger("english_brain.access")
logger.propagate = False

# Resolve logging level
log_level = getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO)
logger.setLevel(log_level)

class JSONFormatter(logging.Formatter):
    """Formats log records as single-line JSON objects."""
    def format(self, record: logging.LogRecord) -> str:
        log_obj = getattr(record, "json_data", None)
        if log_obj is None:
            log_obj = {
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "level": record.levelname,
                "message": record.getMessage(),
                "logger": record.name,
            }
            if record.exc_info:
                log_obj["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_obj, ensure_ascii=False)

# Setup handlers if not already configured
if not logger.handlers:
    # 1. Console Stream Handler
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(JSONFormatter())
    logger.addHandler(stream_handler)

    # 2. Rotating File Handler (10 MB, 5 backups)
    log_file_path = settings.LOG_FILE_PATH
    try:
        log_dir = os.path.dirname(log_file_path)
        if log_dir:
            os.makedirs(log_dir, exist_ok=True)
        file_handler = RotatingFileHandler(
            log_file_path,
            maxBytes=10 * 1024 * 1024,  # 10 MB
            backupCount=5,
            encoding="utf-8"
        )
        file_handler.setFormatter(JSONFormatter())
        logger.addHandler(file_handler)
    except Exception as e:
        print(f"[LoggingMiddleware] Warning: Could not initialize file handler at {log_file_path}: {e}")

class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        # 1. Extract or generate Correlation ID
        request_id = request.headers.get("X-Request-ID") or str(uuid.uuid4())
        request.state.request_id = request_id

        # 2. Timing
        start_time = time.perf_counter()

        client_host = request.client.host if request.client else "unknown"
        path = request.url.path
        method = request.method

        # 3. Process request
        status_code = 500
        try:
            response = await call_next(request)
            status_code = response.status_code
        except Exception as exc:
            duration_ms = round((time.perf_counter() - start_time) * 1000, 2)
            log_payload = {
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "level": "ERROR",
                "request_id": request_id,
                "method": method,
                "path": path,
                "status_code": 500,
                "duration_ms": duration_ms,
                "client_ip": client_host,
                "error": str(exc),
            }
            extra = {"json_data": log_payload}
            logger.error("Unhandled request exception", extra=extra)
            raise exc

        duration_ms = round((time.perf_counter() - start_time) * 1000, 2)

        # 4. Inject X-Request-ID into response headers
        response.headers["X-Request-ID"] = request_id

        # 5. Build structured JSON payload (strictly omitting tokens, keys, transcripts, or audio paths)
        level = "INFO"
        if duration_ms > 5000:
            level = "WARNING"

        log_payload = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": level,
            "request_id": request_id,
            "method": method,
            "path": path,
            "status_code": status_code,
            "duration_ms": duration_ms,
            "client_ip": client_host,
        }
        if duration_ms > 5000:
            log_payload["warning"] = "Slow request (>5000ms threshold)"

        extra = {"json_data": log_payload}
        if duration_ms > 5000:
            logger.warning(f"Slow request {method} {path} took {duration_ms}ms", extra=extra)
        else:
            logger.info(f"{method} {path} {status_code} - {duration_ms}ms", extra=extra)

        return response
