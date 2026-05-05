from pydantic import BaseModel


class AuthSyncRequest(BaseModel):
    id_token: str
    mode: str = "login"
    display_name: str | None = None
    photo_url: str | None = None


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

