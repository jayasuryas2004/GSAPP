"""Scheme endpoints for retrieving government schemes"""

from fastapi import APIRouter, Query, status, HTTPException
from typing import Optional
from app.schemas.scheme import SchemeResponse, SchemeListResponse, SchemeSearchRequest, SchemeSearchResponse
from app.schemas.response import APIResponse
from app.services.supabase_service import supabase_service
from app.services.cache_service import cache_service
from app.utils.logger import logger
from config.settings import settings

router = APIRouter(
    prefix="/schemes",
    tags=["schemes"]
)


@router.get("/list", response_model=APIResponse[SchemeListResponse], status_code=status.HTTP_200_OK)
async def get_all_schemes():
    """
    Get all government schemes
    
    Returns paginated list of all 790+ government schemes
    """
    try:
        # Try to get from cache first
        cache_key = "all_schemes"
        cached_schemes = cache_service.get(cache_key)
        
        if cached_schemes:
            logger.info("[CACHE] Schemes retrieved from cache")
            return APIResponse(
                success=True,
                message="Schemes retrieved successfully (cached)",
                data=SchemeListResponse(
                    total=len(cached_schemes),
                    schemes=[SchemeResponse(**scheme.to_dict()) for scheme in cached_schemes]
                )
            )
        
        # If not cached, fetch from Supabase
        logger.info("[FETCH] Fetching schemes from Supabase...")
        schemes = supabase_service.get_all_schemes()
        
        # Cache the result
        cache_service.set(cache_key, schemes, settings.CACHE_SCHEMES_TTL)
        logger.info(f"[OK] Fetched {len(schemes)} schemes")
        
        return APIResponse(
            success=True,
            message="Schemes retrieved successfully",
            data=SchemeListResponse(
                total=len(schemes),
                schemes=[SchemeResponse(**scheme.to_dict()) for scheme in schemes]
            )
        )
    except Exception as e:
        logger.error(f"[ERROR] Error fetching schemes: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch schemes: {str(e)}"
        )


@router.get("/search", response_model=APIResponse[SchemeSearchResponse], status_code=status.HTTP_200_OK)
async def search_schemes(
    query: str = Query(..., min_length=1),
    state: Optional[str] = Query(None),
    category: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=500)
):
    """
    Search for government schemes
    
    Search with filters for state, category, and limit
    """
    try:
        # Create cache key
        cache_key = f"search:{query}:{state}:{category}:{limit}"
        cached_results = cache_service.get(cache_key)
        
        if cached_results:
            logger.info("[CACHE] Search results retrieved from cache")
            return APIResponse(
                success=True,
                message="Search completed (cached)",
                data=SchemeSearchResponse(
                    query=query,
                    total=len(cached_results),
                    schemes=[SchemeResponse(**scheme.to_dict()) for scheme in cached_results]
                )
            )
        
        logger.info(f"[SEARCH] Searching for: {query}")
        schemes = supabase_service.search_schemes(query, state, category, limit)
        
        # Cache the result
        cache_service.set(cache_key, schemes, settings.CACHE_SCHEMES_TTL)
        logger.info(f"[OK] Found {len(schemes)} schemes")
        
        return APIResponse(
            success=True,
            message="Search completed successfully",
            data=SchemeSearchResponse(
                query=query,
                total=len(schemes),
                schemes=[SchemeResponse(**scheme.to_dict()) for scheme in schemes]
            )
        )
    except Exception as e:
        logger.error(f"[ERROR] Error searching schemes: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Search failed: {str(e)}"
        )


@router.get("/{scheme_id}", response_model=APIResponse[SchemeResponse], status_code=status.HTTP_200_OK)
async def get_scheme_detail(scheme_id: str):
    """
    Get scheme detail
    
    Retrieve detailed information for a single scheme
    """
    try:
        logger.info(f"[DETAIL] Fetching scheme: {scheme_id}")
        
        scheme = supabase_service.get_scheme_by_id(scheme_id)
        
        if not scheme:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Scheme not found"
            )
        
        return APIResponse(
            success=True,
            message="Scheme retrieved successfully",
            data=SchemeResponse(**scheme.to_dict())
        )
    except Exception as e:
        logger.error(f"[ERROR] Error fetching scheme: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch scheme: {str(e)}"
        )


@router.get("/state/{state}", response_model=APIResponse[SchemeListResponse], status_code=status.HTTP_200_OK)
async def get_schemes_by_state(state: str):
    """
    Get schemes by state
    
    Retrieve all schemes for a specific state
    """
    try:
        cache_key = f"state:{state}"
        cached_schemes = cache_service.get(cache_key)
        
        if cached_schemes:
            logger.info(f"[CACHE] State schemes for {state} retrieved from cache")
            return APIResponse(
                success=True,
                message=f"Schemes for {state} retrieved (cached)",
                data=SchemeListResponse(
                    total=len(cached_schemes),
                    schemes=[SchemeResponse(**scheme.to_dict()) for scheme in cached_schemes]
                )
            )
        
        logger.info(f"[FETCH] Fetching schemes for state: {state}")
        schemes = supabase_service.get_schemes_by_state(state)
        
        # Cache the result
        cache_service.set(cache_key, schemes, settings.CACHE_SCHEMES_TTL)
        logger.info(f"[OK] Found {len(schemes)} schemes for {state}")
        
        return APIResponse(
            success=True,
            message=f"Schemes for {state} retrieved successfully",
            data=SchemeListResponse(
                total=len(schemes),
                schemes=[SchemeResponse(**scheme.to_dict()) for scheme in schemes]
            )
        )
    except Exception as e:
        logger.error(f"[ERROR] Error fetching state schemes: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch schemes: {str(e)}"
        )
