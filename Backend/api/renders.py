from rest_framework.exceptions import ErrorDetail, PermissionDenied
from rest_framework import renderers
import json

class MainRenderer(renderers.JSONRenderer):
    def render(self, data, accepted_media_type=None, renderer_context=None):
        response = renderer_context['response']
        if response.status_code == 200 or response.status_code == 201:
            # Success response
            finalResponse = {
                'data': data.data,
                'meta': {
                    'errors': data.errors,
                    'status': True,
                    'status_code': response.status_code,
                    "display_message": data.message,
                    }
                    }
        elif isinstance(data, dict):
            # Permissions response
            data = MainResponse(data=None, errors=data, message="Sorry! You don't have permission to perform this action.")
            finalResponse = {
                'data': data.data,
                'meta': {
                    'errors': data.errors,
                    'status': False,
                    'status_code': response.status_code,
                    "display_message": data.message,
                    }
                    }
        else:
            # Error response
            finalResponse = {
                'data': data.data,
                'meta': {
                    'errors': data.errors,
                    'status': False,
                    'status_code': response.status_code,
                    "display_message": data.message,
                    }
                    }

        return super().render(finalResponse, accepted_media_type, renderer_context)


def formatError(error):
    if not isinstance(error, dict):
        return str(error)

    formatted_errors = []
    for key, value in error.items():
        if isinstance(value, list):
            formatted_errors.append(f"{key}: {', '.join(value)}")
        else:
            formatted_errors.append(f"{key}: {value}")

    return ' , '.join(formatted_errors)

class MainResponse:
    def __init__(self, data, errors,message):
        self.data = data
        self.errors = errors
        self.message = message