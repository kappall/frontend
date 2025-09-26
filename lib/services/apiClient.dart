import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/free_time_slot.dart';
import 'package:frontend/models/schedule_item.dart';
import 'package:frontend/models/session.dart';
import 'package:frontend/models/summary.dart';
import 'package:frontend/models/task.dart';
import 'package:frontend/models/user.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

class ApiClient {
  Future<void> login(String email, String password) async {
    debugPrint("called login");
    final res = await http.post(
      Uri.parse("http://localhost:3000/auth/login"),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    debugPrint(res.toString());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      debugPrint(data.toString());
      final token = data["token"];
      await storage.write(key: "jwt", value: token);
    }
  }

  Future<bool> signup(User user) async {
    final res = await http.post(
      Uri.parse("http://localhost:3000/auth/signup"),
      body: jsonEncode(user.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    return res.statusCode == 200;
  }

  Future<User?> getUser() async {
    final token = await storage.read(key: "jwt");
    final res = await http.get(
      Uri.parse("http://localhost:3000/user"),
      headers: {"Authorization": "Bearer $token"},
    );

    debugPrint(res.body);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return User.fromJson(data);
    }
    return null;
  }

  Future<Summary> getSummary() async {
    final token = await storage.read(key: "jwt");
    final res = await http.get(
      Uri.parse("http://localhost:3000/dashboard/summary"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      final b = jsonDecode(res.body);
      debugPrint("res: ${jsonDecode(res.body)}");
      return Summary.fromJson(b);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  Future<List<ScheduleItem>> getTodaySchedule() async {
    final token = await storage.read(key: "jwt");
    final res = await http.get(
      Uri.parse("http://localhost:3000/schedule/today"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  Future<List<Task>> getTasks(String? due) async {
    final token = await storage.read(key: "jwt");
    final res = await http.get(
      Uri.parse("http://localhost:3000/tasks${due != null ? "?due=$due" : ""}"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  Future<List<FreeTimeSlot>> getFreeSlots() async {
    final token = await storage.read(key: "jwt");
    final res = await http.get(
      Uri.parse("http://localhost:3000/schedule/free"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  Future<Session> startSession(taskId) async {
    final token = await storage.read(key: "jwt");
    final res = await http.post(
      Uri.parse("http://localhost:3000/sessions/start"),
      body: jsonEncode({taskId}),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  Future<void> endSession(Session session) async {
    final token = await storage.read(key: "jwt");
    final res = await http.patch(
      Uri.parse("http://localhost:3000/sessions/end"),
      body: jsonEncode(session.toJson()),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  Future<Task> createTask(Task task) async {
    final token = await storage.read(key: "jwt");
    final res = await http.post(
      Uri.parse("http://localhost:3000/tasks"),
      body: jsonEncode(task.toJson()),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  Future<void> updateTask(Task task) async {
    final token = await storage.read(key: "jwt");
    final res = await http.put(
      Uri.parse("http://localhost:3000/tasks/${task.id}"),
      body: jsonEncode(task.toJson()),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }
}
