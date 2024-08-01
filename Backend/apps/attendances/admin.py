from django.contrib import admin
from .models import Attendance, AttendanceDetail

# Register your models here.
class AttendanceAdmin(admin.ModelAdmin):
    list_display = ['id', 'course_id', 'teacher_id', 'created_at', 'updated_at']

class AttendanceDetailAdmin(admin.ModelAdmin):
    list_filter = ['attendance_id']
    list_display = ['id', 'attendance_id', 'status', 'created_at', 'updated_at']

admin.site.register(Attendance, AttendanceAdmin)
admin.site.register(AttendanceDetail, AttendanceDetailAdmin)