from pydantic import AliasChoices, BaseModel, Field


class AuthSyncRequest(BaseModel):
    id_token: str = Field(validation_alias=AliasChoices("id_token", "idToken"))
    mode: str = "login"
    display_name: str | None = Field(
        default=None,
        validation_alias=AliasChoices("display_name", "displayName"),
    )
    photo_url: str | None = Field(
        default=None,
        validation_alias=AliasChoices("photo_url", "photoUrl"),
    )


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
