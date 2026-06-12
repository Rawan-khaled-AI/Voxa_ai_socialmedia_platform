import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.4:8000';

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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Request failed');
  }

  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
      body: jsonEncode(body),
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception('Request failed');
  }

  static Future<String> uploadImage(
    File file,
    String token,
  ) async {
    return _uploadFile(
      endpoint: '/upload/image',
      file: file,
      token: token,
      errorMessage: 'Image upload failed',
    );
  }

  static Future<String> uploadAudio(
    File file,
    String token,
  ) async {
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
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    final streamedResponse = await request.send();
    final response =
        await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      return data['url'] as String;
    }

    throw Exception(
      '$errorMessage (${response.statusCode}): ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> multipartRequest({
    required String endpoint,
    required String method,
    required Map<String, dynamic> fields,
    required Map<String, File> files,
    String? token,
  }) async {
    final request = http.MultipartRequest(
      method,
      Uri.parse('$baseUrl$endpoint'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    for (final entry in files.entries) {
      request.files.add(
        await http.MultipartFile.fromPath(
          entry.key,
          entry.value.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response =
        await http.Response.fromStream(streamedResponse);

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Multipart request failed');
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Delete request failed');
  }
}