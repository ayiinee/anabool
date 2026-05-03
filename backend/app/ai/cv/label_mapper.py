LABEL_MAP = {
    0: "diarrhea",
    1: "lack_of_water",
    2: "soft_poop",
    3: "normal",
    4: "unknown",
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

    return {
        "detected_class": detected_class,
        "risk_level": RISK_LEVEL_MAP.get(detected_class, "medium"),
        "default_action": DEFAULT_ACTION_MAP.get(detected_class, "education"),
    }