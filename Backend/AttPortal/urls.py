from django.contrib import admin
from django.urls import path, include
from django.conf.urls.static import static
from django.conf import settings

# Views
from api.views.accounts import UserLoginView, UserRegisterView, ProfileAPIView, UserDeleteView
# Swagger
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

urlpatterns = [
    path("admin/", admin.site.urls),
    path('api/', include('api.urls')),

    # Swagger Docs
    path('schema/', SpectacularAPIView.as_view(), name='schema'),
    path('schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    # User Authentication
    path('api/auth/register/', UserRegisterView.as_view(), name="register"),
    path('api/auth/login/', UserLoginView.as_view(), name="login"),
    path('api/auth/profile/', ProfileAPIView.as_view(), name="profile"),
    path('api/auth/delete-user/', UserDeleteView.as_view(), name="delete-user")

] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)