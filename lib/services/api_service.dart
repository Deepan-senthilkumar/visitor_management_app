import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/visitor.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConstants.baseUrl,
        _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 10);

  // 1. GET: Fetch all visitors
  Future<List<Visitor>> getVisitors() async {
    try {
      final response = await _client.get(Uri.parse(baseUrl)).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Visitor.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException('Failed to load visitors (HTTP ${response.statusCode})', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection. Please verify your network.');
    } on TimeoutException {
      throw ApiException('Network request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Invalid response format received from server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // 2. GET by ID: Fetch single visitor details (Spec requirement for QR scan)
  Future<Visitor> getVisitorById(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/$id')).timeout(_timeout);

      if (response.statusCode == 200) {
        return Visitor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw ApiException('Visitor pass not found for ID: #$id', 404);
      } else {
        throw ApiException('Failed to fetch visitor record (HTTP ${response.statusCode})', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection. Please verify your network.');
    } on TimeoutException {
      throw ApiException('Network request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Invalid response format received from server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // 3. POST: Register new visitor
  Future<Visitor> addVisitor(Visitor visitor) async {
    try {
      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(visitor.toJson()),
      ).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Visitor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to register visitor (HTTP ${response.statusCode})', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Network request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // 4. PUT: Update visitor details or status
  Future<Visitor> updateVisitor(Visitor visitor) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/${visitor.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(visitor.toJson()),
      ).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Visitor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to update visitor (HTTP ${response.statusCode})', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Network request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // 5. DELETE: Remove visitor record
  Future<void> deleteVisitor(String id) async {
    try {
      final response = await _client.delete(Uri.parse('$baseUrl/$id')).timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Failed to delete visitor (HTTP ${response.statusCode})', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Network request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}
