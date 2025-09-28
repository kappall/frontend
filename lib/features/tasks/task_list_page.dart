import 'package:flutter/material.dart';
import 'package:frontend/models/task.dart';
import 'package:frontend/services/api_client.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  String _selectedSort = 'due_date';
  bool _showCompleted = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),

          _buildFiltersAndSearch(context),
          const SizedBox(height: 12),

          _buildTabBar(context),
          const SizedBox(height: 16),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTasksView(context),
                _buildTodayTasksView(context),
                _buildUpcomingTasksView(context),
                _buildCompletedTasksView(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Tasks',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showBulkActionsDialog(context),
              icon: const Icon(Icons.checklist, size: 18),
              label: const Text('Bulk Actions'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersAndSearch(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tasks, subjects, or descriptions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),

            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'All Subjects',
                    'all',
                    _selectedFilter == 'all',
                  ),
                  _buildFilterChip(
                    'Mathematics',
                    'math',
                    _selectedFilter == 'math',
                  ),
                  _buildFilterChip(
                    'Physics',
                    'physics',
                    _selectedFilter == 'physics',
                  ),
                  _buildFilterChip(
                    'Chemistry',
                    'chemistry',
                    _selectedFilter == 'chemistry',
                  ),
                  _buildFilterChip(
                    'History',
                    'history',
                    _selectedFilter == 'history',
                  ),

                  const SizedBox(width: 16),

                  Container(
                    width: 1,
                    height: 32,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),

                  const SizedBox(width: 16),

                  _buildPriorityChip('High Priority', 'high', Colors.red),
                  _buildPriorityChip(
                    'Medium Priority',
                    'medium',
                    Colors.orange,
                  ),
                  _buildPriorityChip('Low Priority', 'low', Colors.green),

                  const SizedBox(width: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      underline: Container(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'due_date',
                          child: Text('Due Date'),
                        ),
                        DropdownMenuItem(
                          value: 'priority',
                          child: Text('Priority'),
                        ),
                        DropdownMenuItem(
                          value: 'subject',
                          child: Text('Subject'),
                        ),
                        DropdownMenuItem(
                          value: 'created',
                          child: Text('Created'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  FilterChip(
                    label: Text('Show Completed'),
                    selected: _showCompleted,
                    onSelected: (selected) {
                      setState(() {
                        _showCompleted = selected;
                      });
                    },
                    checkmarkColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primaryContainer,
        checkmarkColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildPriorityChip(String label, String priority, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: false,
        onSelected: (selected) {
          // Handle priority filter
        },
        avatar: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.7,
        ),
        tabs: const [
          Tab(text: 'All Tasks'),
          Tab(text: 'Today'),
          Tab(text: 'Upcoming'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildAllTasksView(BuildContext context) {
    return _buildTasksList();
  }

  Widget _buildTodayTasksView(BuildContext context) {
    return _buildTasksList(today: true);
  }

  Widget _buildUpcomingTasksView(BuildContext context) {
    return _buildTasksList(upcoming: true);
  }

  Widget _buildCompletedTasksView(BuildContext context) {
    return _buildTasksList(completed: true);
  }

  Widget _buildTasksList({
    bool today = false,
    bool completed = false,
    bool upcoming = false,
  }) {
    String? due;
    if (today) due = "today";

    return FutureBuilder(
      future: ApiClient.getTasks(due),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data!.isEmpty) {
          return _buildEmptyState();
        } else {
          List<Task> tasks = snapshot.data!;
          if (completed) {
            tasks.removeWhere((t) => t.completed_at == null);
          }
          if (upcoming) {
            tasks.removeWhere((t) => t.deadline.compareTo(DateTime.now()) < 0);
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(context, task, index);
            },
          );
        }
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first task to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, int index) {
    final theme = Theme.of(context);

    Color getPriorityColor() {
      switch (task.getPriorityString()) {
        case 'high':
          return Colors.red;
        case 'medium':
          return Colors.orange;
        case 'low':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    Color getSubjectColor() {
      switch (task.subject) {
        case 'Mathematics':
          return Colors.blue;
        case 'Physics':
          return Colors.purple;
        case 'Chemistry':
          return Colors.teal;
        case 'History':
          return Colors.brown;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTaskDetailsDialog(context, task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.completed_at != null,
                    onChanged: (value) {
                      setState(() {
                        ApiClient.updateTask(
                          task.copyWith(completed_at: DateTime.now()),
                        );
                      });
                    },
                    shape: const CircleBorder(),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task.completed_at != null
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.completed_at != null
                                ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: getSubjectColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.subject,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: getSubjectColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: getPriorityColor().withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.getPriorityString().toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: getPriorityColor(),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleTaskAction(context, task, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      const PopupMenuItem(
                        value: 'schedule',
                        child: Text('Schedule'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: _getDueDateColor(task.deadline),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${task.deadline}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getDueDateColor(task.deadline),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${task.estimated_minutes}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    final compare = dueDate.compareTo(DateTime.now());
    if (compare < 0) return Colors.red;
    if (compare == 0) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  void _showAddTaskDialog(BuildContext context) {
    // Implement add task dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: const Text('Add task form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Text('Task details would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBulkActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Actions'),
        content: const Text('Bulk actions options would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleTaskAction(BuildContext context, Task task, String action) {
    switch (action) {
      case 'edit':
        // Handle edit
        break;
      case 'duplicate':
        // Handle duplicate
        break;
      case 'schedule':
        // Handle schedule
        break;
      case 'delete':
        // Handle delete
        break;
    }
  }
}
