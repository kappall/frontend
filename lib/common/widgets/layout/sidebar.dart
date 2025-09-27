import 'package:flutter/material.dart';
import 'package:frontend/features/main_layout.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isExpanded = true;
  int selectedNavIndex = 0;
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 0),
      curve: Curves.linear,
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            right: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        width: isExpanded ? 250 : 80,
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
                  if (isExpanded) ...[
                    SizedBox(width: 20),
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
                  _buildSideBarItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Dashboard',
                    isSelected: widget.selectedIndex == 0,
                    onTap: () => widget.onItemTap(0),
                  ),
                  _buildSideBarItem(
                    context,
                    icon: Icons.folder_outlined,
                    activeIcon: Icons.folder,
                    label: 'Tasks',
                    isSelected: widget.selectedIndex == 1,

                    onTap: () => widget.onItemTap(1),
                  ),
                  _buildSideBarItem(
                    context,
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    label: 'Schedule',
                    isSelected: widget.selectedIndex == 2,
                    onTap: () => widget.onItemTap(2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSideBarItem(
                    context,
                    icon: appState.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    label: appState.isDarkMode ? 'Light Mode' : 'Dark Mode',
                    onTap: () => appState.toggleTheme(),
                  ),
                  const SizedBox(height: 8),
                  _buildSideBarItem(
                    context,
                    icon: isExpanded ? Icons.chevron_left : Icons.chevron_right,
                    label: isExpanded ? 'Collapse' : 'Expand',
                    onTap: () => setState(() {
                      isExpanded = !isExpanded;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBarItem(
    BuildContext context, {
    required IconData icon,
    IconData? activeIcon,
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showText = constraints.maxWidth > 120;

                if (showText) {
                  return Row(
                    children: [
                      Icon(
                        isSelected && activeIcon != null ? activeIcon : icon,
                        size: 24,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: constraints.maxWidth > 150 ? 1.0 : 0.0,
                          child: Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
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
                      message: label,
                      child: Icon(
                        isSelected && activeIcon != null ? activeIcon : icon,
                        size: 24,
                        color: isSelected
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
