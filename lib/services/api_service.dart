import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_exceptions.dart';

class ApiService {
  ApiService({http.Client? client, this.timeout = const Duration(seconds: 8)})
    : _client = client ?? http.Client();

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;
  final Duration timeout;

  Future<List<UserModel>> fetchUsers() async {
    final body = await _get('/users');
    try {
      final data = body as List<dynamic>;
      return data
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on TypeError {
      throw const DataParsingException();
    }
  }

  Future<UserModel> fetchUserById(int id) async {
    final body = await _get('/users/$id');
    try {
      return UserModel.fromJson(body as Map<String, dynamic>);
    } on TypeError {
      throw const DataParsingException();
    }
  }

  Future<dynamic> _get(String path) async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse('$baseUrl$path'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(timeout);
    } on SocketException {
      throw const NoInternetException();
    } on http.ClientException {
      throw const NoInternetException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    }

    if (response.statusCode != 200) {
      throw ServerException(
        'The server returned status ${response.statusCode}. Please try again later.',
        statusCode: response.statusCode,
      );
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const DataParsingException();
    }
  }

  void dispose() => _client.close();
}
