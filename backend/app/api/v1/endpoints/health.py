"""Health check endpoints"""

from fastapi import APIRouter, status

router = APIRouter(
    prefix="/health",
    tags=["health"]
)


@router.get("/ping", status_code=status.HTTP_200_OK)
async def ping():
    """Health check endpoint"""
    return {"status": "healthy", "message": "API is running"}


@router.get("/status", status_code=status.HTTP_200_OK)
async def status_check():
    """Detailed status check"""
    return {
        "status": "operational",
        "version": "1.0.0",
        "message": "GSAPP API is operational"
    }
