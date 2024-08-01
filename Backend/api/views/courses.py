from rest_framework import generics
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
import base64
import json
from geopy.distance import geodesic
from django.utils import timezone

# Serializers
from api.serializers.courses import CourseSerializer, EnrollmentSerializer, AttendanceSerializer, ManualAttendanceDetailSerializer, StudentSerializer, GetAttendanceSerializer, GetAttendanceDetailStudentSerializer, QRAttendanceDetailSerializer, StudentAttendanceSerializer
# Permissions
from rest_framework.permissions import IsAuthenticated
# Models
from apps.accounts.models import CustomUser
from apps.courses.models import Course
from apps.enrollments.models import Enrollment
from apps.attendances.models import Attendance, AttendanceDetail

# TEACHER COURSES
class TeacherCoursesView(generics.ListAPIView):
    serializer_class = CourseSerializer
    permission_classes = [IsAuthenticated]
    queryset = Course.objects.all()

    def get_queryset(self):
        return Course.objects.filter(teacher_id=self.request.user)

        
# CREATE ATTENDANCE
class ListCreateAttendanceView(generics.ListCreateAPIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = AttendanceSerializer

    def get(self, request):
        queryset = Attendance.objects.filter(teacher_id=request.user).order_by('-created_at')
        serializer = GetAttendanceSerializer(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = self.serializer_class(data=request.data, context={'user': request.user})
        if serializer.is_valid():
            if serializer.validated_data['att_type'] == 'Manual':
                instance = serializer.save(teacher_id = request.user)
                data = GetAttendanceSerializer(instance).data
                data.pop('details_students_count')
                data.pop('qr_expire_at')
                return Response(data, status=status.HTTP_201_CREATED)
            elif serializer.validated_data['att_type'] == 'QR':
                try:
                    enrolled = Enrollment.objects.get(course_id=serializer.validated_data['course_id'])
                except Enrollment.DoesNotExist:
                    return Response({'error': "No enrollments against this course cant generate QR."}, status=status.HTTP_404_NOT_FOUND)
                qr_expire_time = timezone.now() + timezone.timedelta(minutes=10)
                instance = serializer.save(teacher_id = request.user, qr_expire_at=qr_expire_time)
                # Create Attendance Details for each student enrolled in course
                for student in enrolled.students_id.all():
                    AttendanceDetail.objects.create(module_type="QR", attendance_id=instance, student_id=student, status="Absent")
                # Convert validated data to JSON and encode it in Base64
                data = GetAttendanceSerializer(instance).data
                data.pop('details_students_count')
                data_json = json.dumps(data)
                base64_data = base64.b64encode(data_json.encode('utf-8')).decode('utf-8')
                return Response({'base64_data': base64_data}, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    
# STUDENTS AGAINST EACH COURSE
class EnrolledAndAddStudentsView(APIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = EnrollmentSerializer
    queryset = Enrollment.objects.all()

    def get(self, request):
        roll_num = request.query_params.get('roll_no')
        roll_num_upper = roll_num.upper() if roll_num else None
        course_id = request.query_params.get('course_id')

        if roll_num and course_id:
            try:
                student = CustomUser.objects.get(roll_no=roll_num_upper, user_type="Student")
                if student in Enrollment.objects.get(course_id=course_id).students_id.all():
                    return Response({'error': 'Student is already enrolled in this course'}, status=status.HTTP_400_BAD_REQUEST)
            except CustomUser.DoesNotExist:
                return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)
            except Enrollment.DoesNotExist:
                return Response({'error': 'No enrollments against this course'}, status=status.HTTP_404_NOT_FOUND)
            serializer = StudentSerializer(instance = student)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        elif course_id:
            try:
                course = Course.objects.get(id=course_id, teacher_id=request.user)
                students_enrolled = Enrollment.objects.get(course_id=course).students_id.all()
                serializer = StudentSerializer(students_enrolled, many=True)
                return Response(serializer.data, status=status.HTTP_200_OK)
            except Course.DoesNotExist:
                return Response({'error': 'Course not found'}, status=status.HTTP_404_NOT_FOUND)
            except Enrollment.DoesNotExist:
                return Response({'error': 'No students enrolled yet'}, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({'error': 'Please provide course_id in params'}, status=status.HTTP_400_BAD_REQUEST)


# MARK MANUAL ATTENDANCE
class MarkManualAttendanceView(APIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = ManualAttendanceDetailSerializer

    def post(self, request, attendance_id):
        try:
            attendance = Attendance.objects.get(id=attendance_id, teacher_id=request.user)
        except Attendance.DoesNotExist:
            return Response({'error': 'Attendance not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ManualAttendanceDetailSerializer(data=request.data, many=True, context={'attendance_id': attendance})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# MARK QR ATTENDANCE
class MarkQRAttendanceView(APIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = QRAttendanceDetailSerializer

    def put(self, request, attendance_id):
        try:
            attendance_detail = AttendanceDetail.objects.get(attendance_id=attendance_id, student_id=request.user)
        except AttendanceDetail.DoesNotExist:
            return Response({'error': "Can't mark the attendance, you are not enrolled in this course."}, status=status.HTTP_404_NOT_FOUND)
        serializer = self.serializer_class(data=request.data, instance=attendance_detail)
        if serializer.is_valid():
            # VALIDATION
            # 1) 10 min QR expiration
            if attendance_detail.attendance_id.qr_expire_at < timezone.now():
                return Response({'error': 'QR has been expired'}, status=status.HTTP_400_BAD_REQUEST)
            # 2) marking friends attendance from the same device
            serializer.validated_data['device'] = serializer.validated_data['device'].lower()
            device_exists = AttendanceDetail.objects.filter(
                attendance_id=attendance_id,
                device=serializer.validated_data['device']
                    ).exclude(student_id=request.user).exists()
            if device_exists:
                return Response({'error': 'You have already marked attendance from this device.'}, status=status.HTTP_400_BAD_REQUEST)
            # 3) student should be within 10 meters from the attendance lat, long
            attendance_location = (attendance_detail.attendance_id.latitude, attendance_detail.attendance_id.longitude)
            student_location = (serializer.validated_data['latitude'], serializer.validated_data['longitude'])
            try:
                distance = geodesic(attendance_location, student_location).meters
                if distance > 10:
                    return Response({'error': 'You are not within 10 meters from the attendance location'}, status=status.HTTP_400_BAD_REQUEST)
            except:
                return Response({'error': 'Invalid location data'}, status=status.HTTP_400_BAD_REQUEST)
            
            # MARK PRESENT
            if attendance_detail.status == 'Absent':
                attendance_detail.status = "Present"
                serializer.save(status="Present")
            else:
                return Response({'error': 'You are already Present'}, status=status.HTTP_400_BAD_REQUEST)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# LIST OF STUDENTS AGAINST ATTENDANCE ID
class ListStudentsAttendanceDetailView(APIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = GetAttendanceDetailStudentSerializer

    def get(self, request, attendance_id):
        try:
            attendance = Attendance.objects.get(id=attendance_id, teacher_id=request.user)
        except Attendance.DoesNotExist:
            return Response({'error': 'Attendance not found'}, status=status.HTTP_404_NOT_FOUND)
        attendance_details = AttendanceDetail.objects.filter(attendance_id=attendance)
        serializer = self.serializer_class(instance=attendance_details, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


# GET QR CODE
class GetQRCodeView(APIView):
    permission_classes = (IsAuthenticated,)

    def get(self, request, attendance_id):
        try:
            attendance = Attendance.objects.get(id=attendance_id, teacher_id=request.user)
        except Attendance.DoesNotExist:
            return Response({'error': 'Attendance not found'}, status=status.HTTP_404_NOT_FOUND)
        data = GetAttendanceSerializer(attendance).data
        data.pop('details_students_count')
        data_json = json.dumps(data)
        base64_data = base64.b64encode(data_json.encode('utf-8')).decode('utf-8')
        return Response({'base64_data': base64_data}, status=status.HTTP_200_OK)


# STUDENT DASHBOARD
# List ATTENDANCE
class ListStudentAttendanceView(generics.ListCreateAPIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = StudentAttendanceSerializer

    def get(self, request):
        queryset = AttendanceDetail.objects.filter(student_id=request.user).order_by('-attendance_id__created_at')
        serializer = StudentAttendanceSerializer(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)