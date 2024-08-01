from django.db import models
from apps.accounts.models import CustomUser

# Create your models here.

class Course(models.Model):
    # course
    title = models.CharField(max_length=100)
    description = models.TextField()
    teacher_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE, default=4)
    # status
    is_active = models.BooleanField(default=True)
    # timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Course"
        verbose_name_plural = "Courses"
    
    def __str__(self):
        return f"CourseID: {self.pk}, Title: {self.title}, Teacher: {self.teacher_id.full_name}"