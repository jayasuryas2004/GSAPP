"""
GSAPP FastAPI Backend - Production Ready
Government Schemes Application API
"""

import os
import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.utils import get_openapi
import httpx
import uvicorn

from config.settings import settings
from app.api.v1.router import api_router
from app.utils.logger import logger


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown events"""
    # Startup
    logger.info(f"[STARTUP] GSAPP API starting (Environment: {settings.ENVIRONMENT})")
    logger.info(f"[DB] Database: {settings.SUPABASE_URL}")
    
    # Start keep-alive task
    keep_alive_task = asyncio.create_task(keep_alive_ping())
    
    yield
    
    # Shutdown
    keep_alive_task.cancel()
    logger.info("[SHUTDOWN] GSAPP API shutting down")


async def keep_alive_ping():
    """Periodically ping the API to keep Railway awake"""
    await asyncio.sleep(10)
    
    while True:
        try:
            # Ping health endpoint every 10 minutes
            await asyncio.sleep(600)
            async with httpx.AsyncClient() as client:
                health_url = f"http://0.0.0.0:{settings.PORT}/api/v1/health/ping"
                await client.get(health_url, timeout=5)
                logger.debug("[OK] Keep-alive ping sent")
        except Exception as e:
            logger.debug(f"[FAIL] Keep-alive ping failed: {str(e)}")
            pass


# Initialize FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Production API for Government Schemes Application",
    lifespan=lifespan,
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)


# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:*",
        "http://127.0.0.1",
        "http://127.0.0.1:*",
        "http://10.0.2.2",
        "http://10.0.2.2:*",
        "https://localhost",
        "https://localhost:*",
        "*railway.app",
        "*render.com",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Handle all unhandled exceptions"""
    logger.error(f"[ERROR] Unhandled exception: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "message": "Internal server error",
            "error": str(exc) if settings.DEBUG else "Unknown error"
        }
    )


# Include API v1 routes
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


# Root endpoint
@app.get("/", tags=["root"])
async def root():
    """Root endpoint for health check"""
    return {
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "operational",
        "docs": "/api/docs",
        "health": "/api/v1/health/ping"
    }


# Logging middleware
@app.middleware("http")
async def logging_middleware(request: Request, call_next):
    """Middleware for logging HTTP requests"""
    import time
    
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    logger.info(
        f"{request.method} {request.url.path} - "
        f"Status: {response.status_code} - "
        f"Time: {process_time:.3f}s"
    )
    
    response.headers["X-Process-Time"] = str(process_time)
    return response


# Custom OpenAPI schema
def custom_openapi():
    """Generate custom OpenAPI schema"""
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title="GSAPP API",
        version=settings.APP_VERSION,
        description="Government Schemes Application API Production Ready",
        routes=app.routes,
    )
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi


# Startup validation
@app.on_event("startup")
async def startup_validation():
    """Validate configuration on application startup"""
    logger.info("[VALIDATE] Checking configuration...")
    
    if not settings.SUPABASE_URL:
        raise ValueError("[ERROR] SUPABASE_URL not configured")
    
    if not settings.SUPABASE_SERVICE_KEY:
        raise ValueError("[ERROR] SUPABASE_SERVICE_KEY not configured")
    
    logger.info("[OK] Configuration validated")


# Main entry point
if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=port,
        workers=settings.WORKERS,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower(),
    )
