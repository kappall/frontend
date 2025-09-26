import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),

        _buildFiltersAndSearch(context),
        const SizedBox(height: 24),

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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12 active tasks, 3 due today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Row(
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

            // Filter chips row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Subject filter
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

                  // Divider
                  Container(
                    width: 1,
                    height: 32,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),

                  const SizedBox(width: 16),

                  // Priority filters
                  _buildPriorityChip('High Priority', 'high', Colors.red),
                  _buildPriorityChip(
                    'Medium Priority',
                    'medium',
                    Colors.orange,
                  ),
                  _buildPriorityChip('Low Priority', 'low', Colors.green),

                  const SizedBox(width: 16),

                  // Sort dropdown
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

                  // Show completed toggle
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
    return _buildTasksList(_getAllTasks());
  }

  Widget _buildTodayTasksView(BuildContext context) {
    return _buildTasksList(_getTodayTasks());
  }

  Widget _buildUpcomingTasksView(BuildContext context) {
    return _buildTasksList(_getUpcomingTasks());
  }

  Widget _buildCompletedTasksView(BuildContext context) {
    return _buildTasksList(_getCompletedTasks());
  }

  Widget _buildTasksList(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState();
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

  Widget _buildTaskCard(
    BuildContext context,
    Map<String, dynamic> task,
    int index,
  ) {
    final theme = Theme.of(context);

    Color getPriorityColor() {
      switch (task['priority']) {
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
      switch (task['subject']) {
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
                    value: task['completed'],
                    onChanged: (value) {
                      setState(() {
                        task['completed'] = value ?? false;
                      });
                    },
                    shape: const CircleBorder(),
                  ),

                  // Task title and subject
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task['completed']
                                ? TextDecoration.lineThrough
                                : null,
                            color: task['completed']
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
                                task['subject'],
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
                                task['priority'].toUpperCase(),
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

              // Description (if exists)
              if (task['description'] != null &&
                  task['description'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Bottom row with details
              Row(
                children: [
                  // Due date
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: _getDueDateColor(task['dueDate']),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task['dueDate'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getDueDateColor(task['dueDate']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Estimated time
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task['estimatedTime'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),

                  const Spacer(),

                  // Progress indicator (if task has subtasks)
                  if (task['subtasks'] != null) ...[
                    Text(
                      '${task['completedSubtasks']}/${task['totalSubtasks']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      height: 4,
                      child: LinearProgressIndicator(
                        value:
                            task['completedSubtasks'] / task['totalSubtasks'],
                        backgroundColor: theme.colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Suggested time slots (if AI has recommendations)
              if (task['suggestedSlots'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Suggested: ${task['suggestedSlots']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _scheduleSuggestedSlot(context, task),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Schedule'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getDueDateColor(String dueDate) {
    // Parse due date and determine urgency color
    if (dueDate.contains('overdue')) return Colors.red;
    if (dueDate.contains('today') || dueDate.contains('tomorrow'))
      return Colors.orange;
    return Colors.grey;
  }

  // Mock data methods
  List<Map<String, dynamic>> _getAllTasks() {
    return [
      {
        'id': '1',
        'title': 'Physics Lab Report - Pendulum Motion',
        'subject': 'Physics',
        'description':
            'Complete analysis of pendulum motion experiment with calculations and graphs',
        'priority': 'high',
        'dueDate': 'Due in 2 days',
        'estimatedTime': '2h 30m',
        'completed': false,
        'suggestedSlots': 'Today 10:45-12:00, Tomorrow 14:00-16:30',
        'totalSubtasks': 4,
        'completedSubtasks': 1,
      },
      {
        'id': '2',
        'title': 'Math Assignment - Chapter 5',
        'subject': 'Mathematics',
        'description':
            'Complete exercises 5.1 to 5.8, focus on integration by parts',
        'priority': 'medium',
        'dueDate': 'Due tomorrow',
        'estimatedTime': '1h 45m',
        'completed': false,
        'totalSubtasks': 3,
        'completedSubtasks': 2,
      },
      {
        'id': '3',
        'title': 'History Essay - Industrial Revolution',
        'subject': 'History',
        'description':
            'Write 2000-word essay on the impact of industrial revolution on society',
        'priority': 'low',
        'dueDate': 'Due in 5 days',
        'estimatedTime': '4h',
        'completed': false,
        'suggestedSlots': 'This weekend 9:00-13:00',
      },
      {
        'id': '4',
        'title': 'Chemistry Quiz Preparation',
        'subject': 'Chemistry',
        'description': 'Review organic chemistry chapters 1-3',
        'priority': 'medium',
        'dueDate': 'Due in 1 week',
        'estimatedTime': '1h 30m',
        'completed': true,
      },
      {
        'id': '5',
        'title': 'Physics Problem Set 3',
        'subject': 'Physics',
        'description': 'Complete problems 3.1-3.15 on thermodynamics',
        'priority': 'high',
        'dueDate': 'Overdue by 1 day',
        'estimatedTime': '2h',
        'completed': false,
        'totalSubtasks': 5,
        'completedSubtasks': 3,
      },
    ];
  }

  List<Map<String, dynamic>> _getTodayTasks() {
    return _getAllTasks()
        .where(
          (task) =>
              task['dueDate'].contains('today') ||
              task['dueDate'].contains('tomorrow'),
        )
        .toList();
  }

  List<Map<String, dynamic>> _getUpcomingTasks() {
    return _getAllTasks()
        .where(
          (task) =>
              !task['completed'] &&
              !task['dueDate'].contains('today') &&
              !task['dueDate'].contains('tomorrow'),
        )
        .toList();
  }

  List<Map<String, dynamic>> _getCompletedTasks() {
    return _getAllTasks().where((task) => task['completed']).toList();
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

  void _showTaskDetailsDialog(BuildContext context, Map<String, dynamic> task) {
    // Implement task details dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task['title']),
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
    // Implement bulk actions dialog
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

  void _handleTaskAction(
    BuildContext context,
    Map<String, dynamic> task,
    String action,
  ) {
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

  void _scheduleSuggestedSlot(BuildContext context, Map<String, dynamic> task) {
    // Handle scheduling suggested time slot
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scheduled "${task['title']}" for suggested time slot'),
        action: SnackBarAction(
          label: 'View Schedule',
          onPressed: () {
            // Navigate to schedule page
          },
        ),
      ),
    );
  }
}
