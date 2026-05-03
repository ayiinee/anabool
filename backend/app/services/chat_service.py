def mock_start_chat_from_scan(scan_id: str) -> dict:
    return {
        "scan_id": scan_id,
        "session_type": "scan_result",
        "assistant_name": "Si Ana",
        "messages": [
            {
                "role": "user",
                "message_type": "scan_result",
                "content": "Ini hasil scan feses/litter yang baru saja diambil.",
            },
            {
                "role": "assistant",
                "message_type": "text",
                "content": "Aku sudah membaca hasil scan kamu. Pilih tindakan yang ingin kamu lakukan.",
            },
            {
                "role": "assistant",
                "message_type": "cta_cards",
                "content": "Pilih salah satu tindakan preventif.",
                "cards": [
                    {
                        "card_type": "pickup",
                        "title": "Pick Up",
                        "cta_label": "Jadwalkan Pick-up",
                    },
                    {
                        "card_type": "process",
                        "title": "Olah",
                        "cta_label": "Lihat Cara Olah",
                    },
                    {
                        "card_type": "dispose",
                        "title": "Buang",
                        "cta_label": "Lihat Cara Buang",
                    },
                ],
            },
        ],
    }