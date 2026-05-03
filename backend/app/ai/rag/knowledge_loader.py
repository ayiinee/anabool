def load_mock_knowledge(detected_class: str) -> list[dict]:
    return [
        {
            "title": "Panduan pembersihan litter box",
            "content": "Gunakan sarung tangan, masker, dan hindari kontak langsung dengan feses/litter.",
        },
        {
            "title": "Panduan pembuangan aman",
            "content": "Masukkan limbah ke kantong tertutup dan bersihkan area dengan disinfektan yang aman.",
        },
        {
            "title": f"Modul terkait {detected_class}",
            "content": "Ikuti modul pencegahan sesuai hasil scan untuk mengurangi risiko paparan patogen.",
        },
    ]