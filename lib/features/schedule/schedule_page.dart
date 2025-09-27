import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'week'; // 'week', 'day', 'month'
  bool _showFreeTimeSlots = true;
  bool _showCompletedTasks = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with controls
        _buildHeader(context),
        const SizedBox(height: 24),

        // View controls and filters
        _buildViewControls(context),
        const SizedBox(height: 24),

        // Main schedule view
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main calendar/schedule view
              Expanded(flex: 3, child: _buildScheduleView(context)),

              const SizedBox(width: 24),

              // Right sidebar with details and actions
              Expanded(flex: 1, child: _buildSidebar(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday =
        _selectedDate.day == now.day &&
        _selectedDate.month == now.month &&
        _selectedDate.year == now.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Schedule',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'TODAY',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _getDateRangeText(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Quick actions
            OutlinedButton.icon(
              onPressed: () => _showQuickScheduleDialog(context),
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('Quick Schedule'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddEventDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Event'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewControls(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Date navigation
            IconButton(
              onPressed: () => _navigateDate(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            TextButton(
              onPressed: () => _showDatePicker(context),
              child: Text(
                _getDateButtonText(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _navigateDate(1),
              icon: const Icon(Icons.chevron_right),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                });
              },
              child: const Text('Today'),
            ),

            const SizedBox(width: 24),

            // View mode selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'day',
                  label: Text('Day'),
                  icon: Icon(Icons.today, size: 16),
                ),
                ButtonSegment(
                  value: 'week',
                  label: Text('Week'),
                  icon: Icon(Icons.view_week, size: 16),
                ),
                ButtonSegment(
                  value: 'month',
                  label: Text('Month'),
                  icon: Icon(Icons.calendar_month, size: 16),
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _viewMode = newSelection.first;
                });
              },
            ),

            const Spacer(),

            // Filter toggles
            Row(
              children: [
                FilterChip(
                  label: const Text('Free Time'),
                  selected: _showFreeTimeSlots,
                  onSelected: (selected) {
                    setState(() {
                      _showFreeTimeSlots = selected;
                    });
                  },
                  avatar: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _showCompletedTasks,
                  onSelected: (selected) {
                    setState(() {
                      _showCompletedTasks = selected;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleView(BuildContext context) {
    switch (_viewMode) {
      case 'day':
        return _buildDayView(context);
      case 'week':
        return _buildWeekView(context);
      case 'month':
        return _buildMonthView(context);
      default:
        return _buildWeekView(context);
    }
  }

  Widget _buildWeekView(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          // Week header with days
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Time column header
                const SizedBox(width: 60),
                // Days of week
                ...List.generate(7, (index) {
                  final date = _getWeekStart().add(Duration(days: index));
                  final isToday = _isToday(date);
                  final isSelected = _isSameDay(date, _selectedDate);

                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : isToday
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getDayName(date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected || isToday
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isToday
                                      ? theme.colorScheme.onPrimary
                                      : isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Schedule grid
          Expanded(
            child: SingleChildScrollView(child: _buildTimeGrid(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: List.generate(24, (hour) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Time label
              Container(
                width: 60,
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),

              // Day columns
              ...List.generate(7, (dayIndex) {
                final date = _getWeekStart().add(Duration(days: dayIndex));
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildDayColumn(context, date, hour),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDayColumn(BuildContext context, DateTime date, int hour) {
    final events = _getEventsForDateAndHour(date, hour);

    return Container(
      padding: const EdgeInsets.all(2),
      child: Stack(
        children: events
            .map((event) => _buildEventBlock(context, event))
            .toList(),
      ),
    );
  }

  Widget _buildEventBlock(BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);

    Color getEventColor() {
      switch (event['type']) {
        case 'class':
          return Colors.blue;
        case 'study':
          return Colors.orange;
        case 'free':
          return Colors.green;
        case 'break':
          return Colors.purple;
        case 'exam':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    IconData getEventIcon() {
      switch (event['type']) {
        case 'class':
          return Icons.school;
        case 'study':
          return Icons.menu_book;
        case 'free':
          return Icons.free_breakfast;
        case 'break':
          return Icons.coffee;
        case 'exam':
          return Icons.quiz;
        default:
          return Icons.event;
      }
    }

    final color = getEventColor();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: () => _showEventDetails(context, event),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(getEventIcon(), size: 12, color: color),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        event['title'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (event['location'] != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    event['location'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayView(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(_selectedDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_selectedDate.day} ${_getMonthName(_selectedDate)} ${_selectedDate.year}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildDayStats(context),
              ],
            ),
          ),

          // Day schedule list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getDayEvents(_selectedDate).length,
              itemBuilder: (context, index) {
                final event = _getDayEvents(_selectedDate)[index];
                return _buildDayEventCard(context, event, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayStats(BuildContext context) {
    final events = _getDayEvents(_selectedDate);
    final classCount = events.where((e) => e['type'] == 'class').length;
    final studyCount = events.where((e) => e['type'] == 'study').length;
    final freeCount = events.where((e) => e['type'] == 'free').length;

    return Row(
      children: [
        _buildStatChip(context, '$classCount Classes', Colors.blue),
        const SizedBox(width: 8),
        _buildStatChip(context, '$studyCount Study', Colors.orange),
        const SizedBox(width: 8),
        _buildStatChip(context, '${freeCount}h Free', Colors.green),
      ],
    );
  }

  Widget _buildStatChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDayEventCard(
    BuildContext context,
    Map<String, dynamic> event,
    int index,
  ) {
    final theme = Theme.of(context);

    Color getEventColor() {
      switch (event['type']) {
        case 'class':
          return Colors.blue;
        case 'study':
          return Colors.orange;
        case 'free':
          return Colors.green;
        case 'break':
          return Colors.purple;
        case 'exam':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    final color = getEventColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    event['startTime'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    event['endTime'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Event content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event['type'].toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (event['type'] == 'study' &&
                            event['completed'] != null)
                          Icon(
                            event['completed']
                                ? Icons.check_circle
                                : Icons.schedule,
                            size: 16,
                            color: event['completed'] ? Colors.green : color,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event['title'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (event['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        event['description'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (event['location'] != null) ...[
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event['location'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${event['duration']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month header
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${_getMonthName(_selectedDate)} ${_selectedDate.year}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Days of week header
            Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((
                day,
              ) {
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Calendar grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.2,
                ),
                itemCount: 42, // 6 weeks * 7 days
                itemBuilder: (context, index) {
                  final date = _getMonthStart().add(Duration(days: index));
                  return _buildMonthDayCell(context, date);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDayCell(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final isToday = _isToday(date);
    final isCurrentMonth = date.month == _selectedDate.month;
    final events = _getDayEvents(date);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        color: isToday
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : null,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDate = date;
            _viewMode = 'day';
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.day}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCurrentMonth
                      ? (isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Column(
                  children: events.take(3).map((event) {
                    return Container(
                      width: double.infinity,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 1),
                      decoration: BoxDecoration(
                        color: _getEventTypeColor(event['type']),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (events.length > 3)
                Text(
                  '+${events.length - 3} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 8,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUpcomingEvents(context),
          const SizedBox(height: 24),
          _buildFreeTimeOptimizer(context),
          const SizedBox(height: 24),
          _buildQuickStats(context),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    final theme = Theme.of(context);
    final upcomingEvents = _getUpcomingEvents();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Up',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 12),
            ...upcomingEvents
                .take(4)
                .map((event) => _buildUpcomingEventItem(context, event)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventItem(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    final theme = Theme.of(context);
    final color = _getEventTypeColor(event['type']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${event['startTime']} - ${event['duration']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTimeOptimizer(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Scheduling',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Suggested time slots
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optimal study time detected:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🕐 Today 10:45-12:00 (1h 15m)\n📍 Library - Perfect for Physics Lab',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _scheduleOptimalTime(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 32),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Schedule This',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Free time stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2.5h',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Free today',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Tasks pending',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildStatRow('Study Hours', '12.5h', '📚', Colors.orange),
            const SizedBox(height: 12),
            _buildStatRow('Classes', '18', '🏫', Colors.blue),
            const SizedBox(height: 12),
            _buildStatRow('Free Time Used', '85%', '⏰', Colors.green),
            const SizedBox(height: 12),
            _buildStatRow('Tasks Completed', '14/17', '✅', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String emoji, Color color) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getDateRangeText() {
    switch (_viewMode) {
      case 'day':
        return '${_getDayName(_selectedDate)}, ${_selectedDate.day} ${_getMonthName(_selectedDate)} ${_selectedDate.year}';
      case 'week':
        final weekStart = _getWeekStart();
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${weekStart.day} - ${weekEnd.day} ${_getMonthName(weekStart)} ${weekStart.year}';
      case 'month':
        return '${_getMonthName(_selectedDate)} ${_selectedDate.year}';
      default:
        return '';
    }
  }

  String _getDateButtonText() {
    switch (_viewMode) {
      case 'day':
        return '${_selectedDate.day} ${_getMonthName(_selectedDate)} ${_selectedDate.year}';
      case 'week':
        final weekStart = _getWeekStart();
        return '${_getMonthName(weekStart)} ${weekStart.year}';
      case 'month':
        return '${_getMonthName(_selectedDate)} ${_selectedDate.year}';
      default:
        return '';
    }
  }

  DateTime _getWeekStart() {
    final weekday = _selectedDate.weekday;
    return _selectedDate.subtract(Duration(days: weekday - 1));
  }

  DateTime _getMonthStart() {
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final weekday = firstDayOfMonth.weekday;
    return firstDayOfMonth.subtract(Duration(days: weekday - 1));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'class':
        return Colors.blue;
      case 'study':
        return Colors.orange;
      case 'free':
        return Colors.green;
      case 'break':
        return Colors.purple;
      case 'exam':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateDate(int direction) {
    setState(() {
      switch (_viewMode) {
        case 'day':
          _selectedDate = _selectedDate.add(Duration(days: direction));
          break;
        case 'week':
          _selectedDate = _selectedDate.add(Duration(days: 7 * direction));
          break;
        case 'month':
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + direction,
            _selectedDate.day,
          );
          break;
      }
    });
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _selectedDate = selectedDate;
        });
      }
    });
  }

  // Mock data methods
  List<Map<String, dynamic>> _getEventsForDateAndHour(DateTime date, int hour) {
    final allEvents = _getAllScheduleEvents();
    return allEvents.where((event) {
      final eventDate = DateTime.parse(event['date']);
      final eventHour = int.parse(event['startTime'].split(':')[0]);
      return _isSameDay(eventDate, date) && eventHour == hour;
    }).toList();
  }

  List<Map<String, dynamic>> _getDayEvents(DateTime date) {
    final allEvents = _getAllScheduleEvents();
    return allEvents.where((event) {
      final eventDate = DateTime.parse(event['date']);
      return _isSameDay(eventDate, date);
    }).toList();
  }

  List<Map<String, dynamic>> _getUpcomingEvents() {
    final now = DateTime.now();
    final allEvents = _getAllScheduleEvents();

    return allEvents
        .where((event) {
          final eventDate = DateTime.parse(event['date']);
          final eventTime = _parseTime(event['startTime']);
          final eventDateTime = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
            eventTime.hour,
            eventTime.minute,
          );
          return eventDateTime.isAfter(now);
        })
        .take(5)
        .toList();
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  List<Map<String, dynamic>> _getAllScheduleEvents() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    return [
      // Today's events
      {
        'id': '1',
        'title': 'Mathematics - Linear Algebra',
        'type': 'class',
        'date': today.toIso8601String(),
        'startTime': '09:00',
        'endTime': '10:30',
        'duration': '1h 30m',
        'location': 'Room 301',
        'description': 'Chapter 5: Vector Spaces',
      },
      {
        'id': '2',
        'title': 'Free Time',
        'type': 'free',
        'date': today.toIso8601String(),
        'startTime': '10:45',
        'endTime': '12:00',
        'duration': '1h 15m',
        'location': 'Library',
        'description': 'Perfect for Physics Lab Report',
      },
      {
        'id': '3',
        'title': 'Physics Lab Report',
        'type': 'study',
        'date': today.toIso8601String(),
        'startTime': '12:00',
        'endTime': '12:45',
        'duration': '45m',
        'location': 'Study Hall',
        'description': 'Work on pendulum motion analysis',
        'completed': false,
      },
      {
        'id': '4',
        'title': 'Lunch Break',
        'type': 'break',
        'date': today.toIso8601String(),
        'startTime': '13:00',
        'endTime': '14:00',
        'duration': '1h',
        'location': 'Cafeteria',
      },
      {
        'id': '5',
        'title': 'Computer Science',
        'type': 'class',
        'date': today.toIso8601String(),
        'startTime': '14:00',
        'endTime': '16:00',
        'duration': '2h',
        'location': 'Lab 205',
        'description': 'Data Structures and Algorithms',
      },
      {
        'id': '6',
        'title': 'Math Assignment Review',
        'type': 'study',
        'date': today.toIso8601String(),
        'startTime': '16:30',
        'endTime': '17:30',
        'duration': '1h',
        'location': 'Dorm',
        'description': 'Chapter 5 exercises',
        'completed': true,
      },

      // Tomorrow's events
      {
        'id': '7',
        'title': 'Physics Lab',
        'type': 'class',
        'date': tomorrow.toIso8601String(),
        'startTime': '09:00',
        'endTime': '11:00',
        'duration': '2h',
        'location': 'Physics Lab',
        'description': 'Pendulum motion experiment',
      },
      {
        'id': '8',
        'title': 'Chemistry',
        'type': 'class',
        'date': tomorrow.toIso8601String(),
        'startTime': '13:00',
        'endTime': '14:30',
        'duration': '1h 30m',
        'location': 'Room 402',
        'description': 'Organic Chemistry - Chapter 3',
      },
      {
        'id': '9',
        'title': 'History Essay Work',
        'type': 'study',
        'date': tomorrow.toIso8601String(),
        'startTime': '15:00',
        'endTime': '17:00',
        'duration': '2h',
        'location': 'Library',
        'description': 'Industrial Revolution research',
        'completed': false,
      },

      // Day after tomorrow
      {
        'id': '10',
        'title': 'Physics Quiz',
        'type': 'exam',
        'date': dayAfterTomorrow.toIso8601String(),
        'startTime': '10:00',
        'endTime': '11:00',
        'duration': '1h',
        'location': 'Room 301',
        'description': 'Thermodynamics quiz',
      },
    ];
  }

  // Action methods
  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: const Text('Add event form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add Event'),
          ),
        ],
      ),
    );
  }

  void _showQuickScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Schedule'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI will automatically schedule your pending tasks in optimal time slots.',
            ),
            SizedBox(height: 16),
            Text('This will:'),
            Text('• Schedule 3 pending tasks'),
            Text('• Use 2.5 hours of free time'),
            Text('• Optimize for your energy levels'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tasks scheduled automatically! ✨'),
                ),
              );
            },
            child: const Text('Schedule Now'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${event['type']}'),
            Text('Time: ${event['startTime']} - ${event['endTime']}'),
            Text('Duration: ${event['duration']}'),
            if (event['location'] != null)
              Text('Location: ${event['location']}'),
            if (event['description'] != null)
              Text('Description: ${event['description']}'),
          ],
        ),
        actions: [
          if (event['type'] == 'study') ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Mark as completed
              },
              child: Text(
                event['completed'] ? 'Mark Incomplete' : 'Mark Complete',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Edit event
              },
              child: const Text('Edit'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _scheduleOptimalTime(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Physics Lab Report scheduled for 10:45-12:00 at Library! 📚',
        ),
        action: SnackBarAction(label: 'View', onPressed: () => {}),
      ),
    );
  }
}
