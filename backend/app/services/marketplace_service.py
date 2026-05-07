from __future__ import annotations

from decimal import Decimal
from urllib.parse import quote

from app.core.exceptions import AppException
from app.db.repositories.marketplace_repository import MarketplaceRepository
from app.db.schemas.marketplace_schema import (
    MarketplaceCategory,
    MarketplaceProduct,
    ProductCreateRequest,
    ProductListResult,
    ProductReview,
    ProductReviewCreateRequest,
    WhatsAppOrderLogCreateRequest,
    WhatsAppOrderLogResult,
)
from app.db.schemas.user_schema import AuthenticatedUser


class MarketplaceService:
    def __init__(self, repository: MarketplaceRepository | None = None):
        self._repository = repository or MarketplaceRepository()

    def list_categories(self) -> list[MarketplaceCategory]:
        rows = self._repository.list_categories(active_only=True)
        return [MarketplaceCategory.model_validate(row) for row in rows]

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
    ) -> ProductListResult:
        if min_price_idr is not None and max_price_idr is not None:
            if min_price_idr > max_price_idr:
                raise AppException("Harga minimum tidak boleh lebih besar dari harga maksimum.")

        result = self._repository.list_products(
            q=_clean_optional(q),
            category_id=_clean_optional(category_id),
            category_slug=_clean_optional(category_slug),
            seller_id=_clean_optional(seller_id),
            min_price_idr=min_price_idr,
            max_price_idr=max_price_idr,
            in_stock=in_stock,
            sort=sort,
            limit=limit,
            offset=offset,
            active_only=True,
        )
        return ProductListResult(
            items=[_product_from_row(row) for row in result["items"]],
            limit=limit,
            offset=offset,
            total=int(result.get("total") or 0),
        )

    def get_product(self, product_id: str) -> MarketplaceProduct:
        row = self._repository.get_product(product_id, active_only=True)
        if row is None:
            raise AppException("Produk marketplace tidak ditemukan.", status_code=404)
        return _product_from_row(row)

    def list_reviews(self, product_id: str, *, limit: int = 10) -> list[ProductReview]:
        self.get_product(product_id)
        rows = self._repository.list_reviews(product_id, limit=limit)
        return [
            ProductReview.model_validate(_normalize_numbers(row))
            for row in rows
        ]

    def create_product(
        self,
        request: ProductCreateRequest,
        *,
        authenticated_user: AuthenticatedUser | None = None,
    ) -> MarketplaceProduct:
        self._require_storage()
        seller_id = authenticated_user.id if authenticated_user is not None else request.seller_id
        if not seller_id:
            raise AppException("Login diperlukan untuk membuat produk.", status_code=401)
        if not self._repository.category_exists(request.category_id):
            raise AppException("Kategori marketplace tidak ditemukan.", status_code=404)

        row = self._repository.create_product(
            seller_id=seller_id,
            category_id=request.category_id,
            name=request.name.strip(),
            description=_clean_optional(request.description),
            price_idr=request.price_idr,
            stock=request.stock,
            unit=_clean_optional(request.unit),
            wa_number=_clean_optional(request.wa_number),
            wa_template=_clean_optional(request.wa_template),
            image_urls=[url.strip() for url in request.image_urls if url.strip()],
        )
        return _product_from_row(row)

    def create_review(
        self,
        product_id: str,
        request: ProductReviewCreateRequest,
        *,
        authenticated_user: AuthenticatedUser | None = None,
    ) -> ProductReview:
        self._require_storage()
        user_id = authenticated_user.id if authenticated_user is not None else request.user_id
        if not user_id:
            raise AppException("Login diperlukan untuk memberi ulasan.", status_code=401)
        self.get_product(product_id)

        row = self._repository.create_review(
            product_id=product_id,
            user_id=user_id,
            rating=request.rating,
            body=_clean_optional(request.body),
        )
        return ProductReview.model_validate(_normalize_numbers(row))

    def create_whatsapp_order_log(
        self,
        product_id: str,
        request: WhatsAppOrderLogCreateRequest,
        *,
        authenticated_user: AuthenticatedUser | None = None,
    ) -> WhatsAppOrderLogResult:
        self._require_storage()
        user_id = authenticated_user.id if authenticated_user is not None else request.user_id
        if not user_id:
            raise AppException("Login diperlukan untuk mencatat pesanan WhatsApp.", status_code=401)

        product = self.get_product(product_id)
        wa_number = _normalize_wa_number(product.wa_number)
        if wa_number is None:
            raise AppException("Nomor WhatsApp penjual belum tersedia.", status_code=400)

        template_message = _format_whatsapp_message(
            request.template_message or product.wa_template,
            product,
        )
        log = self._repository.create_whatsapp_order_log(
            user_id=user_id,
            product_id=product.id,
            seller_id=product.seller_id,
            template_message=template_message,
        )
        return WhatsAppOrderLogResult(
            id=str(log["id"]) if log.get("id") else None,
            product_id=product.id,
            seller_id=product.seller_id,
            user_id=user_id,
            wa_number=wa_number,
            template_message=template_message,
            wa_url=f"https://wa.me/{wa_number}?text={quote(template_message)}",
            clicked_at=log.get("clicked_at"),
        )

    def _require_storage(self) -> None:
        if not self._repository.is_available:
            raise AppException(
                "Supabase marketplace belum dikonfigurasi di backend.",
                status_code=503,
            )


def list_categories() -> list[MarketplaceCategory]:
    return MarketplaceService().list_categories()


def list_products(
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
) -> ProductListResult:
    return MarketplaceService().list_products(
        q=q,
        category_id=category_id,
        category_slug=category_slug,
        seller_id=seller_id,
        min_price_idr=min_price_idr,
        max_price_idr=max_price_idr,
        in_stock=in_stock,
        sort=sort,
        limit=limit,
        offset=offset,
    )


def _product_from_row(row: dict) -> MarketplaceProduct:
    return MarketplaceProduct.model_validate(_normalize_numbers(row))


def _normalize_numbers(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, list):
        return [_normalize_numbers(item) for item in value]
    if isinstance(value, dict):
        return {key: _normalize_numbers(item) for key, item in value.items()}
    return value


def _clean_optional(value: str | None) -> str | None:
    if value is None:
        return None
    cleaned = value.strip()
    return cleaned or None


def _normalize_wa_number(value: str | None) -> str | None:
    if not value:
        return None

    digits = "".join(character for character in value if character.isdigit())
    if not digits:
        return None
    if digits.startswith("0"):
        return f"62{digits[1:]}"
    if digits.startswith("8"):
        return f"62{digits}"
    return digits


def _format_whatsapp_message(template: str | None, product: MarketplaceProduct) -> str:
    message = template or "Halo, saya tertarik dengan {product_name} di ANABOOL."
    seller_name = product.seller.display_name if product.seller is not None else ""
    replacements = {
        "{product_id}": product.id,
        "{product_name}": product.name,
        "{price_idr}": str(product.price_idr),
        "{seller_name}": seller_name or "penjual",
    }
    for placeholder, value in replacements.items():
        message = message.replace(placeholder, value)
    return message.strip()
