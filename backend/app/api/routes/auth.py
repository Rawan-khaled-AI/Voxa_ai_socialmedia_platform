from datetime import datetime, timedelta
import random

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import (
    create_access_token,
    decode_access_token,
    hash_password,
    verify_password,
)
from app.models.user import User
from app.models.password_reset_code import PasswordResetCode
from app.schemas.auth import (
    LoginRequest,
    SignUpRequest,
    ForgotPasswordRequest,
    VerifyResetCodeRequest,
    ResetPasswordRequest,
)
from app.services.auth_service import (
    create_user,
    authenticate_user,
    get_user_by_email,
)
from app.services.email_service import send_reset_code_email
from app.services.notification_service import create_notification

router = APIRouter(prefix="/auth", tags=["Authentication"])
security = HTTPBearer()


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


@router.post("/signup")
def signup(
    data: SignUpRequest,
    db: Session = Depends(get_db),
):
    existing_user = get_user_by_email(
        db,
        data.email,
    )

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="Email already exists",
        )

    new_user = create_user(
        db,
        data.name,
        data.email,
        data.password,
    )

    return {
        "message": "User created successfully.",
        "user": {
            "id": new_user.id,
            "name": new_user.name,
            "email": new_user.email,
        },
    }


@router.post("/login")
def login(
    data: LoginRequest,
    db: Session = Depends(get_db),
):
    user = authenticate_user(
        db,
        data.email,
        data.password,
    )

    if not user:
        raise HTTPException(
            status_code=400,
            detail="Invalid email or password",
        )

    token = create_access_token(
        {
            "sub": str(user.id),
        },
    )

    return {
        "access_token": token,
        "token_type": "bearer",
    }


@router.post("/forgot-password")
def forgot_password(
    data: ForgotPasswordRequest,
    db: Session = Depends(get_db),
):
    user = get_user_by_email(
        db,
        data.email,
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="Email not found",
        )

    db.query(PasswordResetCode).filter(
        PasswordResetCode.user_id == user.id,
        PasswordResetCode.is_used == False,
    ).update(
        {
            "is_used": True,
        }
    )

    code = str(
        random.randint(
            100000,
            999999,
        )
    )

    reset_code = PasswordResetCode(
        user_id=user.id,
        code=code,
        expires_at=datetime.utcnow() + timedelta(minutes=10),
        is_used=False,
    )

    db.add(reset_code)
    db.commit()

    try:
        send_reset_code_email(
            to_email=user.email,
            code=code,
        )
    except Exception as e:
        print("EMAIL ERROR:", str(e))
        raise HTTPException(
            status_code=500,
            detail=f"Failed to send verification email: {str(e)}",
        )

    return {
        "message": "Verification code sent",
    }


@router.post("/verify-reset-code")
def verify_reset_code(
    data: VerifyResetCodeRequest,
    db: Session = Depends(get_db),
):
    user = get_user_by_email(
        db,
        data.email,
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="Email not found",
        )

    reset_code = (
        db.query(PasswordResetCode)
        .filter(
            PasswordResetCode.user_id == user.id,
            PasswordResetCode.code == data.code,
            PasswordResetCode.is_used == False,
        )
        .order_by(PasswordResetCode.created_at.desc())
        .first()
    )

    if not reset_code:
        raise HTTPException(
            status_code=400,
            detail="Invalid verification code",
        )

    if reset_code.expires_at < datetime.utcnow():
        raise HTTPException(
            status_code=400,
            detail="Verification code expired",
        )

    return {
        "message": "Code verified successfully",
    }


@router.post("/reset-password")
def reset_password(
    data: ResetPasswordRequest,
    db: Session = Depends(get_db),
):
    user = get_user_by_email(
        db,
        data.email,
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="Email not found",
        )

    reset_code = (
        db.query(PasswordResetCode)
        .filter(
            PasswordResetCode.user_id == user.id,
            PasswordResetCode.is_used == False,
        )
        .order_by(PasswordResetCode.created_at.desc())
        .first()
    )

    if not reset_code:
        raise HTTPException(
            status_code=400,
            detail="Please verify your reset code first",
        )

    if reset_code.expires_at < datetime.utcnow():
        raise HTTPException(
            status_code=400,
            detail="Verification code expired",
        )

    user.password = hash_password(
        data.new_password,
    )

    reset_code.is_used = True

    create_notification(
        db=db,
        user_id=user.id,
        notification_type="password_reset",
    )

    db.commit()

    return {
        "message": "Password reset successfully",
    }


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
):
    token = credentials.credentials
    payload = decode_access_token(token)

    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user_id = payload.get("sub")

    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
        )

    user = (
        db.query(User)
        .filter(User.id == int(user_id))
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    return user


@router.patch("/change-password")
def change_password(
    data: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not verify_password(
        data.current_password,
        current_user.password,
    ):
        raise HTTPException(
            status_code=400,
            detail="Current password is incorrect",
        )

    current_user.password = hash_password(
        data.new_password,
    )

    create_notification(
        db=db,
        user_id=current_user.id,
        notification_type="password_changed",
    )

    db.commit()

    return {
        "message": "Password changed successfully",
    }


@router.get("/me")
def get_me(
    current_user: User = Depends(get_current_user),
):
    return {
        "id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
    }