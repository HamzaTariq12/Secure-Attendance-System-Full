import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:start/main.dart';

class BaseApiResponse<T> {
  T? data;
  Meta? meta;

  BaseApiResponse({this.data, this.meta});

  factory BaseApiResponse.fromJson(Map<String, dynamic> json,
      T Function(Map<String, dynamic> json) fromJsonFunction) {
    return BaseApiResponse<T>(
      data: json['data'] != null ? fromJsonFunction(json['data']) : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class Meta {
  String? errors;
  bool? status;
  int? statusCode;
  String? displayMessage;

  Meta({this.errors, this.status, this.statusCode, this.displayMessage});

  Meta.fromJson(Map<String, dynamic> json) {
    errors = json['errors'];
    status = json['status'];
    statusCode = json['status_code'];
    displayMessage = json['display_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['errors'] = errors;
    data['status'] = status;
    data['status_code'] = statusCode;
    data['display_message'] = displayMessage;
    return data;
  }
}

class ApiService {
  static String baseUrl =
      "https://localhost:8080/api/";

  static Future<http.Response> getRequest(String endpoint) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    String token = prefs?.getString('access_token') ?? '';
    var headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (!token.isEmpty) {
      headers["Authorization"] = "Bearer " + token;
    }
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    return response;
  }

  static Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    String token = prefs?.getString('access_token') ?? '';
    var headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (!token.isEmpty) {
      headers["Authorization"] = "Bearer " + token;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  static Future<http.Response> putRequest(
      String endpoint, Map<String, dynamic> body) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    String token = prefs?.getString('access_token') ?? '';
    var headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (!token.isEmpty) {
      headers["Authorization"] = "Bearer " + token;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  static Future<http.Response> deleteRequest(String endpoint) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    String token = prefs?.getString('access_token') ?? '';
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
