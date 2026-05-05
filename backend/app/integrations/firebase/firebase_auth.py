import firebase_admin
from firebase_admin import auth, credentials

from app.core.config import settings


def verify_firebase_token(token: str) -> dict:
    if not token:
        raise ValueError("Firebase ID token wajib dikirim.")

    _ensure_firebase_app()
    return auth.verify_id_token(token)


def _ensure_firebase_app() -> None:
    if firebase_admin._apps:
        return

    if (
        not settings.FIREBASE_PROJECT_ID
        or not settings.FIREBASE_CLIENT_EMAIL
        or not settings.FIREBASE_PRIVATE_KEY
    ):
        raise ValueError(
            "Firebase Admin belum dikonfigurasi. Isi FIREBASE_PROJECT_ID, "
            "FIREBASE_CLIENT_EMAIL, dan FIREBASE_PRIVATE_KEY."
        )

    private_key = settings.FIREBASE_PRIVATE_KEY.replace("\\n", "\n")
    credential = credentials.Certificate(
        {
            "type": "service_account",
            "project_id": settings.FIREBASE_PROJECT_ID,
            "client_email": settings.FIREBASE_CLIENT_EMAIL,
            "private_key": private_key,
            "token_uri": "https://oauth2.googleapis.com/token",
        }
    )
    firebase_admin.initialize_app(credential)
