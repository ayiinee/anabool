from supabase import create_client, Client
from app.core.config import settings


def get_supabase_client() -> Client | None:
    if not settings.SUPABASE_URL or not settings.SUPABASE_ANON_KEY:
        return None

    return create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)


def get_supabase_service_client() -> Client | None:
    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
        return None

    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY) 