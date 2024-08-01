# from rest_framework import permissions

# class IsOwner(permissions.BasePermission):
#     def has_object_permission(self, request, view, obj):
#         # Check if the request user is the owner of the object
#         print(f"Object owner: {obj.owner}")
#         print(f"Request user: {request.user}")
#         return obj.owner == request.user

# class IsOwnerOrReadOnly(permissions.BasePermission):
#     def has_object_permission(self, request, view, obj):
#         # Check if the request user is the owner of the object
#         print(f"Object owner: {obj.owner}")
#         print(f"Request user: {request.user}")
#         if request.method in permissions.SAFE_METHODS:
#             return True
#         return obj.owner == request.user

# from rest_framework.permissions import BasePermission

# class IsActiveSubscription(BasePermission):
#     def has_permission(self, request, view):
#         user = request.user
#         if user.is_authenticated:
#             # Assuming user has a OneToOne relationship with Subscription
#             subscription = user.subscription  # Assuming 'subscription' is the related name

#             # Check if subscription is active
#             return subscription.is_active
#         return False  # Deny access if user is not authenticated or has no subscription


# from rest_framework.permissions import BasePermission
# from rest_framework.response import Response
# from rest_framework import status
# from apps.workouts.models import Workouts
# from apps.membership.models import Subscription
# from django.utils import timezone

# class IsActiveSubscription(BasePermission):
#     def has_permission(self, request, view):
#         workout_id = view.kwargs.get('pk')  # Assuming the workout ID is passed as 'pk' in the URL
#         try:
#             workout = Workouts.objects.get(pk=workout_id)
#             if workout:
#                 if workout.is_locked:
#                     # For locked workouts, allow access only to users with an active subscription
#                     user = request.user
#                     if user.is_authenticated:
#                         active_subscriptions = Subscription.objects.filter(
#                                             user=user,
#                                             end_date__gt=timezone.now(),  # Active subscriptions
#                                         )
#                         if active_subscriptions.exists():
#                             return True  # Allow access if the user has an active subscription
#                         # subscription = user.subscription  # Assuming 'subscription' is the related name

#                         # if subscription and subscription.is_active:
#                         #     return True  # Allow access if the user has an active subscription

#                     return False  # Deny access if subscription is not active or doesn't exist
#                 else:
#                     # For unlocked workouts, allow access to any authenticated user
#                     return request.user.is_authenticated
#         except Workouts.DoesNotExist:
#             return Response({"Workout not found!"}, status=status.HTTP_404_NOT_FOUND)