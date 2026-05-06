from datetime import datetime

from pydantic import AliasChoices, BaseModel, Field


class PickupPackage(BaseModel):
    id: str
    name: str
    description: str
    pickup_type: str
    price_idr: int = 0
    weight_limit_g: int | None = None
    meowpoints_bonus: int = 0
    is_active: bool = True
    created_at: datetime | None = None


class CourierInfo(BaseModel):
    id: str
    user_id: str
    vehicle_type: str
    plate_number: str | None = None
    is_available: bool = False
    rating: float | None = None
    display_name: str | None = None
    avatar_url: str | None = None


class PickupOrderStatusLog(BaseModel):
    id: str | None = None
    pickup_order_id: str | None = None
    status: str
    note: str | None = None
    created_at: datetime | None = None


class PickupOrder(BaseModel):
    id: str
    user_id: str
    courier_id: str | None = None
    package_id: str
    address_id: str
    scan_session_id: str | None = None
    pickup_type: str
    status: str
    scheduled_at: datetime | None = None
    pickup_lat: float | None = None
    pickup_lng: float | None = None
    estimated_weight_g: int | None = None
    actual_weight_g: int | None = None
    notes: str | None = None
    meowpoints_earned: int = 0
    created_at: datetime | None = None
    updated_at: datetime | None = None
    package: PickupPackage | None = None
    courier: CourierInfo | None = None
    status_logs: list[PickupOrderStatusLog] = Field(default_factory=list)


class PickupOrderCreateRequest(BaseModel):
    user_id: str | None = Field(
        default=None,
        validation_alias=AliasChoices("user_id", "userId"),
    )
    package_id: str = Field(validation_alias=AliasChoices("package_id", "packageId"))
    address_id: str = Field(validation_alias=AliasChoices("address_id", "addressId"))
    pickup_type: str = Field(validation_alias=AliasChoices("pickup_type", "pickupType"))
    scan_session_id: str | None = Field(
        default=None,
        validation_alias=AliasChoices("scan_session_id", "scanSessionId"),
    )
    scheduled_at: datetime | None = Field(
        default=None,
        validation_alias=AliasChoices("scheduled_at", "scheduledAt"),
    )
    pickup_lat: float | None = Field(
        default=None,
        validation_alias=AliasChoices("pickup_lat", "pickupLat"),
    )
    pickup_lng: float | None = Field(
        default=None,
        validation_alias=AliasChoices("pickup_lng", "pickupLng"),
    )
    notes: str | None = Field(default=None, max_length=1000)


class PickupPackageListResult(BaseModel):
    items: list[PickupPackage]
