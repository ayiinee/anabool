from app.core.exceptions import AppException
from app.db.repositories.user_repository import UserRepository
from app.db.schemas.user_schema import AuthenticatedUser, AuthSyncResult
from app.integrations.firebase.firebase_auth import verify_firebase_token


class AuthService:
    def __init__(self, user_repository: UserRepository | None = None):
        self._user_repository = user_repository or UserRepository()

    def sync_user(
        self,
        *,
        id_token: str,
        mode: str,
        display_name: str | None = None,
        photo_url: str | None = None,
    ) -> AuthSyncResult:
        claims = self._verify_token(id_token)
        firebase_uid = claims.get("uid")
        email = claims.get("email")

        if not firebase_uid:
            raise AppException("Firebase token tidak memiliki uid.", status_code=401)

        auth_provider = _extract_auth_provider(claims)

        if mode == "login":
            user = self._user_repository.find_by_firebase_uid_or_email(
                firebase_uid=firebase_uid,
                email=email,
            )
            if user is None:
                raise AppException(
                    "Akun belum terdaftar. Silakan daftar terlebih dahulu.",
                    status_code=404,
                    data={
                        "reason": "registration_required",
                        "redirect_to": "/signup",
                    },
                )
            return AuthSyncResult(
                user=_to_authenticated_user(user),
                auth_provider=auth_provider,
            )

        user = self._user_repository.create_or_update_from_auth_claims(
            firebase_uid=firebase_uid,
            email=email,
            display_name=claims.get("name") or display_name,
            avatar_url=claims.get("picture") or photo_url,
        )
        return AuthSyncResult(
            user=_to_authenticated_user(user),
            auth_provider=auth_provider,
        )

    def _verify_token(self, id_token: str) -> dict:
        try:
            return verify_firebase_token(id_token)
        except Exception as exc:
            raise AppException(
                f"Firebase token tidak valid: {exc}",
                status_code=401,
            ) from exc


def _extract_auth_provider(claims: dict) -> str | None:
    firebase_claims = claims.get("firebase")
    if not isinstance(firebase_claims, dict):
        return None
    return firebase_claims.get("sign_in_provider")


def _to_authenticated_user(user: dict) -> AuthenticatedUser:
    return AuthenticatedUser(
        id=str(user["id"]),
        firebase_uid=user["firebase_uid"],
        email=user.get("email"),
        display_name=user.get("display_name"),
        avatar_url=user.get("avatar_url"),
        role=user.get("role", "user"),
        is_pregnant=user.get("is_pregnant", False),
        meowpoints_balance=user.get("meowpoints_balance", 0),
    )


def sync_user(
    *,
    id_token: str,
    mode: str,
    display_name: str | None = None,
    photo_url: str | None = None,
) -> AuthSyncResult:
    return AuthService().sync_user(
        id_token=id_token,
        mode=mode,
        display_name=display_name,
        photo_url=photo_url,
    )
