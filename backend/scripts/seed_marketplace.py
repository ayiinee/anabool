"""
Seed script untuk mengisi data marketplace di Supabase.

Menambahkan:
  - Kategori marketplace
  - User penjual (seller) sebagai contoh
  - Produk beserta gambar
  - Review contoh

Jalankan dari root backend:
    python -m scripts.seed_marketplace

Script ini idempotent: kategori di-upsert berdasarkan slug,
produk & seller hanya dibuat jika belum ada.
"""

from __future__ import annotations

import sys
import os
import uuid
from datetime import datetime, timezone

# Tambahkan backend root ke sys.path agar bisa import app.*
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.integrations.supabase.supabase_client import get_supabase_service_client


def main():
    client = get_supabase_service_client()
    if client is None:
        print("ERROR: Supabase client tidak tersedia. Pastikan .env sudah benar.")
        sys.exit(1)

    print("=== Seeding Marketplace Data ===\n")

    # ------------------------------------------------------------------ #
    # 1. Kategori Marketplace
    # ------------------------------------------------------------------ #
    categories = [
        {
            "name": "Makanan Kucing",
            "slug": "makanan-kucing",
            "description": "Makanan kering, makanan basah, dan camilan untuk kucing.",
            "icon_url": "https://img.icons8.com/fluency/96/cat-food.png",
            "display_order": 1,
            "is_active": True,
        },
        {
            "name": "Aksesoris Kucing",
            "slug": "aksesoris-kucing",
            "description": "Kalung, baju, topi, dan aksesoris lucu untuk kucing.",
            "icon_url": "https://img.icons8.com/fluency/96/pet-commands-stay.png",
            "display_order": 2,
            "is_active": True,
        },
        {
            "name": "Peralatan Kebersihan",
            "slug": "peralatan-kebersihan",
            "description": "Litter box, sekop pasir, dan alat kebersihan kucing lainnya.",
            "icon_url": "https://img.icons8.com/fluency/96/broom.png",
            "display_order": 3,
            "is_active": True,
        },
        {
            "name": "Kesehatan Kucing",
            "slug": "kesehatan-kucing",
            "description": "Vitamin, obat cacing, dan produk kesehatan kucing.",
            "icon_url": "https://img.icons8.com/fluency/96/heart-with-pulse.png",
            "display_order": 4,
            "is_active": True,
        },
        {
            "name": "Mainan Kucing",
            "slug": "mainan-kucing",
            "description": "Bola, tongkat bulu, dan mainan interaktif untuk kucing.",
            "icon_url": "https://img.icons8.com/fluency/96/cat-toy.png",
            "display_order": 5,
            "is_active": True,
        },
        {
            "name": "Tempat Tidur & Rumah Kucing",
            "slug": "tempat-tidur-kucing",
            "description": "Kasur, rumah kucing, cat tree, dan tempat istirahat.",
            "icon_url": "https://img.icons8.com/fluency/96/dog-house.png",
            "display_order": 6,
            "is_active": True,
        },
    ]

    print("1. Menyimpan kategori marketplace...")
    for cat in categories:
        client.table("marketplace_categories").upsert(
            cat, on_conflict="slug"
        ).execute()
        print(f"   ✓ {cat['name']}")

    # Ambil ulang kategori yang sudah tersimpan (untuk mendapatkan id)
    cat_response = client.table("marketplace_categories").select("*").order("display_order").execute()
    cat_map = {row["slug"]: row for row in cat_response.data}
    print(f"   Total kategori: {len(cat_map)}\n")

    # ------------------------------------------------------------------ #
    # 2. Seller Users (contoh)
    # ------------------------------------------------------------------ #
    sellers = [
        {
            "firebase_uid": "seed_seller_001",
            "email": "petshop.meow@example.com",
            "display_name": "PetShop Meow",
            "avatar_url": "https://api.dicebear.com/9.x/initials/svg?seed=PM&backgroundColor=f59e0b",
            "phone_number": "081234567890",
            "role": "user",
        },
        {
            "firebase_uid": "seed_seller_002",
            "email": "kucing.sehat@example.com",
            "display_name": "Kucing Sehat Store",
            "avatar_url": "https://api.dicebear.com/9.x/initials/svg?seed=KS&backgroundColor=10b981",
            "phone_number": "087654321098",
            "role": "user",
        },
        {
            "firebase_uid": "seed_seller_003",
            "email": "anabool.official@example.com",
            "display_name": "ANABOOL Official",
            "avatar_url": "https://api.dicebear.com/9.x/initials/svg?seed=AO&backgroundColor=6366f1",
            "phone_number": "089876543210",
            "role": "user",
        },
    ]

    # Buyer user untuk review
    buyer = {
        "firebase_uid": "seed_buyer_001",
        "email": "catlover@example.com",
        "display_name": "Cat Lover",
        "avatar_url": "https://api.dicebear.com/9.x/initials/svg?seed=CL&backgroundColor=ec4899",
        "phone_number": "081111222333",
        "role": "user",
    }

    print("2. Membuat user seller & buyer...")
    seller_map: dict[str, dict] = {}
    for seller in sellers:
        response = client.table("users").upsert(
            seller, on_conflict="firebase_uid"
        ).execute()
        user = response.data[0]
        seller_map[seller["firebase_uid"]] = user
        print(f"   ✓ Seller: {user['display_name']} (id={user['id']})")

    buyer_response = client.table("users").upsert(
        buyer, on_conflict="firebase_uid"
    ).execute()
    buyer_user = buyer_response.data[0]
    print(f"   ✓ Buyer: {buyer_user['display_name']} (id={buyer_user['id']})\n")

    # ------------------------------------------------------------------ #
    # 3. Produk Marketplace
    # ------------------------------------------------------------------ #
    seller1 = seller_map["seed_seller_001"]
    seller2 = seller_map["seed_seller_002"]
    seller3 = seller_map["seed_seller_003"]

    products_data = [
        # --- Makanan Kucing ---
        {
            "seller_id": seller1["id"],
            "category_id": cat_map["makanan-kucing"]["id"],
            "name": "Royal Canin Indoor 27 - 2kg",
            "description": "Makanan kering premium untuk kucing indoor dewasa. Membantu menjaga berat badan ideal dan kesehatan pencernaan kucing yang tinggal di dalam rumah. Mengandung L-Carnitine untuk metabolisme lemak.",
            "price_idr": 245000,
            "stock": 25,
            "unit": "pack",
            "wa_number": "081234567890",
            "wa_template": "Halo PetShop Meow, saya tertarik dengan {product_name} seharga Rp {price_idr}. Apakah masih tersedia?",
            "images": [
                "https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=600",
                "https://images.unsplash.com/photo-1574158622682-e40e69881006?w=600",
            ],
        },
        {
            "seller_id": seller2["id"],
            "category_id": cat_map["makanan-kucing"]["id"],
            "name": "Whiskas Tuna - 1.2kg",
            "description": "Makanan kucing rasa tuna yang disukai kucing. Diperkaya dengan omega 3 & 6 untuk bulu sehat dan berkilau. Cocok untuk kucing dewasa di atas 1 tahun.",
            "price_idr": 89000,
            "stock": 50,
            "unit": "pack",
            "wa_number": "087654321098",
            "wa_template": "Halo Kucing Sehat Store, saya ingin pesan {product_name}. Bisa COD?",
            "images": [
                "https://images.unsplash.com/photo-1615497001839-b0a0eac3274c?w=600",
            ],
        },
        {
            "seller_id": seller1["id"],
            "category_id": cat_map["makanan-kucing"]["id"],
            "name": "Me-O Creamy Treats Salmon - Box isi 20",
            "description": "Snack kucing creamy rasa salmon yang lezat. Bisa diberikan langsung atau dicampur dengan makanan kering. Satu box berisi 20 sachet.",
            "price_idr": 65000,
            "stock": 100,
            "unit": "box",
            "wa_number": "081234567890",
            "wa_template": "Halo, saya mau beli {product_name}. Ready stock?",
            "images": [
                "https://images.unsplash.com/photo-1526336024174-e58f5cdd8e13?w=600",
            ],
        },

        # --- Aksesoris Kucing ---
        {
            "seller_id": seller3["id"],
            "category_id": cat_map["aksesoris-kucing"]["id"],
            "name": "Kalung Kucing Anti Kutu Premium",
            "description": "Kalung kucing 2-in-1 yang berfungsi sebagai aksesoris sekaligus anti kutu. Bahan lembut dan aman untuk kulit kucing. Tersedia dalam berbagai warna pastel.",
            "price_idr": 35000,
            "stock": 75,
            "unit": "pcs",
            "wa_number": "089876543210",
            "wa_template": "Hai ANABOOL, mau order {product_name} dong!",
            "images": [
                "https://images.unsplash.com/photo-1548681528-6a5c45b66b42?w=600",
                "https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=600",
            ],
        },
        {
            "seller_id": seller3["id"],
            "category_id": cat_map["aksesoris-kucing"]["id"],
            "name": "Baju Kucing Lucu Motif Sailor",
            "description": "Baju kucing motif sailor yang menggemaskan. Bahan katun breathable agar kucing tetap nyaman. Ukuran S-L untuk berbagai ras.",
            "price_idr": 45000,
            "stock": 30,
            "unit": "pcs",
            "wa_number": "089876543210",
            "wa_template": "Hai ANABOOL, saya mau pesan {product_name} ukuran __ ya!",
            "images": [
                "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600",
            ],
        },

        # --- Peralatan Kebersihan ---
        {
            "seller_id": seller2["id"],
            "category_id": cat_map["peralatan-kebersihan"]["id"],
            "name": "Litter Box Tertutup Anti Bau - Large",
            "description": "Litter box tertutup ukuran besar dengan filter karbon aktif anti bau. Dilengkapi pintu flap agar privasi kucing terjaga. Mudah dibongkar pasang untuk dibersihkan.",
            "price_idr": 175000,
            "stock": 15,
            "unit": "pcs",
            "wa_number": "087654321098",
            "wa_template": "Halo, saya tertarik {product_name}. Bisa kirim ke alamat saya?",
            "images": [
                "https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=600",
            ],
        },
        {
            "seller_id": seller1["id"],
            "category_id": cat_map["peralatan-kebersihan"]["id"],
            "name": "Pasir Kucing Tofu Clump 7L - Lavender",
            "description": "Pasir kucing tofu yang ramah lingkungan dan flushable. Aroma lavender yang menenangkan. Daya serap tinggi dan mudah menggumpal.",
            "price_idr": 55000,
            "stock": 200,
            "unit": "pack",
            "wa_number": "081234567890",
            "wa_template": "Halo PetShop Meow, mau order {product_name} 3 pack ya!",
            "images": [
                "https://images.unsplash.com/photo-1606567595334-d39972c85dbe?w=600",
            ],
        },

        # --- Kesehatan Kucing ---
        {
            "seller_id": seller2["id"],
            "category_id": cat_map["kesehatan-kucing"]["id"],
            "name": "Obat Cacing Kucing Drontal Cat",
            "description": "Obat cacing untuk kucing dewasa. Efektif mengatasi cacing gelang, cacing pita, dan cacing tambang. Dosis 1 tablet per 4 kg berat badan.",
            "price_idr": 28000,
            "stock": 60,
            "unit": "tablet",
            "wa_number": "087654321098",
            "wa_template": "Halo, saya butuh {product_name}. Berapa harga untuk 2 tablet?",
            "images": [
                "https://images.unsplash.com/photo-1571566882372-1598d88abd90?w=600",
            ],
        },
        {
            "seller_id": seller3["id"],
            "category_id": cat_map["kesehatan-kucing"]["id"],
            "name": "Vitamin Bulu Kucing - Salmon Oil 100ml",
            "description": "Minyak ikan salmon murni untuk kucing. Kaya omega 3 & 6 yang membantu menjaga kesehatan bulu, kulit, dan sendi kucing. Cukup teteskan di makanan.",
            "price_idr": 85000,
            "stock": 40,
            "unit": "botol",
            "wa_number": "089876543210",
            "wa_template": "Hai ANABOOL, mau pesan {product_name}!",
            "images": [
                "https://images.unsplash.com/photo-1596854407944-bf87f6fdd49e?w=600",
            ],
        },

        # --- Mainan Kucing ---
        {
            "seller_id": seller1["id"],
            "category_id": cat_map["mainan-kucing"]["id"],
            "name": "Tongkat Bulu Mainan Kucing Interaktif",
            "description": "Tongkat mainan kucing dengan bulu sintetis berwarna-warni. Merangsang insting berburu kucing dan membantu kucing tetap aktif. Gagang ergonomis anti slip.",
            "price_idr": 25000,
            "stock": 80,
            "unit": "pcs",
            "wa_number": "081234567890",
            "wa_template": "Halo, saya mau pesan {product_name}!",
            "images": [
                "https://images.unsplash.com/photo-1595433707802-6b2626ef1c91?w=600",
            ],
        },
        {
            "seller_id": seller3["id"],
            "category_id": cat_map["mainan-kucing"]["id"],
            "name": "Bola Catnip Mainan Kucing - Set 3pcs",
            "description": "Set 3 bola catnip organik yang aman untuk kucing. Aroma catnip alami membuat kucing bersemangat bermain. Warna cerah dan menarik perhatian kucing.",
            "price_idr": 32000,
            "stock": 55,
            "unit": "set",
            "wa_number": "089876543210",
            "wa_template": "Hai, mau beli {product_name}. Masih ada?",
            "images": [
                "https://images.unsplash.com/photo-1592194996308-7b43878e84a6?w=600",
                "https://images.unsplash.com/photo-1543852786-1cf6624b9987?w=600",
            ],
        },

        # --- Tempat Tidur & Rumah Kucing ---
        {
            "seller_id": seller2["id"],
            "category_id": cat_map["tempat-tidur-kucing"]["id"],
            "name": "Cat Tree Tower 3 Tingkat - Abu-abu",
            "description": "Cat tree 3 tingkat dengan tiang garukan sisal, tempat tidur empuk, dan mainan bola gantung. Tinggi 120cm. Cocok untuk 1-2 kucing. Kokoh dan stabil.",
            "price_idr": 450000,
            "stock": 8,
            "unit": "pcs",
            "wa_number": "087654321098",
            "wa_template": "Halo Kucing Sehat Store, saya tertarik dengan {product_name}. Bisa kirim ekspedisi?",
            "images": [
                "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=600",
            ],
        },
        {
            "seller_id": seller1["id"],
            "category_id": cat_map["tempat-tidur-kucing"]["id"],
            "name": "Kasur Kucing Donut Bulu Lembut - Pink",
            "description": "Kasur kucing model donut dengan bulu sherpa super lembut. Desain melingkar memberikan rasa aman untuk kucing. Diameter 50cm, bisa dicuci mesin.",
            "price_idr": 120000,
            "stock": 20,
            "unit": "pcs",
            "wa_number": "081234567890",
            "wa_template": "Halo PetShop Meow, saya mau order {product_name}!",
            "images": [
                "https://images.unsplash.com/photo-1495360010541-f48722b34f7d?w=600",
            ],
        },
    ]

    print("3. Menyimpan produk marketplace...")
    product_ids: list[str] = []
    for product_data in products_data:
        images = product_data.pop("images", [])

        # Cek apakah produk dengan nama & seller yang sama sudah ada
        existing = (
            client.table("products")
            .select("id")
            .eq("name", product_data["name"])
            .eq("seller_id", product_data["seller_id"])
            .limit(1)
            .execute()
        )
        if existing.data:
            product_id = existing.data[0]["id"]
            print(f"   ○ Sudah ada: {product_data['name']} (id={product_id})")
        else:
            response = client.table("products").insert(product_data).execute()
            product_id = response.data[0]["id"]
            print(f"   ✓ Dibuat: {product_data['name']} (id={product_id})")

        product_ids.append(product_id)

        # Simpan gambar (hapus dulu yang lama untuk idempotency)
        client.table("product_images").delete().eq("product_id", product_id).execute()
        if images:
            image_payload = [
                {
                    "product_id": product_id,
                    "image_url": url,
                    "display_order": idx,
                }
                for idx, url in enumerate(images)
            ]
            client.table("product_images").insert(image_payload).execute()

    print(f"   Total produk: {len(product_ids)}\n")

    # ------------------------------------------------------------------ #
    # 4. Review Contoh
    # ------------------------------------------------------------------ #
    reviews_data = [
        # Review untuk produk pertama (Royal Canin)
        {"product_id": product_ids[0], "user_id": buyer_user["id"], "rating": 5, "body": "Kucing saya sangat suka! Sudah repeat order 3 kali. Pengiriman juga cepat."},
        {"product_id": product_ids[0], "user_id": seller2["id"], "rating": 4, "body": "Produk bagus, kemasan rapi. Kucing saya jadi lebih aktif setelah makan ini."},

        # Review untuk Whiskas
        {"product_id": product_ids[1], "user_id": buyer_user["id"], "rating": 4, "body": "Harga terjangkau, kucing suka banget. Recommended!"},

        # Review untuk Kalung Anti Kutu
        {"product_id": product_ids[3], "user_id": buyer_user["id"], "rating": 5, "body": "Kalung bagus, kutu kucing jadi hilang dalam seminggu. Warnanya juga cantik!"},
        {"product_id": product_ids[3], "user_id": seller1["id"], "rating": 4, "body": "Kalungnya awet dan tahan lama. Kucing nyaman pakai ini."},

        # Review untuk Litter Box
        {"product_id": product_ids[5], "user_id": buyer_user["id"], "rating": 5, "body": "Litter box terbaik yang pernah saya beli! Anti bau benar-benar bekerja. Filter carbonnya efektif."},

        # Review untuk Tongkat Bulu
        {"product_id": product_ids[9], "user_id": buyer_user["id"], "rating": 5, "body": "Kucing saya langsung excited! Mainan yang simple tapi efektif."},
        {"product_id": product_ids[9], "user_id": seller3["id"], "rating": 4, "body": "Kualitas bagus, bulu tidak mudah rontok."},

        # Review untuk Cat Tree
        {"product_id": product_ids[11], "user_id": buyer_user["id"], "rating": 5, "body": "Cat tree yang kokoh dan bagus. Kucing saya betah bermain di sini seharian!"},

        # Review untuk Kasur Donut
        {"product_id": product_ids[12], "user_id": buyer_user["id"], "rating": 4, "body": "Kasur lembut dan empuk. Kucing saya langsung tidur pulas begitu dicoba. Recommended!"},
    ]

    print("4. Menyimpan review contoh...")
    for review in reviews_data:
        # Cek apakah review dari user yang sama untuk produk yang sama sudah ada
        existing = (
            client.table("product_reviews")
            .select("id")
            .eq("product_id", review["product_id"])
            .eq("user_id", review["user_id"])
            .limit(1)
            .execute()
        )
        if existing.data:
            print(f"   ○ Review sudah ada untuk product_id={review['product_id'][:8]}...")
        else:
            client.table("product_reviews").insert(review).execute()
            print(f"   ✓ Review: ★{review['rating']} untuk product_id={review['product_id'][:8]}...")

    # ------------------------------------------------------------------ #
    # 5. Update avg_rating pada produk yang memiliki review
    # ------------------------------------------------------------------ #
    print("\n5. Update avg_rating produk...")
    from statistics import mean

    for pid in product_ids:
        reviews_resp = (
            client.table("product_reviews")
            .select("rating")
            .eq("product_id", pid)
            .execute()
        )
        ratings = [int(r["rating"]) for r in reviews_resp.data or []]
        if ratings:
            avg = round(mean(ratings), 2)
            client.table("products").update({"avg_rating": avg}).eq("id", pid).execute()
            print(f"   ✓ product_id={pid[:8]}... avg_rating={avg} ({len(ratings)} reviews)")

    print("\n=== Seeding selesai! ===")
    print(f"   Kategori : {len(cat_map)}")
    print(f"   Seller   : {len(seller_map)}")
    print(f"   Produk   : {len(product_ids)}")
    print(f"   Review   : {len(reviews_data)}")


if __name__ == "__main__":
    main()
