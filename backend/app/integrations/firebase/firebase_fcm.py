def verify_firebase_token(token: str) -> dict:
    # MVP placeholder.
    # Nanti diganti dengan firebase_admin.auth.verify_id_token(token)
    return {
        "uid": "mock_firebase_uid",
        "email": "user@example.com",
    }