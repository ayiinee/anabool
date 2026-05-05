import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient

from app.api.v1.endpoints import marketplace_routes
from app.main import app
from app.services.marketplace_service import MarketplaceService


client = TestClient(app)


def test_list_marketplace_products_returns_enriched_catalog(monkeypatch):
    repository = FakeMarketplaceRepository()
    monkeypatch.setattr(marketplace_routes, "_service", MarketplaceService(repository))

    response = client.get(
        "/api/v1/marketplace/products",
        params={"category_slug": "litter", "limit": 12, "offset": 0},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True
    assert body["data"]["total"] == 1
    assert repository.last_product_filters["category_slug"] == "litter"

    product = body["data"]["items"][0]
    assert product["name"] == "Pasir Kucing Organik"
    assert product["category"]["slug"] == "litter"
    assert product["seller"]["display_name"] == "Toko Ana"
    assert product["images"][0]["image_url"] == "https://example.com/product.png"
    assert product["review_count"] == 2


def test_create_marketplace_product_uses_seller_id_fallback(monkeypatch):
    repository = FakeMarketplaceRepository()
    monkeypatch.setattr(marketplace_routes, "_service", MarketplaceService(repository))

    response = client.post(
        "/api/v1/marketplace/products",
        json={
            "seller_id": "seller-1",
            "category_id": "category-1",
            "name": "Vitamin Bulu",
            "price_idr": 25000,
            "stock": 5,
            "wa_number": "081234567890",
            "image_urls": ["https://example.com/vitamin.png"],
        },
    )

    assert response.status_code == 200
    assert repository.created_product["seller_id"] == "seller-1"
    assert repository.created_product["category_id"] == "category-1"
    assert response.json()["data"]["name"] == "Vitamin Bulu"


def test_create_marketplace_review_uses_user_id_fallback(monkeypatch):
    repository = FakeMarketplaceRepository()
    monkeypatch.setattr(marketplace_routes, "_service", MarketplaceService(repository))

    response = client.post(
        "/api/v1/marketplace/products/product-1/reviews",
        json={"user_id": "buyer-1", "rating": 5, "body": "Bagus dan cepat."},
    )

    assert response.status_code == 200
    assert repository.created_review == {
        "product_id": "product-1",
        "user_id": "buyer-1",
        "rating": 5,
        "body": "Bagus dan cepat.",
    }
    assert response.json()["data"]["rating"] == 5


def test_create_whatsapp_order_log_returns_deeplink(monkeypatch):
    repository = FakeMarketplaceRepository()
    monkeypatch.setattr(marketplace_routes, "_service", MarketplaceService(repository))

    response = client.post(
        "/api/v1/marketplace/products/product-1/whatsapp-order-logs",
        json={"user_id": "buyer-1"},
    )

    assert response.status_code == 200
    data = response.json()["data"]
    assert data["wa_number"] == "6281234567890"
    assert data["template_message"] == "Halo, saya tertarik dengan Pasir Kucing Organik."
    assert data["wa_url"].startswith("https://wa.me/6281234567890?text=")
    assert repository.created_order_log["seller_id"] == "seller-1"


def test_marketplace_product_not_found_returns_404(monkeypatch):
    repository = FakeMarketplaceRepository()
    monkeypatch.setattr(marketplace_routes, "_service", MarketplaceService(repository))

    response = client.get("/api/v1/marketplace/products/missing-product")

    assert response.status_code == 404
    assert response.json()["success"] is False
    assert response.json()["message"] == "Produk marketplace tidak ditemukan."


class FakeMarketplaceRepository:
    def __init__(self):
        self.last_product_filters = None
        self.created_product = None
        self.created_review = None
        self.created_order_log = None

    @property
    def is_available(self):
        return True

    def list_categories(self, *, active_only=True):
        return [
            {
                "id": "category-1",
                "name": "Pasir",
                "slug": "litter",
                "description": "Pasir dan kebutuhan litter box.",
                "icon_url": None,
                "display_order": 1,
                "is_active": True,
            }
        ]

    def category_exists(self, category_id):
        return category_id == "category-1"

    def list_products(
        self,
        *,
        q=None,
        category_id=None,
        category_slug=None,
        seller_id=None,
        min_price_idr=None,
        max_price_idr=None,
        in_stock=None,
        sort="newest",
        limit=20,
        offset=0,
        active_only=True,
    ):
        self.last_product_filters = {
            "q": q,
            "category_id": category_id,
            "category_slug": category_slug,
            "seller_id": seller_id,
            "min_price_idr": min_price_idr,
            "max_price_idr": max_price_idr,
            "in_stock": in_stock,
            "sort": sort,
            "limit": limit,
            "offset": offset,
            "active_only": active_only,
        }
        return {"items": [self._product()], "total": 1}

    def get_product(self, product_id, *, active_only=True):
        if product_id != "product-1":
            return None
        product = self._product()
        product["reviews"] = [
            {
                "id": "review-1",
                "product_id": "product-1",
                "user_id": "buyer-1",
                "rating": 5,
                "body": "Bagus.",
                "created_at": "2026-05-05T00:00:00+00:00",
                "user": {
                    "id": "buyer-1",
                    "display_name": "Buyer Ana",
                    "avatar_url": None,
                    "phone_number": None,
                },
            }
        ]
        return product

    def create_product(
        self,
        *,
        seller_id,
        category_id,
        name,
        description,
        price_idr,
        stock,
        unit,
        wa_number,
        wa_template,
        image_urls,
    ):
        self.created_product = {
            "seller_id": seller_id,
            "category_id": category_id,
            "name": name,
            "description": description,
            "price_idr": price_idr,
            "stock": stock,
            "unit": unit,
            "wa_number": wa_number,
            "wa_template": wa_template,
            "image_urls": image_urls,
        }
        product = self._product()
        product.update(
            {
                "id": "product-created",
                "seller_id": seller_id,
                "category_id": category_id,
                "name": name,
                "description": description,
                "price_idr": price_idr,
                "stock": stock,
                "unit": unit,
                "wa_number": wa_number,
                "wa_template": wa_template,
                "images": [
                    {
                        "id": "image-created",
                        "product_id": "product-created",
                        "image_url": image_urls[0],
                        "storage_path": None,
                        "display_order": 0,
                        "created_at": "2026-05-05T00:00:00+00:00",
                    }
                ],
            }
        )
        return product

    def create_review(self, *, product_id, user_id, rating, body):
        self.created_review = {
            "product_id": product_id,
            "user_id": user_id,
            "rating": rating,
            "body": body,
        }
        return {
            "id": "review-created",
            "product_id": product_id,
            "user_id": user_id,
            "rating": rating,
            "body": body,
            "created_at": "2026-05-05T00:00:00+00:00",
        }

    def create_whatsapp_order_log(
        self,
        *,
        user_id,
        product_id,
        seller_id,
        template_message,
    ):
        self.created_order_log = {
            "user_id": user_id,
            "product_id": product_id,
            "seller_id": seller_id,
            "template_message": template_message,
        }
        return {
            "id": "order-log-1",
            "clicked_at": "2026-05-05T00:00:00+00:00",
        }

    def _product(self):
        return {
            "id": "product-1",
            "seller_id": "seller-1",
            "category_id": "category-1",
            "name": "Pasir Kucing Organik",
            "description": "Ramah lingkungan.",
            "price_idr": 49000,
            "stock": 12,
            "unit": "pack",
            "wa_number": "081234567890",
            "wa_template": "Halo, saya tertarik dengan {product_name}.",
            "avg_rating": 4.8,
            "review_count": 2,
            "is_active": True,
            "created_at": "2026-05-05T00:00:00+00:00",
            "updated_at": "2026-05-05T00:00:00+00:00",
            "category": {
                "id": "category-1",
                "name": "Pasir",
                "slug": "litter",
                "description": "Pasir dan kebutuhan litter box.",
                "icon_url": None,
                "display_order": 1,
                "is_active": True,
            },
            "seller": {
                "id": "seller-1",
                "display_name": "Toko Ana",
                "avatar_url": None,
                "phone_number": "081234567890",
            },
            "images": [
                {
                    "id": "image-1",
                    "product_id": "product-1",
                    "image_url": "https://example.com/product.png",
                    "storage_path": None,
                    "display_order": 0,
                    "created_at": "2026-05-05T00:00:00+00:00",
                }
            ],
            "reviews": [],
        }
