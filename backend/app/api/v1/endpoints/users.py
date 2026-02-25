"""User endpoints for profile and bookmark management"""

from fastapi import APIRouter, Header, status, HTTPException
from typing import Optional
from app.schemas.user import UserProfileRequest, UserProfileResponse, SavedSchemeRequest, SavedSchemeResponse
from app.schemas.response import APIResponse
from app.services.supabase_service import supabase_service
from app.utils.logger import logger

router = APIRouter(
    prefix="/users",
    tags=["users"]
)


@router.get("/profile", response_model=APIResponse[UserProfileResponse], status_code=status.HTTP_200_OK)
async def get_user_profile(user_uuid: str = Header(..., alias="X-User-UUID")):
    """
    Get user profile
    
    Retrieve user profile information by UUID
    """
    try:
        logger.info(f"[PROFILE] Fetching profile for: {user_uuid}")
        
        user = supabase_service.get_user_profile(user_uuid)
        
        if not user:
            # Return empty profile for new users
            logger.info(f"[NEW-USER] New user: {user_uuid}")
            return APIResponse(
                success=True,
                message="User profile retrieved successfully",
                data=UserProfileResponse(uuid=user_uuid)
            )
        
        return APIResponse(
            success=True,
            message="User profile retrieved successfully",
            data=UserProfileResponse(**user.to_dict())
        )
    except Exception as e:
        logger.error(f"[ERROR] Error fetching user profile: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch profile: {str(e)}"
        )


@router.post("/profile", response_model=APIResponse[UserProfileResponse], status_code=status.HTTP_200_OK)
async def update_user_profile(
    user_uuid: str = Header(..., alias="X-User-UUID"),
    profile: UserProfileRequest = None
):
    """
    Update user profile
    
    Update user information like state, age, occupation
    """
    try:
        logger.info(f"[UPDATE] Updating profile for: {user_uuid}")
        
        if not profile:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Profile data is required"
            )
        
        updated_user = supabase_service.create_or_update_user(
            user_uuid, 
            state=profile.state,
            age=profile.age,
            gender=profile.gender,
            occupation=profile.occupation
        )
        
        logger.info(f"[OK] Profile updated for: {user_uuid}")
        
        return APIResponse(
            success=True,
            message="Profile updated successfully",
            data=UserProfileResponse(**updated_user.to_dict())
        )
    except Exception as e:
        logger.error(f"[ERROR] Error updating profile: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile: {str(e)}"
        )


@router.post("/schemes/bookmark", response_model=APIResponse[SavedSchemeResponse], status_code=status.HTTP_200_OK)
async def bookmark_scheme(
    user_uuid: str = Header(..., alias="X-User-UUID"),
    request: SavedSchemeRequest = None
):
    """
    Save scheme for user
    
    Add scheme to user's saved schemes
    """
    try:
        if not request or not request.scheme_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="scheme_id is required"
            )
        
        logger.info(f"[BOOKMARK] User {user_uuid} saving scheme: {request.scheme_id}")
        
        supabase_service.bookmark_scheme(user_uuid, request.scheme_id)
        
        logger.info(f"[OK] Scheme bookmarked for: {user_uuid}")
        
        return APIResponse(
            success=True,
            message="Scheme saved successfully",
            data=SavedSchemeResponse(
                user_uuid=user_uuid,
                scheme_id=request.scheme_id,
                saved=True
            )
        )
    except Exception as e:
        logger.error(f"[ERROR] Error saving scheme: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save scheme: {str(e)}"
        )


@router.delete("/schemes/bookmark/{scheme_id}", response_model=APIResponse[SavedSchemeResponse], status_code=status.HTTP_200_OK)
async def remove_bookmark(
    user_uuid: str = Header(..., alias="X-User-UUID"),
    scheme_id: str = None
):
    """
    Remove saved scheme
    
    Remove scheme from user's saved schemes
    """
    try:
        if not scheme_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="scheme_id is required"
            )
        
        logger.info(f"[REMOVE] User {user_uuid} removing scheme: {scheme_id}")
        
        supabase_service.remove_bookmark(user_uuid, scheme_id)
        
        logger.info(f"[OK] Scheme removed for: {user_uuid}")
        
        return APIResponse(
            success=True,
            message="Scheme removed successfully",
            data=SavedSchemeResponse(
                user_uuid=user_uuid,
                scheme_id=scheme_id,
                saved=False
            )
        )
    except Exception as e:
        logger.error(f"[ERROR] Error removing scheme: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove scheme: {str(e)}"
        )


@router.get("/schemes/saved", response_model=APIResponse[str], status_code=status.HTTP_200_OK)
async def get_saved_schemes(user_uuid: str = Header(..., alias="X-User-UUID")):
    """
    Get saved scheme IDs
    
    Retrieve list of scheme IDs saved by user
    """
    try:
        logger.info(f"[FETCH] Getting saved schemes for: {user_uuid}")
        
        saved_scheme_ids = supabase_service.get_saved_schemes(user_uuid)
        
        logger.info(f"[OK] Found {len(saved_scheme_ids)} saved schemes")
        
        return APIResponse(
            success=True,
            message="Saved schemes retrieved successfully",
            data={"saved_scheme_ids": saved_scheme_ids}
        )
    except Exception as e:
        logger.error(f"[ERROR] Error fetching saved schemes: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch saved schemes: {str(e)}"
        )
