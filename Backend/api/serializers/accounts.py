from rest_framework import serializers
from django.db import transaction
from django.utils import timezone

# Models
from apps.accounts.models import CustomUser, UserProfile
from apps.attachments.models import Attachments


# User Serializer for sending User Details in Token
class UserTokenSerializer(serializers.ModelSerializer):
    '''
    For Generating Custom data of User in Token
    '''
    class Meta:
        model = CustomUser
        fields = ["first_name", "last_name", "email", "user_type", "is_active", "last_login"]
        read_only_fields = fields

# Login Serializer
class UserLoginSerializer(serializers.ModelSerializer):
    '''
    Logging in User
    '''
    email = serializers.EmailField(required=True)
    class Meta:
        model = CustomUser
        fields = ['email', 'password']

# Register Serializer
class UserRegisterSerializer(serializers.ModelSerializer):
    '''
    Registering a new User and Creating a Profile for the User
    '''
    class Meta:
        model = CustomUser
        fields = ["id", "first_name", "last_name", "email", "password", "roll_no", "user_type", "created_at"]
        read_only_fields = ["id", "created_at"]
        extra_kwargs={
            'password':{'write_only':True},
        }
    
    def validate_email(self, value):
        email = value.lower()
        if CustomUser.objects.filter(email=email).exists():
            raise serializers.ValidationError("user with this email already exists.")
        return email
  
    @transaction.atomic
    def create(self, validated_data):
        # Normalize the email address to lowercase
        validated_data['email'] = validated_data['email'].lower()
        # Create the User object and set the password
        user = CustomUser.objects.create(**validated_data)
        user.set_password(validated_data['password'])
        user.save()

        return user

# USER PROFILE SERIALIZER'S
# Profile Serializer's
class TeacherProfileSerializer(serializers.ModelSerializer):
    email = serializers.CharField(source='user.email')
    first_name = serializers.CharField(source='user.first_name')
    last_name = serializers.CharField(source='user.last_name')
    profile_picture = serializers.SerializerMethodField()
    class Meta:
        model = UserProfile
        fields = ["id", "email", "first_name", "last_name", "profile_picture", "created_at", "updated_at"]
        read_only_fields = fields

    def get_profile_picture(self, obj):
        return obj.get_profile_picture()
class StudentProfileSerializer(serializers.ModelSerializer):
    email = serializers.CharField(source='user.email')
    first_name = serializers.CharField(source='user.first_name')
    last_name = serializers.CharField(source='user.last_name')
    roll_no = serializers.CharField(source='user.roll_no')
    profile_picture = serializers.SerializerMethodField()
    class Meta:
        model = UserProfile
        fields = ["id", "email", "first_name", "last_name", "roll_no", "profile_picture", "created_at", "updated_at"]
        read_only_fields = fields

    def get_profile_picture(self, obj):
        return obj.get_profile_picture()
    
class UpdateProfileSerializer(serializers.Serializer):
    first_name = serializers.CharField(required=False)
    last_name = serializers.CharField(required=False)
    profile_picture = serializers.ImageField(required=False)
    
    def update(self, instance, validated_data):
        if "first_name" in validated_data:
            instance.user.first_name = validated_data["first_name"]
        if "last_name" in validated_data:
            instance.user.last_name = validated_data["last_name"]
        if "profile_picture" in validated_data:
            instance.profile_picture.attachment = validated_data["profile_picture"]
        instance.user.save()
        instance.profile_picture.save()
        instance.save()
        return instance