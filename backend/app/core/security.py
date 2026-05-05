from app.core.exceptions import AppException
from app.db.repositories.user_repository import UserRepository
from app.db.schemas.user_schema import AuthenticatedUser
from app.integrations.firebase.firebase_auth import verify_firebase_token


def authenticated_user_from_authorization(
    authorization: str | None,
) -> AuthenticatedUser | None:
    token = _extract_bearer_token(authorization)
    if token is None:
        return None

    try:
        claims = verify_firebase_token(token)
    except Exception as exc:
        raise AppException(
            f"Firebase token tidak valid: {exc}",
            status_code=401,
        ) from exc

    firebase_uid = claims.get("uid")
    if not firebase_uid:
        raise AppException("Firebase token tidak memiliki uid.", status_code=401)

    user = UserRepository().create_or_update_from_auth_claims(
        firebase_uid=firebase_uid,
        email=claims.get("email"),
        display_name=claims.get("name"),
        avatar_url=claims.get("picture"),
    )
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


def _extract_bearer_token(authorization: str | None) -> str | None:
    if not authorization:
        return None

    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise AppException("Authorization header harus memakai Bearer token.", status_code=401)
    return token.strip()
