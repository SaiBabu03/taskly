import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/Main_Screens/Login_Screen.dart';
import 'package:taskly/blocs/auth/auth_bloc.dart';
import 'package:taskly/blocs/auth/auth_event.dart';
import 'package:taskly/blocs/auth/auth_state.dart';

// Ensure these imports match the package name in your pubspec.yaml exactly
import 'package:taskly/models/task_model.dart';
import 'package:taskly/blocs/tasks/task_bloc.dart';
import 'package:taskly/blocs/tasks/tasks_event.dart';
import 'package:taskly/blocs/tasks/tasks_state.dart';

class MainTasksScreen extends StatefulWidget {
  const MainTasksScreen({super.key});

  @override
  State<MainTasksScreen> createState() => _MainTasksScreenState();
}

class _MainTasksScreenState extends State<MainTasksScreen> {
  int _currentTab = 0;
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  // Search state
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final Map<String, Color> availableCategories = {
    "Personal": Colors.orange,
    "Work": Colors.brown,
    "Study": Colors.blue,
    "App": Colors.deepPurpleAccent,
  };

  @override
  @override
  Widget build(BuildContext context) {
    // 1. Wrap with BlocListener to handle "Side Effects" like navigation
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // 2. Clear the navigation stack and go to Login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // This prevents the user from going "Back" to tasks
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            List<Task> allTasks = [];
            if (state is TasksLoaded) {
              allTasks = state.tasks;
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: state is TasksLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _currentTab == 0
                      ? _buildGroupedListView(allTasks)
                      : _buildCalendarView(allTasks),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskSheet(context),
          backgroundColor: const Color(0xFF7E7CF7),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // --- HEADER WITH SEARCH ---
  // --- HEADER WITH SEARCH & LOGOUT ---
  // --- HEADER WITH SEARCH & LOGOUT ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        color: Color(0xFF7E7CF7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black54,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(right: 15, bottom: 2),
                      isDense: true,
                    ),
                  ),
                ),
              ),

              // --- UPDATED: POPUP MENU FOR SIGN OUT ---
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 26,
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    // 1. Trigger the logic in AuthBloc
                    context.read<AuthBloc>().add(SignOutRequested());
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Sign Out",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            "Today, ${DateFormat('d MMM').format(DateTime.now())}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const Text(
            "My tasks",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Dismissible(
      key: Key(task.id), // Unique key for the task
      direction: DismissDirection.endToStart, // Swipe right-to-left
      onDismissed: (direction) {
        // TRIGGER THE ACTUAL DELETE HERE
        context.read<TasksBloc>().add(DeleteTask(task.id));

        // Optional: Show a snackbar with an undo option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "${task.title}" deleted')),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () {
            setState(() {
              task.isExpanded = !task.isExpanded;
            });
          },
          // Trigger the Edit sheet on Long Press
          onLongPress: () => _showAddTaskSheet(context, existingTask: task),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Checkbox Logic
                    GestureDetector(
                      onTap: () => context.read<TasksBloc>().add(ToggleTask(task.id)),
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.isCompleted ? Colors.transparent : const Color(0xFF7E7CF7),
                            width: 1.5,
                          ),
                          color: task.isCompleted ? const Color(0xFF7E7CF7) : Colors.transparent,
                        ),
                        child: task.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? Colors.grey : const Color(0xFF2D3142),
                        ),
                      ),
                    ),
                    _buildPriorityBadge(task.priority),
                  ],
                ),

                // Description (Visible when expanded)
                if (task.isExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 34, top: 2),
                    child: Text(
                      task.description.isEmpty ? "No description." : task.description,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],

                // Date & Tags
                Padding(
                  padding: const EdgeInsets.only(left: 34, top: 2),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMM d').format(task.date),
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                      const SizedBox(width: 10),
                      if (task.tags.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            children: task.tags.asMap().entries.map((e) {
                              return _buildTag(e.value, task.tagColors[e.key]);
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// 1. REFINED SMALL PRIORITY BADGE
  Widget _buildPriorityBadge(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.high: color = Colors.red; break;
      case TaskPriority.medium: color = Colors.orange; break;
      case TaskPriority.low: color = Colors.green; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // Tighter padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), // Softer background
        borderRadius: BorderRadius.circular(3), // Sharper corners for a "technical" look
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12, // REDUCED: Smaller font for priority
          fontWeight: FontWeight.w900, // Thicker font to remain readable
          letterSpacing: 0.5,
        ),
      ),
    );
  }

// 2. REFINED SMALL TAGS
  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
  //
  // Widget _buildTag(String text, Color color) {
  //   return Container(
  //     margin: const EdgeInsets.only(left: 4),
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.12),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Text(
  //       text,
  //       style: TextStyle(
  //         color: color,
  //         fontSize: 10,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }

  // --- GROUPED LIST VIEW ---
  Widget _buildGroupedListView(List<Task> tasks) {
    final filteredTasks = tasks
        .where((t) => t.title.toLowerCase().contains(_searchQuery))
        .toList();
    if (filteredTasks.isEmpty) return _buildEmptyState();

    List<Task> today = filteredTasks
        .where((t) => DateUtils.isSameDay(t.date, DateTime.now()))
        .toList();
    List<Task> tomorrow = filteredTasks
        .where(
          (t) => DateUtils.isSameDay(
            t.date,
            DateTime.now().add(const Duration(days: 1)),
          ),
        )
        .toList();
    List<Task> upcoming = filteredTasks
        .where(
          (t) => t.date.isAfter(DateTime.now().add(const Duration(days: 1))),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (today.isNotEmpty) ...[
          _sectionHeader("Today"),
          ...today.map((t) => _buildTaskCard(t)),
        ],
        if (tomorrow.isNotEmpty) ...[
          _sectionHeader("Tomorrow"),
          ...tomorrow.map((t) => _buildTaskCard(t)),
        ],
        if (upcoming.isNotEmpty) ...[
          _sectionHeader("Upcoming"),
          ...upcoming.map((t) => _buildTaskCard(t)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  // --- CALENDAR VIEW ---
  Widget _buildCalendarView(List<Task> tasks) {
    return Column(
      children: [
        _buildMonthlyGrid(tasks),
        const Divider(height: 1),
        Expanded(child: _buildFilteredTaskList(tasks)),
      ],
    );
  }

  Widget _buildMonthlyGrid(List<Task> tasks) {
    int daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    int weekdayOffset =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(
                      () => _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month - 1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(
                      () => _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month + 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: daysInMonth + weekdayOffset,
            itemBuilder: (context, index) {
              if (index < weekdayOffset) return const SizedBox();
              int day = index - weekdayOffset + 1;
              DateTime date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              bool isSelected = DateUtils.isSameDay(date, _selectedDate);
              bool hasTasks = tasks.any(
                (t) => DateUtils.isSameDay(t.date, date),
              );

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7E7CF7)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$day",
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (hasTasks)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF7E7CF7),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredTaskList(List<Task> tasks) {
    final filtered = tasks
        .where(
          (t) =>
              DateUtils.isSameDay(t.date, _selectedDate) &&
              t.title.toLowerCase().contains(_searchQuery),
        )
        .toList();
    if (filtered.isEmpty) return const Center(child: Text("No tasks found"));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildTaskCard(filtered[i]),
    );
  }

  // --- HELPERS ---
  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_outlined, size: 70, color: Colors.grey.shade200),
        const Text("No tasks found"),
      ],
    ),
  );

  Widget _buildBottomBar() {
    return BottomAppBar(
      height: 70,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.list_rounded,
              color: _currentTab == 0 ? const Color(0xFF7E7CF7) : Colors.grey,
              size: 28,
            ),
            onPressed: () => setState(() => _currentTab = 0),
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              color: _currentTab == 1 ? const Color(0xFF7E7CF7) : Colors.grey,
              size: 22,
            ),
            onPressed: () => setState(() => _currentTab = 1),
          ),
        ],
      ),
    );
  }
  void _showAddTaskSheet(BuildContext context, {Task? existingTask}) {
    TextEditingController titleController = TextEditingController(text: existingTask?.title ?? "");
    TextEditingController descController = TextEditingController(text: existingTask?.description ?? "");
    TextEditingController customCatController = TextEditingController();

    TaskPriority selectedPriority = existingTask?.priority ?? TaskPriority.medium;
    // Initialize tags from the existing task or start empty
    List<String> selectedTags = existingTask != null ? List.from(existingTask.tags) : [];
    DateTime taskDate = existingTask?.date ?? _selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(existingTask == null ? "New Task" : "Edit Task",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    TextField(
                        controller: titleController,
                        decoration: const InputDecoration(hintText: "What needs to be done?")),
                    const SizedBox(height: 10),

                    TextField(
                        controller: descController,
                        decoration: const InputDecoration(hintText: "Add a description...")),
                    const SizedBox(height: 15),

                    const Text("Priority", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: TaskPriority.values.map((p) {
                        bool isSel = selectedPriority == p;
                        return ChoiceChip(
                          label: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                          selected: isSel,
                          onSelected: (val) => setModalState(() => selectedPriority = p),
                          selectedColor: const Color(0xFF7E7CF7).withOpacity(0.2),
                        );
                      }).toList(),
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Date: ${DateFormat('yMMMMd').format(taskDate)}"),
                      trailing: const Icon(Icons.calendar_month, color: Color(0xFF7E7CF7)),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: taskDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime(2030));
                        if (picked != null) setModalState(() => taskDate = picked);
                      },
                    ),

                    // --- RESTORED CATEGORY SECTION ---
                    const Text("Categories",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customCatController,
                            decoration: InputDecoration(
                              hintText: "Add custom category...",
                              hintStyle: const TextStyle(fontSize: 13),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFF7E7CF7), size: 30),
                          onPressed: () {
                            if (customCatController.text.isNotEmpty) {
                              String newCat = customCatController.text.trim();
                              // Update the main state for available colors
                              setState(() { availableCategories[newCat] = Colors.blueGrey; });
                              // Update the modal state to select it
                              setModalState(() {
                                if (!selectedTags.contains(newCat)) selectedTags.add(newCat);
                              });
                              customCatController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: availableCategories.keys.map((cat) => FilterChip(
                        label: Text(cat, style: const TextStyle(fontSize: 12)),
                        selected: selectedTags.contains(cat),
                        onSelected: (bool selected) {
                          setModalState(() {
                            selected ? selectedTags.add(cat) : selectedTags.remove(cat);
                          });
                        },
                        selectedColor: availableCategories[cat]!.withOpacity(0.3),
                        checkmarkColor: availableCategories[cat],
                      )).toList(),
                    ),
                    // --- END OF CATEGORY SECTION ---

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E7CF7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            final updatedTask = Task(
                              id: existingTask?.id ?? DateTime.now().toString(),
                              title: titleController.text,
                              description: descController.text,
                              date: taskDate,
                              priority: selectedPriority,
                              tags: List.from(selectedTags),
                              tagColors: selectedTags.map((t) => availableCategories[t] ?? Colors.blueGrey).toList(),
                              isCompleted: existingTask?.isCompleted ?? false,
                            );

                            if (existingTask == null) {
                              context.read<TasksBloc>().add(AddTask(updatedTask));
                            } else {
                              context.read<TasksBloc>().add(UpdateTask(updatedTask));
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(existingTask == null ? "Create Task" : "Save Changes",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
