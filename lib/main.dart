import 'package:flutter/material.dart';
import 'package:frontend/features/main_layout.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/theme.dart';
import 'package:provider/provider.dart';
import 'router.dart';

void main() {
  runApp(PlannerApp());
}

class PlannerApp extends StatelessWidget {
  PlannerApp({super.key});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    ApiClient.initialize(navigatorKey);
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp.router(
            title: 'MySchedule',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter(navigatorKey),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
