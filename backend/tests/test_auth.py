import pytest

from app.core.exceptions import AppException
from app.db.schemas.user_schema import AuthSyncRequest
from app.services import auth_service as auth_service_module
from app.services.auth_service import AuthService


class FakeUserRepository:
    def __init__(self, user=None):
        self.user = user
        self.created_payload = None

    def find_by_firebase_uid_or_email(self, firebase_uid, email):
        return self.user

    def create_or_update_from_auth_claims(
        self,
        *,
        firebase_uid,
        email,
        display_name,
        avatar_url,
    ):
        self.created_payload = {
            "firebase_uid": firebase_uid,
            "email": email,
            "display_name": display_name,
            "avatar_url": avatar_url,
        }
        return {
            "id": "user-db-id",
            "firebase_uid": firebase_uid,
            "email": email,
            "display_name": display_name,
            "avatar_url": avatar_url,
            "role": "user",
            "is_pregnant": False,
            "meowpoints_balance": 0,
        }


def test_register_google_user_saves_firebase_claims(monkeypatch):
    repository = FakeUserRepository()
    monkeypatch.setattr(
        auth_service_module,
        "verify_firebase_token",
        lambda _: {
            "uid": "firebase-uid",
            "email": "USER@example.com",
            "name": "Ana Bool",
            "picture": "https://example.com/avatar.png",
            "firebase": {"sign_in_provider": "google.com"},
        },
    )

    result = AuthService(repository).sync_user(
        id_token="firebase-token",
        mode="register",
    )

    assert repository.created_payload == {
        "firebase_uid": "firebase-uid",
        "email": "USER@example.com",
        "display_name": "Ana Bool",
        "avatar_url": "https://example.com/avatar.png",
    }
    assert result.user.firebase_uid == "firebase-uid"
    assert result.auth_provider == "google.com"


def test_auth_sync_request_accepts_flutter_camel_case_payload():
    payload = AuthSyncRequest.model_validate(
        {
            "idToken": "firebase-token",
            "mode": "register",
            "displayName": "Ana Bool",
            "photoUrl": "https://example.com/avatar.png",
        }
    )

    assert payload.id_token == "firebase-token"
    assert payload.mode == "register"
    assert payload.display_name == "Ana Bool"
    assert payload.photo_url == "https://example.com/avatar.png"


def test_auth_sync_request_accepts_backend_snake_case_payload():
    payload = AuthSyncRequest.model_validate(
        {
            "id_token": "firebase-token",
            "display_name": "Ana Bool",
            "photo_url": "https://example.com/avatar.png",
        }
    )

    assert payload.id_token == "firebase-token"
    assert payload.mode == "login"
    assert payload.display_name == "Ana Bool"
    assert payload.photo_url == "https://example.com/avatar.png"


def test_login_requires_existing_database_user(monkeypatch):
    monkeypatch.setattr(
        auth_service_module,
        "verify_firebase_token",
        lambda _: {
            "uid": "firebase-uid",
            "email": "user@example.com",
            "firebase": {"sign_in_provider": "password"},
        },
    )

    with pytest.raises(AppException) as error:
        AuthService(FakeUserRepository()).sync_user(
            id_token="firebase-token",
            mode="login",
        )

    assert error.value.status_code == 404
    assert error.value.data == {
        "reason": "registration_required",
        "redirect_to": "/signup",
    }
