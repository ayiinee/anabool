from app.core.exceptions import AppException
from app.integrations.supabase.supabase_client import get_supabase_service_client


class UserRepository:
    def __init__(self):
        self._client = get_supabase_service_client()

    def find_by_firebase_uid(self, firebase_uid: str) -> dict | None:
        response = (
            self._require_client()
            .table("users")
            .select("*")
            .eq("firebase_uid", firebase_uid)
            .limit(1)
            .execute()
        )
        return _first_row(response.data)

    def find_by_email(self, email: str | None) -> dict | None:
        if not email:
            return None

        response = (
            self._require_client()
            .table("users")
            .select("*")
            .eq("email", email.lower())
            .limit(1)
            .execute()
        )
        return _first_row(response.data)

    def find_by_firebase_uid_or_email(
        self,
        firebase_uid: str,
        email: str | None,
    ) -> dict | None:
        return self.find_by_firebase_uid(firebase_uid) or self.find_by_email(email)

    def create_or_update_from_auth_claims(
        self,
        *,
        firebase_uid: str,
        email: str | None,
        display_name: str | None,
        avatar_url: str | None,
    ) -> dict:
        existing_user = self.find_by_firebase_uid_or_email(firebase_uid, email)
        payload = {
            "firebase_uid": firebase_uid,
            "email": email.lower() if email else None,
            "display_name": display_name,
            "avatar_url": avatar_url,
        }

        if existing_user:
            response = (
                self._require_client()
                .table("users")
                .update(payload)
                .eq("id", existing_user["id"])
                .execute()
            )
        else:
            response = self._require_client().table("users").insert(payload).execute()

        user = _first_row(response.data)
        if not user:
            raise AppException("Gagal menyimpan data pengguna.", status_code=500)

        self.ensure_user_profile(user["id"])
        return user

    def ensure_user_profile(self, user_id: str) -> None:
        response = (
            self._require_client()
            .table("user_profiles")
            .select("user_id")
            .eq("user_id", user_id)
            .limit(1)
            .execute()
        )
        if _first_row(response.data):
            return

        self._require_client().table("user_profiles").insert({"user_id": user_id}).execute()

    def _require_client(self):
        if self._client is None:
            raise AppException(
                "Supabase service client belum dikonfigurasi.",
                status_code=503,
            )
        return self._client


def _first_row(rows: list[dict] | None) -> dict | None:
    if not rows:
        return None
    return rows[0]
