from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.conf import settings
from django.utils import timezone

def generate_otp(user):
    # Generate a random 6-digit OTP
    otp = get_random_string(length=6, allowed_chars='1234567890')

    # Save the OTP to the user's model
    user.otp = otp
    print("Time token created", timezone.now())
    user.otp_expire_at = timezone.now() + timezone.timedelta(minutes=5)
    user.save()

    # Send the OTP to the user's email
    subject = "OTP Verification"
    message = f"Your OTP verification code is: {otp}"
    from_email = settings.EMAIL_HOST_USER
    recipient_list = [user.email]

    send_mail(subject, message, from_email, recipient_list, fail_silently=False)