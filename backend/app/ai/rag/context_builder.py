def build_scan_context(scan_result: dict, user_profile: dict | None = None) -> str:
    user_profile = user_profile or {}

    return f"""
Hasil scan:
- Detected class: {scan_result.get("detected_class")}
- Confidence score: {scan_result.get("confidence_score")}
- Risk level: {scan_result.get("risk_level")}

Profil user:
- Safety mode: {user_profile.get("safety_mode", False)}
- Risk group: {user_profile.get("risk_group", "general")}
"""