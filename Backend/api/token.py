from rest_framework_simplejwt.tokens import RefreshToken
# Serializers for custom claims
from api.serializers.accounts import UserTokenSerializer

# Generate Token Manually
def get_tokens_for_user(user):
  refresh = RefreshToken.for_user(user)
  # Custom claims
  refresh["user_data"] = UserTokenSerializer(user).data

  return {
      # 'refresh_token': str(refresh),
      'access_token': str(refresh.access_token),
  }