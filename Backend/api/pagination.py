from rest_framework.pagination import PageNumberPagination

class CustomPagination(PageNumberPagination):
    page_size = 30  # Set the number of items per page
    page_size_query_param = 'page_size'  # Customize the query parameter for changing page size
    max_page_size = 30  # Set a maximum page size if needed

class StatsPagination(PageNumberPagination):
    page_size = 30  # Set the number of items per page
    page_size_query_param = 'page_size'  # Customize the query parameter for changing page size
    max_page_size = 30  # Set a maximum page size if needed