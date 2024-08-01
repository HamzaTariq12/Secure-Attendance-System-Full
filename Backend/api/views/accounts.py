from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView

from django.contrib.auth import authenticate
from django.utils import timezone

# Serializers
from api.serializers.accounts import UserLoginSerializer, UserRegisterSerializer, TeacherProfileSerializer, StudentProfileSerializer, UpdateProfileSerializer
# Renders
from api.renders import MainResponse, formatError, MainRenderer
# Token
from api.token import get_tokens_for_user
# Permissions
from rest_framework.permissions import IsAuthenticated
# Models
from apps.accounts.models import UserProfile
# CustomUser model
from django.contrib.auth import get_user_model
User = get_user_model()


# Login User
class UserLoginView(APIView):
    renderer_classes = [MainRenderer]
    serializer_class = UserLoginSerializer

    def post(self, request):
        try:
            serializer = self.serializer_class(data=request.data)
            if serializer.is_valid():
                email = serializer.data.get('email').lower()
                password = serializer.data.get('password')

                # Authenticate the user if user is active
                user = authenticate(email=email, password=password)
                if user is not None:
                    # Update last login
                    self.update_last_login(user)
                    # Generate token
                    token = get_tokens_for_user(user)
                    data = MainResponse(data={"token": token}, errors=None, message="Login Successfully!")
                    return Response(data, status=status.HTTP_200_OK)
                else:
                    data = MainResponse(data=None, errors="Invalid credentials", message="Login Failed! Invalid credentials.")
                    return Response(data, status=status.HTTP_400_BAD_REQUEST)
            else:
                data = MainResponse(data=None, errors=formatError(serializer.errors), message="Login Failed! Please make sure all required fields are filled correctly.")
                return Response(data, status=status.HTTP_400_BAD_REQUEST)

        except Exception as err:
            data = MainResponse(data=None, errors=formatError(err), message="Sorry! Something went wrong.") 
            return Response(data, status=status.HTTP_400_BAD_REQUEST)

    def update_last_login(self, user):
        user.last_login = timezone.now()
        user.save()
        return user

# Register User
class UserRegisterView(APIView):
    renderer_classes = [MainRenderer]
    serializer_class = UserRegisterSerializer

    def post(self, request):
        try:
            serializer = self.serializer_class(data=request.data)
            if serializer.is_valid():
                serializer.save()
                data = MainResponse(data={"User":serializer.data}, errors=None, message="Registration Successful!")
                return Response(data, status=status.HTTP_201_CREATED)
            else:
                data = MainResponse(data=None, errors=formatError(serializer.errors), message="Registration Failed! Please make sure all required fields are filled correctly.")
                return Response(data, status=status.HTTP_400_BAD_REQUEST)

        except Exception as err:
            data = MainResponse(data=None, errors=formatError(err), message="Sorry! Something went wrong.") 
            return Response(data, status=status.HTTP_400_BAD_REQUEST)

# Get/Edit User Profile
class ProfileAPIView(APIView):
    renderer_classes = [MainRenderer]
    permission_classes = [IsAuthenticated]
    queryset = UserProfile.objects.all()

    def get_serializer_class(self):
        if self.request.method == 'GET':
            return TeacherProfileSerializer if self.request.user.user_type == 'Teacher' else StudentProfileSerializer
        elif self.request.method == 'PUT':
            return UpdateProfileSerializer

    def get_object(self):
        return self.request.user.userprofile
    
    def get(self, request):
        try:
            user_profile = self.get_object()
            serializer_class = self.get_serializer_class()
            serializer = serializer_class(instance=user_profile)
            data = MainResponse(data={"User Profile":serializer.data}, errors=None, message="User Profile details.")
            return Response(data, status=status.HTTP_200_OK)
        
        except Exception as err:
            data = MainResponse(data=None, errors=formatError(err), message="Sorry! Something went wrong.") 
            return Response(data, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        try:
            user_profile = self.get_object()
            serializer_class = self.get_serializer_class()
            serializer = serializer_class(data=request.data, instance=user_profile, partial=True)
            if serializer.is_valid():
                instance = serializer.save()
                if user_profile.user.user_type == 'Teacher':
                    display_serializer = TeacherProfileSerializer(instance=instance)
                else:
                    display_serializer = StudentProfileSerializer(instance=instance)
                # display_serializer = ProfileSerializer(instance=user_profile)
                data = MainResponse(data={"User Profile":display_serializer.data}, errors=None, message="User Profile updated successfully.")
                return Response(data, status=status.HTTP_200_OK)
            else:
                data = MainResponse(data=None, errors=formatError(serializer.errors), message="Please make sure all required fields are filled correctly.")
                return Response(data, status=status.HTTP_400_BAD_REQUEST)
        
        except Exception as err:
            data = MainResponse(data=None, errors=formatError(err), message="Sorry! Something went wrong.") 
            return Response(data, status=status.HTTP_400_BAD_REQUEST)

# Delete User
class UserDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request):
        user = request.user
        user.delete()
        return Response({"User deleted successfully!"}, status=status.HTTP_200_OK)