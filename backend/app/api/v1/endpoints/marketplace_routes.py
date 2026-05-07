from fastapi import APIRouter, Header, Query

from app.core.security import authenticated_user_from_authorization
from app.core.response import success_response
from app.db.schemas.marketplace_schema import (
    ProductCreateRequest,
    ProductReviewCreateRequest,
    WhatsAppOrderLogCreateRequest,
)
from app.services.marketplace_service import MarketplaceService

router = APIRouter()
_service = MarketplaceService()


@router.get("/health")
def marketplace_health():
    return success_response("Marketplace routes ready")


@router.get("/categories")
def list_marketplace_categories():
    result = _service.list_categories()
    return success_response(
        "Marketplace categories loaded",
        [category.model_dump(mode="json") for category in result],
    )


@router.get("/products")
def list_marketplace_products(
    q: str | None = Query(default=None, min_length=1),
    category_id: str | None = Query(default=None),
    category_slug: str | None = Query(default=None),
    seller_id: str | None = Query(default=None),
    min_price_idr: int | None = Query(default=None, ge=0),
    max_price_idr: int | None = Query(default=None, ge=0),
    in_stock: bool | None = Query(default=None),
    sort: str = Query(default="newest", pattern="^(newest|oldest|price_asc|price_desc|rating)$"),
    limit: int = Query(default=20, ge=1, le=50),
    offset: int = Query(default=0, ge=0),
):
    result = _service.list_products(
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
    return success_response("Marketplace products loaded", result.model_dump(mode="json"))


@router.post("/products")
def create_marketplace_product(
    request: ProductCreateRequest,
    authorization: str | None = Header(default=None),
):
    result = _service.create_product(
        request,
        authenticated_user=authenticated_user_from_authorization(authorization),
    )
    return success_response("Marketplace product created", result.model_dump(mode="json"))


@router.get("/products/{product_id}")
def read_marketplace_product(product_id: str):
    result = _service.get_product(product_id)
    return success_response("Marketplace product loaded", result.model_dump(mode="json"))


@router.post("/products/{product_id}/reviews")
def create_marketplace_product_review(
    product_id: str,
    request: ProductReviewCreateRequest,
    authorization: str | None = Header(default=None),
):
    result = _service.create_review(
        product_id,
        request,
        authenticated_user=authenticated_user_from_authorization(authorization),
    )
    return success_response("Marketplace product review created", result.model_dump(mode="json"))


@router.get("/products/{product_id}/reviews")
def list_marketplace_product_reviews(
    product_id: str,
    limit: int = Query(default=10, ge=1, le=50),
):
    result = _service.list_reviews(product_id, limit=limit)
    return success_response(
        "Marketplace product reviews loaded",
        [review.model_dump(mode="json") for review in result],
    )


@router.post("/products/{product_id}/whatsapp-order-logs")
def create_marketplace_whatsapp_order_log(
    product_id: str,
    request: WhatsAppOrderLogCreateRequest,
    authorization: str | None = Header(default=None),
):
    result = _service.create_whatsapp_order_log(
        product_id,
        request,
        authenticated_user=authenticated_user_from_authorization(authorization),
    )
    return success_response("Marketplace WhatsApp order logged", result.model_dump(mode="json"))


@router.post("/products/{product_id}/whatsapp-order")
def create_marketplace_whatsapp_order(
    product_id: str,
    request: WhatsAppOrderLogCreateRequest,
    authorization: str | None = Header(default=None),
):
    return create_marketplace_whatsapp_order_log(product_id, request, authorization)
