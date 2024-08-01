from rest_framework import serializers
from apps.courses.models import Course
from apps.enrollments.models import Enrollment
from apps.attendances.models import Attendance, AttendanceDetail
from apps.accounts.models import CustomUser
from django.utils import timezone

# Teacher Serializer
class TeacherSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ('id', 'full_name', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

# Student Serializer
class StudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ('id', 'full_name', 'roll_no', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

# Course Serializer
class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = ('id', 'title', 'description')
        read_only_fields = fields

# Enrollment Serializer
class EnrollmentSerializer(serializers.ModelSerializer):
    students_id = StudentSerializer(many=True)
    class Meta:
        model = Enrollment
        fields = ('id', 'course_id', 'students_id', 'created_at', 'updated_at')

# Attendance Serializer
class AttendanceSerializer(serializers.ModelSerializer):
    course_id = serializers.PrimaryKeyRelatedField(queryset=Course.objects.all())
    class Meta:
        model = Attendance
        fields = ('id', 'att_type', 'course_id', 'latitude', 'longitude', 'ip', 'device', 'details_students_count', 'qr_expire_at', 'created_at', 'updated_at')
        read_only_fields = ('id', 'details_students_count', 'qr_expire_at', 'created_at', 'updated_at')
        depth = 1

    def validate_course_id(self, value):
        user = self.context.get('user')
        if not value.teacher_id == user:
            raise serializers.ValidationError("You are not the teacher of this course")
        return value
class GetAttendanceCourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = ('id', 'title')
        read_only_fields = fields
class GetAttendanceSerializer(serializers.ModelSerializer):
    course_id = GetAttendanceCourseSerializer()
    class Meta:
        model = Attendance
        fields = ('id', 'att_type', 'course_id', 'latitude', 'longitude', 'ip', 'device', 'details_students_count', 'qr_expire_at', 'created_at', 'updated_at')
        read_only_fields = fields

# Manual Attendance Detail Serializer
class ManualAttendanceDetailSerializer(serializers.ModelSerializer):
    student_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.all())
    class Meta:
        model = AttendanceDetail
        fields = ('id', 'module_type', 'attendance_id', 'student_id', 'status', 'latitude', 'longitude', 'ip', 'device', 'ssid', 'created_at', 'updated_at')
        read_only_fields = ('id', 'module_type', 'attendance_id', 'created_at', 'updated_at')

    def create(self, validated_data):
        attendance = self.context.get('attendance_id')
        attendance_detail = AttendanceDetail.objects.create(module_type="Manual", attendance_id=attendance, **validated_data)
        return attendance_detail
class AttendanceDetailStudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ('id', 'full_name', 'roll_no')
        read_only_fields = fields
class GetAttendanceDetailStudentSerializer(serializers.ModelSerializer):
    student = serializers.SerializerMethodField()
    class Meta:
        model = AttendanceDetail
        fields = ('id', 'module_type', 'attendance_id', 'student', 'status', 'enrollment_status', 'created_at', 'updated_at')
        read_only_fields = ('id', 'module_type', 'attendance_id', 'created_at', 'updated_at')

    def get_student(self, obj):
        return AttendanceDetailStudentSerializer(instance = obj.student_id).data
    
# QR Attendance Detail Serializer
class QRAttendanceDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = AttendanceDetail
        fields = ('id', 'latitude', 'longitude', 'ip', 'device', 'ssid', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')


# Student Attendance Detail Serializer
class StudentAttendanceSerializer(serializers.ModelSerializer):
    student = serializers.SerializerMethodField()
    course = serializers.SerializerMethodField()
    class Meta:
        model = AttendanceDetail
        fields = ('id', 'module_type', 'student', 'status', 'course', 'enrollment_status', 'created_at')
        read_only_fields = ('id', 'module_type', 'attendance_id', 'created_at')

    def get_student(self, obj):
        return AttendanceDetailStudentSerializer(instance = obj.student_id).data
    
    def get_course(self, obj):
        return GetAttendanceCourseSerializer(instance = obj.attendance_id.course_id).data