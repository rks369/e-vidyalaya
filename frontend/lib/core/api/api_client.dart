import 'dart:async';
import 'dart:convert';

import 'package:evidyalaya/core/config/env.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {

  ApiException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;

}

class UploadedFile {

  const UploadedFile({
    required this.url,
    required this.name,
    required this.ext,
  });

  final String url;
  final String name;
  final String ext;

}

class ApiClient {

  ApiClient._();

  static final instance = ApiClient._();

  static const _timeout = Duration(seconds: 90);
  static const _uploadTimeout = Duration(minutes: 15);

  String? token;

  Future<dynamic> get({
    required String path,
    Map<String, String>? query,
  }) =>
      _send(
        method: 'GET',
        path: path,
        query: query,
      );

  Future<dynamic> post({
    required String path,
    required Map<String, dynamic> body,
  }) =>
      _send(
        method: 'POST',
        path: path,
        body: body,
      );

  Future<UploadedFile> upload({
    required String filename,
    required int length,
    required Stream<List<int>> content,
  }) async {

    final request = http.MultipartRequest(
      'POST',
      _uri(path: '/uploads'),
    )
      ..headers.addAll(_authHeaders())
      ..files.add(
        http.MultipartFile(
          'file',
          content,
          length,
          filename: filename,
        ),
      );
    final result = await _finish(
      request: request,
      timeout: _uploadTimeout,
    );
    return UploadedFile(
      url: result['url'],
      name: result['name'],
      ext: result['ext'],
    );

  }

  Uri _uri({
    required String path,
    Map<String, String>? query,
  }) =>
      Uri.parse('${Env.apiBaseUrl}$path')
          .replace(queryParameters: query?.isEmpty ?? true ? null : query);

  Map<String, String> _authHeaders() => {

    if (token != null) 'authorization': 'Bearer $token',

  };

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) {

    final request = http.Request(
      method,
      _uri(
        path: path,
        query: query,
      ),
    )
      ..headers['content-type'] = 'application/json'
      ..headers.addAll(_authHeaders());
    if (body != null) {
      request.body = jsonEncode(body);
    }
    return _finish(
      request: request,
      timeout: _timeout,
    );

  }

  Future<dynamic> _finish({
    required http.BaseRequest request,
    required Duration timeout,
  }) async {

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await request.send().timeout(timeout),
      );
    } on TimeoutException {
      throw ApiException(message: 'The server took too long to respond');
    } on http.ClientException {
      throw ApiException(message: 'Cannot reach the server. Check your connection.');
    }

    final decoded = response.body.isEmpty ? null : _tryDecode(body: response.body);
    if (response.statusCode >= 400) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(
        message: message is String ? message : 'Something went wrong',
        statusCode: response.statusCode,
      );
    }
    return decoded is Map ? decoded['data'] : decoded;

  }

  dynamic _tryDecode({required String body}) {

    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }

  }

}
