"""API v1 router"""

from fastapi import APIRouter
from app.api.v1.endpoints import health, schemes, users

api_router = APIRouter()

# Include endpoint routers
api_router.include_router(health.router)
api_router.include_router(schemes.router)
api_router.include_router(users.router)
