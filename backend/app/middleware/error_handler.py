"""Error handling middleware"""

from fastapi import Request, status
from fastapi.responses import JSONResponse
from app.utils.logger import logger


async def error_handler_middleware(request: Request, call_next):
    """Handle errors and log requests"""
    try:
        response = await call_next(request)
        return response
    except Exception as e:
        logger.error(f"Request failed: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "success": False,
                "message": "Internal server error",
                "error": str(e) if logger.level == logging.DEBUG else "Unknown error"
            }
        )


import logging
