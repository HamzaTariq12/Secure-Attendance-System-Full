from django.urls import path
from api.views.courses import TeacherCoursesView, EnrolledAndAddStudentsView, ListCreateAttendanceView, MarkManualAttendanceView, ListStudentsAttendanceDetailView, MarkQRAttendanceView, ListStudentAttendanceView, GetQRCodeView

urlpatterns = [
    # Teacher Dashboard
    # - Courses
    path('teacher-courses/', TeacherCoursesView.as_view(), name='teacher-courses'),
    # - List/Create Attendance against a course
    path('teacher-courses/attendance/', ListCreateAttendanceView.as_view(), name='create-attendance'),
    # - Get QR Code
    path('teacher-courses/attendance/qr/<int:attendance_id>', GetQRCodeView.as_view(), name='get-qr-code'),
    # - List Students against each course
    path('teacher-courses/students/', EnrolledAndAddStudentsView.as_view(), name='students-against-course'),
    # path('teacher-courses/students/<int:pk>', EnrolledStudentsView.as_view(), name='students-against-course'),
    # - Mark Attendance
    #   - Manual
    path('teacher-courses/attendance/mark/manual/<int:attendance_id>', MarkManualAttendanceView.as_view(), name='mark-attendance-manual'),
    # - List Students against an Attendance
    path('teacher-courses/attendance/students/<int:attendance_id>', ListStudentsAttendanceDetailView.as_view(), name='students-against-attendance'),

    # Student Dashboard
    # - List Attendances
    path('student/attendance/', ListStudentAttendanceView.as_view(), name='student-attendance'),
    # - Mark Attendance
    #   - QR
    path('teacher-course/attendance/mark/qr/<int:attendance_id>', MarkQRAttendanceView.as_view(), name='mark-attendance-qr'),
]