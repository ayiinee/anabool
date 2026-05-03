from pathlib import Path


def get_file_extension(filename: str) -> str:
    return Path(filename).suffix.lower()


def is_allowed_image(filename: str) -> bool:
    return get_file_extension(filename) in [".jpg", ".jpeg", ".png", ".webp"]