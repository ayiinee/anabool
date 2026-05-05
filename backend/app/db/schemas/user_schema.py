from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class AuthSyncRequest(BaseModel):
    id_token: str = Field(..., alias="idToken", min_length=1)
    mode: Literal["register", "login"] = "login"
    display_name: str | None = Field(default=None, alias="displayName")
    photo_url: str | None = Field(default=None, alias="photoUrl")

    model_config = ConfigDict(populate_by_name=True)


class AuthenticatedUser(BaseModel):
    id: str
    firebase_uid: str
    email: str | None = None
    display_name: str | None = None
    avatar_url: str | None = None
    role: str = "user"
    is_pregnant: bool = False
    meowpoints_balance: int = 0


class AuthSyncResult(BaseModel):
    user: AuthenticatedUser
    auth_provider: str | None = None
    redirect_to: str | None = None
