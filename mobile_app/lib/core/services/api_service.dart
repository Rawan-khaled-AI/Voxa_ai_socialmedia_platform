import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
      body: jsonEncode(body),
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Request failed');
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Request failed');
  }

  static Future<List<dynamic>> getList(
    String endpoint, {
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as List<dynamic>
        : <dynamic>[];

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception('Request failed');
  }

  static Future<String> uploadImage(File file, String token) async {
    return _uploadFile(
      endpoint: '/upload/image',
      file: file,
      token: token,
      errorMessage: 'Image upload failed',
    );
  }

  static Future<String> uploadAudio(File file, String token) async {
    return _uploadFile(
      endpoint: '/upload/audio',
      file: file,
      token: token,
      errorMessage: 'Audio upload failed',
    );
  }

  static Future<String> _uploadFile({
    required String endpoint,
    required File file,
    required String token,
    required String errorMessage,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      return data['url'] as String;
    }

    throw Exception('$errorMessage (${response.statusCode}): ${response.body}');
  }
}