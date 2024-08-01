from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import CustomUser, UserProfile
from apps.attachments.models import Attachments

@receiver(post_save, sender=CustomUser)
def create_profile(sender, instance, created, **kwargs):
    if created:
        # Create the UserProfile instance and associate it with the default profile picture
        UserProfile.objects.create(user=instance, profile_picture=Attachments.objects.create(attachment='attachments/default/profile_picture/default.png'))