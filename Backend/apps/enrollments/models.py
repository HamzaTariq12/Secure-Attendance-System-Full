from django.db import models
from apps.accounts.models import CustomUser
from apps.courses.models import Course

# Create your models here.
class Enrollment(models.Model):
    course_id = models.ForeignKey(Course, on_delete=models.CASCADE)
    students_id = models.ManyToManyField(CustomUser)
    # status
    is_active = models.BooleanField(default=True)
    # timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        # unique_together = ('course', 'student')
        verbose_name = "Enrollment"
        verbose_name_plural = "Enrollments"
    
    def __str__(self):
        return self.course_id.title