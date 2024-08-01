from django.db import models
from django.conf import settings

# Create your models here.

# Attachments
class Attachments(models.Model):
    attachment = models.FileField(upload_to='attachments')

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Attachment"
        verbose_name_plural = "Attacnhemts"

    def __str__(self):
        if self.attachment:
            return self.attachment.name.split('/')[-1]

    def getAttachment(self):
        if self.attachment:
            return settings.BASE_URL + self.attachment.url
        else:
            return None