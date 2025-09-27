import 'package:flutter/material.dart';
import 'package:frontend/services/api_client.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/login_page.dart';
import 'package:frontend/features/auth/signup_page.dart';
import 'package:frontend/features/main_layout.dart';

GoRouter appRouter(GlobalKey<NavigatorState> navigatorKey) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    redirect: (context, state) async {
      final isAuth = await ApiClient.hasToken();
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isAuth && !loggingIn) {
        return '/login';
      }
      if (isAuth && loggingIn) {
        return '/app';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (ctx, st) => const LoginPage()),
      GoRoute(path: '/signup', builder: (ctx, st) => const SignupPage()),

      GoRoute(path: '/app', builder: (ctx, st) => const MainLayout()),
    ],
  );
}
