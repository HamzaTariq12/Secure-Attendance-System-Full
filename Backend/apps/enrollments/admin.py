from django.contrib import admin
from .models import Enrollment

# Register your models here.
class EndollmentAdmin(admin.ModelAdmin):
    list_display = ['id', 'course_id', 'display_students', 'is_active', 'created_at', 'updated_at']

    def display_students(self, obj):
        return ", ".join([str(student) for student in obj.students_id.all()])
# class EndollmentAdmin(admin.ModelAdmin):
#     list_display = ['course', 'student', 'is_active', 'created_at', 'updated_at']

admin.site.register(Enrollment, EndollmentAdmin)