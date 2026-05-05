LABEL_MAP = {
    0: "diarrhea",
    1: "lack_of_water",
    2: "soft_poop",
    3: "normal",
    4: "unknown",
}

LABEL_ALIASES = {
    "diarrhea": "diarrhea",
    "diarrhoea": "diarrhea",
    "diare": "diarrhea",
    "mencret": "diarrhea",
    "runny": "diarrhea",
    "watery": "diarrhea",
    "lack_of_water": "lack_of_water",
    "lack of water": "lack_of_water",
    "kurang_air": "lack_of_water",
    "kurang air": "lack_of_water",
    "kering": "lack_of_water",
    "dehydrated": "lack_of_water",
    "dry": "lack_of_water",
    "hard": "lack_of_water",
    "soft_poop": "soft_poop",
    "soft poop": "soft_poop",
    "soft-poop": "soft_poop",
    "lembek": "soft_poop",
    "soft": "soft_poop",
    "normal": "normal",
    "healthy": "normal",
    "sehat": "normal",
    "unknown": "unknown",
}

RISK_LEVEL_MAP = {
    "diarrhea": "high",
    "lack_of_water": "medium",
    "soft_poop": "medium",
    "normal": "low",
    "unknown": "medium",
}

DEFAULT_ACTION_MAP = {
    "diarrhea": "dispose",
    "lack_of_water": "process",
    "soft_poop": "process",
    "normal": "pickup",
    "unknown": "education",
}


def map_label(index: int) -> dict:
    detected_class = LABEL_MAP.get(index, "unknown")
    return map_detected_class(detected_class)


def normalize_label(label: str | None) -> str:
    if not label:
        return "unknown"

    normalized = label.strip().lower().replace("-", "_")
    normalized = "_".join(normalized.split())
    return LABEL_ALIASES.get(normalized, normalized if normalized in RISK_LEVEL_MAP else "unknown")


def map_detected_class(label: str | None) -> dict:
    detected_class = normalize_label(label)

    return {
        "detected_class": detected_class,
        "risk_level": RISK_LEVEL_MAP.get(detected_class, "medium"),
        "default_action": DEFAULT_ACTION_MAP.get(detected_class, "education"),
    }
