from typing import Any
from django.contrib import admin
from django import forms
from django.forms import HiddenInput, TextInput, ImageField

# Register your models here.

from .models import CustomUser, UserProfile

class ProfileAdminForm(forms.ModelForm):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        instance = kwargs.get('instance')
        if instance and instance.profile_picture:
            self.fields['profile_picture'].widget.can_add_related = False

    class Meta:
        model = UserProfile
        fields = '__all__'

class UserProfileAdmin(admin.ModelAdmin):
    # form = ProfileAdminForm
    # exclude = ('user',)
    list_display = ('user_email', 'user_first_name', 'user_last_name', 'user_is_active', 'user_is_staff', 'user_is_super_user')  # Fields to display in the list display

    def user_first_name(self, instance):
        return instance.user.first_name  # Accessing the first_name of the associated CustomUser
    
    def user_last_name(self, instance):
        return instance.user.last_name  # Accessing the last_name of the associated CustomUser
    
    def user_email(self, instance):
        return instance.user.email
    
    def user_is_active(self, instance):
        return instance.user.is_active
    
    def user_is_staff(self, instance):
        return instance.user.is_staff
    
    def user_is_super_user(self, instance):
        return instance.user.is_superuser
    
    user_is_super_user.boolean = True  # Displaying an icon instead of True/False
    user_is_active.boolean = True  # Displaying an icon instead of True/False
    user_is_staff.boolean = True  # Displaying an icon instead of True/False
    user_email.short_description = 'Email'  # Customize the column header name
    user_first_name.short_description = 'First Name'  # Customize the column header name
    user_last_name.short_description = 'Last Name'  # Customize the column header name
    user_is_active.short_description = 'Active'  # Customize the column header name
    user_is_staff.short_description = 'Staff'  # Customize the column header name
    user_is_super_user.short_description = 'Super User'  # Customize the column header name

class UserAdmin(admin.ModelAdmin):
    exclude = ('username',)
    # exclude = ('otp', 'otp_expire_at', 'groups', 'user_permissions', 'password', 'created_at', 'updated_at')
    # readonly_fields = ('date_joined', 'last_login')
    list_display = ('id', 'email', 'first_name', 'last_name', 'user_type', 'roll_no', 'is_active', 'is_staff', 'is_superuser')

    def save_model(self, request, obj, form, change):
        # Your additional logic here
        obj.set_password(obj.password)

        # // SEE THIS ARTICLE TO FIX THIS SET_PASSWORD ISSUE FOR CREATION OF NEW STUDENT
        # https://stackoverflow.com/questions/15456964/changing-password-in-django-admin
        # // THE PASSWORD CANNOT BE CHANGED FROM THE ADMIN PANEL, CREATE SEPERATE VIEW IF NECESSARY

        # Save the model
        super().save_model(request, obj, form, change)

# Register the model with the admin
admin.site.register(UserProfile, UserProfileAdmin)
admin.site.register(CustomUser, UserAdmin)