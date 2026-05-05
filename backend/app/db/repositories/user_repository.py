from app.integrations.supabase.supabase_client import get_supabase_service_client


class UserRepository:
    def __init__(self):
        self._client = get_supabase_service_client()

    def find_by_firebase_uid_or_email(
        self,
        *,
        firebase_uid: str,
        email: str | None,
    ) -> dict | None:
        if self._client is None:
            return None

        query = self._client.table("users").select("*").eq(
            "firebase_uid",
            firebase_uid,
        )
        response = query.execute()
        if response.data:
            return response.data[0]

        if not email:
            return None

        response = self._client.table("users").select("*").eq("email", email).execute()
        if response.data:
            return response.data[0]

        return None

    def create_or_update_from_auth_claims(
        self,
        *,
        firebase_uid: str,
        email: str | None,
        display_name: str | None,
        avatar_url: str | None,
    ) -> dict:
        if self._client is None:
            return {
                "id": firebase_uid,
                "firebase_uid": firebase_uid,
                "email": email,
                "display_name": display_name,
                "avatar_url": avatar_url,
                "role": "user",
                "is_pregnant": False,
                "meowpoints_balance": 0,
            }

        payload = {
            "firebase_uid": firebase_uid,
            "email": email,
            "display_name": display_name,
            "avatar_url": avatar_url,
        }
        response = self._client.table("users").upsert(
            payload,
            on_conflict="firebase_uid",
        ).execute()
        if response.data:
            return response.data[0]

        return {
            "id": firebase_uid,
            **payload,
            "role": "user",
            "is_pregnant": False,
            "meowpoints_balance": 0,
        }
