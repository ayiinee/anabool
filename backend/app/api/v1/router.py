from fastapi import APIRouter

from app.api.v1.endpoints import auth_routes
from app.api.v1.endpoints import user_routes
from app.api.v1.endpoints import cat_routes
from app.api.v1.endpoints import litter_box_routes
from app.api.v1.endpoints import scan_routes
from app.api.v1.endpoints import chat_routes
from app.api.v1.endpoints import education_routes
from app.api.v1.endpoints import module_routes
from app.api.v1.endpoints import pickup_routes
from app.api.v1.endpoints import marketplace_routes
from app.api.v1.endpoints import reward_routes
from app.api.v1.endpoints import impact_routes
from app.api.v1.endpoints import notification_routes

api_router = APIRouter()

api_router.include_router(auth_routes.router, prefix="/auth", tags=["Auth"])
api_router.include_router(user_routes.router, prefix="/users", tags=["Users"])
api_router.include_router(cat_routes.router, prefix="/cats", tags=["Cats"])
api_router.include_router(litter_box_routes.router, prefix="/litter-boxes", tags=["Litter Boxes"])
api_router.include_router(scan_routes.router, prefix="/scans", tags=["Scans"])
api_router.include_router(chat_routes.router, prefix="/chats", tags=["Chatbot Ana"])
api_router.include_router(education_routes.router, prefix="/education", tags=["Education"])
api_router.include_router(module_routes.router, prefix="/modules", tags=["Modules"])
api_router.include_router(pickup_routes.router, prefix="/pickup", tags=["Pickup"])
api_router.include_router(marketplace_routes.router, prefix="/marketplace", tags=["Marketplace"])
api_router.include_router(reward_routes.router, prefix="/rewards", tags=["Rewards"])
api_router.include_router(impact_routes.router, prefix="/impact", tags=["Impact"])
api_router.include_router(notification_routes.router, prefix="/notifications", tags=["Notifications"])