import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/free_time_slot.dart';
import 'package:frontend/models/schedule_item.dart';
import 'package:frontend/models/session.dart';
import 'package:frontend/models/summary.dart';
import 'package:frontend/models/task.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/auth_interceptor.dart';

class ApiClient {
  static late Dio _dio;
  static final FlutterSecureStorage storage = const FlutterSecureStorage();

  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _dio = Dio();

    _dio.options = BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    );

    _dio.interceptors.add(AuthInterceptor(navigatorKey: navigatorKey));
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  static Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  static Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  static Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  static Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  // AUTH METHODS
  static Future<void> login(String email, String password) async {
    final response = await post(
      '/auth/login',
      data: {"email": email, "password": password},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final token = data["token"];
      await storage.write(key: "jwt", value: token);
    }
  }

  static Future<bool> signup(User user) async {
    final response = await post('/auth/signup', data: user.toJson());
    return response.statusCode == 200;
  }

  static Future<void> logout() async {
    await storage.delete(key: 'jwt');
  }

  static Future<bool> hasToken() async {
    final token = await storage.read(key: 'jwt');
    return token != null;
  }

  static Future<User?> getUser() async {
    try {
      final response = await get('/user');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // DASHBOARD METHODS
  static Future<Summary> getSummary({
    DateTime? from,
    DateTime? to,
    String? granularity, // "day", "week", "month"
  }) async {
    final params = <String, String>{};

    if (from != null && to != null) {
      params['from'] = from.toIso8601String();
      params['to'] = to.toIso8601String();
    }
    if (granularity != null) {
      params['granularity'] = granularity;
    }

    final response = await get('/dashboard/summary', queryParameters: params);

    if (response.statusCode == 200) {
      return Summary.fromJson(response.data);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  // SCHEDULE METHODS
  static Future<List<ScheduleItem>> getTodaySchedule() async {
    final response = await get('/schedule/today');

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((item) => ScheduleItem.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load today schedule");
    }
  }

  static Future<List<FreeTimeSlot>> getFreeSlots() async {
    final response = await get('/schedule/free');

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((item) => FreeTimeSlot.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load free slots");
    }
  }

  // TASK METHODS
  static Future<List<Task>> getTasks(String? due) async {
    final response = await get(
      '/tasks',
      queryParameters: due != null ? {"due": due} : null,
    );

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((item) => Task.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  static Future<Task> createTask(Task task) async {
    final response = await post('/tasks', data: task.toJson());

    if (response.statusCode == 200) {
      return Task.fromJson(response.data);
    } else {
      throw Exception("Failed to create task");
    }
  }

  static Future<Task> updateTask(Task task) async {
    final response = await put('/tasks/${task.id}', data: task.toJson());

    if (response.statusCode == 200) {
      return Task.fromJson(response.data);
    } else {
      throw Exception("Failed to update task");
    }
  }

  // SESSION METHODS
  static Future<Session> startSession(String taskId) async {
    final response = await post('/sessions/start', data: {"task_id": taskId});

    if (response.statusCode == 200) {
      return Session.fromJson(response.data);
    } else {
      throw Exception("Failed to start session");
    }
  }

  static Future<Session> endSession(Session session) async {
    final response = await patch('/sessions/end', data: session.toJson());

    if (response.statusCode == 200) {
      return Session.fromJson(response.data);
    } else {
      throw Exception("Failed to end session");
    }
  }
}
