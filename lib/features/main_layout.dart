import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/dashboard_page.dart';
import 'package:frontend/features/schedule/schedule_page.dart';
import 'package:frontend/features/tasks/task_list_page.dart';
import 'package:provider/provider.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;

  bool get isDarkMode => _isDarkMode;
  int get selectedNavIndex => _selectedNavIndex;
  bool get isSidebarExpanded => _isSidebarExpanded;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarExpanded = !_isSidebarExpanded;
    notifyListeners();
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: Row(
            children: [
              AnimatedSize(
                curve: Curves.linear,
                duration: const Duration(milliseconds: 0),
                child: SizedBox(
                  width: appState._isSidebarExpanded ? 240 : 80,
                  child: const Sidebar(),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const TopBar(),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: _getCurrentPage(
                          context,
                          appState.selectedNavIndex,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getCurrentPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const TaskListPage();
      case 2:
        return const SchedulePage();
      default:
        return const DashboardPage();
    }
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flutter_dash,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                if (appState.isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    'MySchedule',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                  isActive: appState.selectedNavIndex == 0,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder,
                  title: 'Tasks',
                  index: 1,
                  isActive: appState.selectedNavIndex == 1,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  title: 'Schedule',
                  index: 2,
                  isActive: appState.selectedNavIndex == 2,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildNavItem(
                  context,
                  icon: appState.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  title: appState.isDarkMode ? 'Light Mode' : 'Dark Mode',
                  onTap: () => appState.toggleTheme(),
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: appState.isSidebarExpanded
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  title: appState.isSidebarExpanded ? 'Collapse' : 'Expand',
                  onTap: () => appState.toggleSidebar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    IconData? activeIcon,
    String? title,
    int? index,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap:
              onTap ??
              (index != null ? () => appState.setNavIndex(index) : null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showText = constraints.maxWidth > 120;

                if (showText && title != null) {
                  return Row(
                    children: [
                      Icon(
                        isActive && activeIcon != null ? activeIcon : icon,
                        size: 24,
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: constraints.maxWidth > 150 ? 1.0 : 0.0,
                          child: Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Tooltip(
                      message: title ?? '',
                      child: Icon(
                        isActive && activeIcon != null ? activeIcon : icon,
                        size: 24,
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
