def load_fallback_knowledge(detected_class: str | None = None) -> list[dict[str, str]]:
    class_hint = detected_class or "unknown"

    return [
        {
            "title": "Panduan kebersihan dasar litter box",
            "content": (
                "Gunakan sarung tangan atau sekop khusus, masukkan limbah ke kantong tertutup, "
                "bersihkan area dengan sabun atau disinfektan aman untuk hewan, lalu cuci tangan."
            ),
        },
        {
            "title": "Pencegahan risiko toxoplasma",
            "content": (
                "Ibu hamil dan pengguna dengan imun rendah sebaiknya menghindari kontak langsung dengan "
                "feses kucing dan meminta bantuan orang lain bila memungkinkan."
            ),
        },
        {
            "title": f"Panduan tindakan untuk kelas {class_hint}",
            "content": (
                "Gunakan hasil scan sebagai indikasi awal untuk menentukan langkah Pick Up, Olah, atau Buang, "
                "dan konsultasikan ke tenaga profesional bila gejala berlanjut."
            ),
        },
    ]


def load_mock_knowledge(detected_class: str) -> list[dict[str, str]]:
    return load_fallback_knowledge(detected_class)
