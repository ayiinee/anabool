from datetime import datetime

from pydantic import AliasChoices, BaseModel, Field


class MarketplaceCategory(BaseModel):
    id: str
    name: str
    slug: str
    description: str | None = None
    icon_url: str | None = None
    display_order: int = 0
    is_active: bool = True


class MarketplaceSeller(BaseModel):
    id: str
    display_name: str | None = None
    avatar_url: str | None = None
    phone_number: str | None = None


class ProductImage(BaseModel):
    id: str
    product_id: str
    image_url: str
    storage_path: str | None = None
    display_order: int = 0
    created_at: datetime | None = None


class ProductReview(BaseModel):
    id: str
    product_id: str
    user_id: str
    rating: int = Field(ge=1, le=5)
    body: str | None = None
    created_at: datetime | None = None
    user: MarketplaceSeller | None = None


class MarketplaceProduct(BaseModel):
    id: str
    seller_id: str
    category_id: str
    name: str
    description: str | None = None
    price_idr: int = 0
    stock: int = 0
    unit: str | None = None
    wa_number: str | None = None
    wa_template: str | None = None
    avg_rating: float | None = None
    review_count: int = 0
    is_active: bool = True
    created_at: datetime | None = None
    updated_at: datetime | None = None
    category: MarketplaceCategory | None = None
    seller: MarketplaceSeller | None = None
    images: list[ProductImage] = Field(default_factory=list)
    reviews: list[ProductReview] = Field(default_factory=list)


class ProductListResult(BaseModel):
    items: list[MarketplaceProduct]
    limit: int
    offset: int
    total: int


class ProductCreateRequest(BaseModel):
    # MVP fallback until every write request carries Firebase auth.
    seller_id: str | None = Field(
        default=None,
        validation_alias=AliasChoices("seller_id", "sellerId"),
    )
    category_id: str = Field(validation_alias=AliasChoices("category_id", "categoryId"))
    name: str = Field(min_length=1, max_length=160)
    description: str | None = Field(default=None, max_length=4000)
    price_idr: int = Field(default=0, ge=0, validation_alias=AliasChoices("price_idr", "priceIdr"))
    stock: int = Field(default=0, ge=0)
    unit: str | None = Field(default=None, max_length=40)
    wa_number: str | None = Field(
        default=None,
        validation_alias=AliasChoices("wa_number", "waNumber"),
        max_length=32,
    )
    wa_template: str | None = Field(
        default=None,
        validation_alias=AliasChoices("wa_template", "waTemplate"),
        max_length=1000,
    )
    image_urls: list[str] = Field(
        default_factory=list,
        validation_alias=AliasChoices("image_urls", "imageUrls"),
    )


class ProductReviewCreateRequest(BaseModel):
    # MVP fallback until every write request carries Firebase auth.
    user_id: str | None = Field(
        default=None,
        validation_alias=AliasChoices("user_id", "userId"),
    )
    rating: int = Field(ge=1, le=5)
    body: str | None = Field(default=None, max_length=1000)


class WhatsAppOrderLogCreateRequest(BaseModel):
    # MVP fallback until every write request carries Firebase auth.
    user_id: str | None = Field(
        default=None,
        validation_alias=AliasChoices("user_id", "userId"),
    )
    template_message: str | None = Field(
        default=None,
        validation_alias=AliasChoices("template_message", "templateMessage"),
        max_length=1000,
    )


class WhatsAppOrderLogResult(BaseModel):
    id: str | None = None
    product_id: str
    seller_id: str
    user_id: str
    wa_number: str
    template_message: str
    wa_url: str
    clicked_at: datetime | None = None
