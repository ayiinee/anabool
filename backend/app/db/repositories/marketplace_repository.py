from __future__ import annotations

from collections import defaultdict
from statistics import mean
from typing import Any

from app.integrations.supabase.supabase_client import get_supabase_service_client


class MarketplaceRepository:
    def __init__(self):
        self._client = get_supabase_service_client()

    @property
    def is_available(self) -> bool:
        return self._client is not None

    def list_categories(self, *, active_only: bool = True) -> list[dict]:
        if self._client is None:
            return []

        query = self._client.table("marketplace_categories").select("*")
        if active_only:
            query = query.eq("is_active", True)

        response = query.order("display_order").order("name").execute()
        return response.data or []

    def category_exists(self, category_id: str) -> bool:
        if self._client is None:
            return False

        response = (
            self._client.table("marketplace_categories")
            .select("id")
            .eq("id", category_id)
            .eq("is_active", True)
            .limit(1)
            .execute()
        )
        return bool(response.data)

    def list_products(
        self,
        *,
        q: str | None = None,
        category_id: str | None = None,
        category_slug: str | None = None,
        seller_id: str | None = None,
        min_price_idr: int | None = None,
        max_price_idr: int | None = None,
        in_stock: bool | None = None,
        sort: str = "newest",
        limit: int = 20,
        offset: int = 0,
        active_only: bool = True,
    ) -> dict[str, Any]:
        if self._client is None:
            return {"items": [], "total": 0}

        resolved_category_id = category_id
        if category_slug:
            category = self._find_category_by_slug(category_slug)
            if category is None:
                return {"items": [], "total": 0}
            resolved_category_id = str(category["id"])

        query = self._client.table("products").select("*", count="exact")
        if active_only:
            query = query.eq("is_active", True)
        if resolved_category_id:
            query = query.eq("category_id", resolved_category_id)
        if seller_id:
            query = query.eq("seller_id", seller_id)
        if q:
            query = query.ilike("name", f"%{q.strip()}%")
        if min_price_idr is not None:
            query = query.gte("price_idr", min_price_idr)
        if max_price_idr is not None:
            query = query.lte("price_idr", max_price_idr)
        if in_stock is True:
            query = query.gt("stock", 0)
        elif in_stock is False:
            query = query.eq("stock", 0)

        query = _apply_product_sort(query, sort)
        response = query.range(offset, offset + limit - 1).execute()
        rows = response.data or []
        return {
            "items": self._enrich_products(rows),
            "total": response.count if response.count is not None else len(rows),
        }

    def get_product(self, product_id: str, *, active_only: bool = True) -> dict | None:
        if self._client is None:
            return None

        query = self._client.table("products").select("*").eq("id", product_id)
        if active_only:
            query = query.eq("is_active", True)

        response = query.limit(1).execute()
        if not response.data:
            return None

        products = self._enrich_products(response.data)
        if not products:
            return None

        product = products[0]
        product["reviews"] = self.list_reviews(product_id, limit=10)
        return product

    def create_product(
        self,
        *,
        seller_id: str,
        category_id: str,
        name: str,
        description: str | None,
        price_idr: int,
        stock: int,
        unit: str | None,
        wa_number: str | None,
        wa_template: str | None,
        image_urls: list[str],
    ) -> dict:
        if self._client is None:
            raise RuntimeError("Supabase client is not configured.")

        product_payload = {
            "seller_id": seller_id,
            "category_id": category_id,
            "name": name,
            "description": description,
            "price_idr": price_idr,
            "stock": stock,
            "unit": unit,
            "wa_number": wa_number,
            "wa_template": wa_template,
        }
        response = self._client.table("products").insert(product_payload).execute()
        product = response.data[0]

        image_payload = [
            {
                "product_id": product["id"],
                "image_url": image_url,
                "display_order": index,
            }
            for index, image_url in enumerate(image_urls)
            if image_url.strip()
        ]
        if image_payload:
            self._client.table("product_images").insert(image_payload).execute()

        created = self.get_product(str(product["id"]))
        return created or product

    def create_review(
        self,
        *,
        product_id: str,
        user_id: str,
        rating: int,
        body: str | None,
    ) -> dict:
        if self._client is None:
            raise RuntimeError("Supabase client is not configured.")

        response = (
            self._client.table("product_reviews")
            .insert(
                {
                    "product_id": product_id,
                    "user_id": user_id,
                    "rating": rating,
                    "body": body,
                }
            )
            .execute()
        )
        review = response.data[0]
        stats = self.get_review_stats(product_id)
        if stats["count"] > 0:
            self._client.table("products").update({"avg_rating": stats["avg_rating"]}).eq(
                "id",
                product_id,
            ).execute()
        return review

    def list_reviews(self, product_id: str, *, limit: int = 10) -> list[dict]:
        if self._client is None:
            return []

        response = (
            self._client.table("product_reviews")
            .select("*")
            .eq("product_id", product_id)
            .order("created_at", desc=True)
            .limit(limit)
            .execute()
        )
        reviews = response.data or []
        user_ids = {str(row["user_id"]) for row in reviews if row.get("user_id")}
        users_by_id = self._fetch_users(user_ids)
        for row in reviews:
            row["user"] = users_by_id.get(str(row.get("user_id")))
        return reviews

    def get_review_stats(self, product_id: str) -> dict[str, int | float | None]:
        if self._client is None:
            return {"count": 0, "avg_rating": None}

        response = (
            self._client.table("product_reviews")
            .select("rating")
            .eq("product_id", product_id)
            .execute()
        )
        ratings = [int(row["rating"]) for row in response.data or []]
        if not ratings:
            return {"count": 0, "avg_rating": None}
        return {"count": len(ratings), "avg_rating": round(mean(ratings), 2)}

    def create_whatsapp_order_log(
        self,
        *,
        user_id: str,
        product_id: str,
        seller_id: str,
        template_message: str,
    ) -> dict:
        if self._client is None:
            raise RuntimeError("Supabase client is not configured.")

        response = (
            self._client.table("whatsapp_order_logs")
            .insert(
                {
                    "user_id": user_id,
                    "product_id": product_id,
                    "seller_id": seller_id,
                    "template_message": template_message,
                }
            )
            .execute()
        )
        return response.data[0]

    def _find_category_by_slug(self, slug: str) -> dict | None:
        if self._client is None:
            return None

        response = (
            self._client.table("marketplace_categories")
            .select("*")
            .eq("slug", slug)
            .eq("is_active", True)
            .limit(1)
            .execute()
        )
        if not response.data:
            return None
        return response.data[0]

    def _enrich_products(self, rows: list[dict]) -> list[dict]:
        if not rows:
            return []

        product_ids = {str(row["id"]) for row in rows}
        category_ids = {str(row["category_id"]) for row in rows if row.get("category_id")}
        seller_ids = {str(row["seller_id"]) for row in rows if row.get("seller_id")}

        categories_by_id = self._fetch_categories(category_ids)
        sellers_by_id = self._fetch_users(seller_ids)
        images_by_product_id = self._fetch_images(product_ids)
        stats_by_product_id = self._fetch_review_stats(product_ids)

        enriched = []
        for row in rows:
            product = dict(row)
            product_id = str(product["id"])
            product["category"] = categories_by_id.get(str(product.get("category_id")))
            product["seller"] = sellers_by_id.get(str(product.get("seller_id")))
            product["images"] = images_by_product_id.get(product_id, [])
            stats = stats_by_product_id.get(product_id, {"count": 0, "avg_rating": None})
            product["review_count"] = stats["count"]
            if product.get("avg_rating") is None:
                product["avg_rating"] = stats["avg_rating"]
            enriched.append(product)
        return enriched

    def _fetch_categories(self, category_ids: set[str]) -> dict[str, dict]:
        if self._client is None or not category_ids:
            return {}

        response = (
            self._client.table("marketplace_categories")
            .select("*")
            .in_("id", list(category_ids))
            .execute()
        )
        return {str(row["id"]): row for row in response.data or []}

    def _fetch_users(self, user_ids: set[str]) -> dict[str, dict]:
        if self._client is None or not user_ids:
            return {}

        response = (
            self._client.table("users")
            .select("id,display_name,avatar_url,phone_number")
            .in_("id", list(user_ids))
            .execute()
        )
        return {str(row["id"]): row for row in response.data or []}

    def _fetch_images(self, product_ids: set[str]) -> dict[str, list[dict]]:
        if self._client is None or not product_ids:
            return {}

        response = (
            self._client.table("product_images")
            .select("*")
            .in_("product_id", list(product_ids))
            .order("display_order")
            .execute()
        )
        images_by_product_id: dict[str, list[dict]] = defaultdict(list)
        for row in response.data or []:
            images_by_product_id[str(row["product_id"])].append(row)
        return images_by_product_id

    def _fetch_review_stats(self, product_ids: set[str]) -> dict[str, dict]:
        if self._client is None or not product_ids:
            return {}

        response = (
            self._client.table("product_reviews")
            .select("product_id,rating")
            .in_("product_id", list(product_ids))
            .execute()
        )
        ratings_by_product_id: dict[str, list[int]] = defaultdict(list)
        for row in response.data or []:
            ratings_by_product_id[str(row["product_id"])].append(int(row["rating"]))

        return {
            product_id: {
                "count": len(ratings),
                "avg_rating": round(mean(ratings), 2) if ratings else None,
            }
            for product_id, ratings in ratings_by_product_id.items()
        }


def _apply_product_sort(query, sort: str):
    if sort == "price_asc":
        return query.order("price_idr")
    if sort == "price_desc":
        return query.order("price_idr", desc=True)
    if sort == "rating":
        return query.order("avg_rating", desc=True).order("created_at", desc=True)
    if sort == "oldest":
        return query.order("created_at")
    return query.order("created_at", desc=True)
