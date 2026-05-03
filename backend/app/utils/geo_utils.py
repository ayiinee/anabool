def calculate_scan_points(risk_level: str) -> int:
    if risk_level == "high":
        return 15
    if risk_level == "medium":
        return 10
    return 5


def calculate_module_points(is_completed: bool) -> int:
    return 25 if is_completed else 0


def calculate_pickup_points(weight_g: int | None = None) -> int:
    if weight_g is None:
        return 50

    if weight_g >= 1000:
        return 100

    return 50