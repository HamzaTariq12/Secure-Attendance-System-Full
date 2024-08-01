from django.db import models
from apps.accounts.models import CustomUser
from apps.courses.models import Course
from apps.enrollments.models import Enrollment

# Create your models here.
class Attendance(models.Model):
    ATTENDANCE_MODULE_TYPE = (
        ('Manual', 'Manual'),
        ('QR', 'QR')
    )
    att_type = models.CharField(max_length=10, choices=ATTENDANCE_MODULE_TYPE)
    course_id = models.ForeignKey(Course, on_delete=models.CASCADE)
    teacher_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    latitude = models.FloatField()
    longitude = models.FloatField()
    ip = models.GenericIPAddressField()
    device = models.CharField(max_length=50)
    qr_expire_at = models.DateTimeField(blank=True, null=True)
    # timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Attendance"
        verbose_name_plural = "Attendances"
    
    def __str__(self):
        return f"ID: {self.pk}, Course: {self.course_id.title} - Teacher: {self.teacher_id.full_name}"
    
    @property
    def details_students_count(self):
        enrolled_students = Enrollment.objects.get(course_id=self.course_id).students_id.all()
        total = enrolled_students.count()
        
        present = AttendanceDetail.objects.filter(attendance_id=self, status='Present',student_id__in=enrolled_students).count()
        absent = AttendanceDetail.objects.filter(attendance_id=self, status='Absent',student_id__in=enrolled_students).count()
        return {'total': total, 'present': present, 'absent': absent}
    
class AttendanceDetail(models.Model):
    ATTENDANCE_MODULE_TYPE = (
        ('Manual', 'Manual'),
        ('QR', 'QR')
    )
    STATUS_CHOICES = (
        ('Present', 'Present'),
        ('Absent', 'Absent')
    )
    module_type = models.CharField(max_length=10, choices=ATTENDANCE_MODULE_TYPE)
    attendance_id = models.ForeignKey(Attendance, on_delete=models.CASCADE)
    student_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES)
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    ip = models.GenericIPAddressField(blank=True, null=True)
    device = models.CharField(max_length=50, blank=True, null=True)
    ssid = models.CharField(max_length=50, blank=True, null=True)
    # timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Attendance Detail"
        verbose_name_plural = "Attendance Details"
    
    def __str__(self):
        return self.attendance_id.course_id.title
    
    @property
    def enrollment_status(self):
        student = self.student_id
        course = self.attendance_id.course_id
        try:
            enrollment = Enrollment.objects.get(course_id=course, students_id=student)
            return True
        except Enrollment.DoesNotExist:
            return False