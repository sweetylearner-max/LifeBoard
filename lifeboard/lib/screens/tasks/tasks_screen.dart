import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

const _uuid = Uuid();

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _selectedCategory = 'All';

  final _categories = ['All', 'Work', 'Health', 'Learning', 'Personal', 'Career'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final all = state.tasks;
    final today = state.todayTasks;
    final done = today.where((t) => t.isDone).toList();
    final pending = today.where((t) => !t.isDone).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Task Manager', style: AppText.heading),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.blue.withOpacity(0.25)),
            ),
            child: Text('${done.length}/${today.length} done',
              style: const TextStyle(fontSize: 11, color: AppTheme.blue,
                  fontWeight: FontWeight.w600)),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.blue,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All Tasks'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // TODAY TAB
          _TaskList(
            tasks: pending,
            categories: _categories,
            selectedCat: _selectedCategory,
            onCatChange: (c) => setState(() => _selectedCategory = c),
            emptyEmoji: '🎉',
            emptyTitle: 'All Done!',
            emptySub: 'You completed all tasks for today',
          ),
          // ALL TASKS
          _TaskList(
            tasks: all,
            categories: _categories,
            selectedCat: _selectedCategory,
            onCatChange: (c) => setState(() => _selectedCategory = c),
            emptyEmoji: '📝',
            emptyTitle: 'No Tasks',
            emptySub: 'Add your first task below',
          ),
          // COMPLETED
          _TaskList(
            tasks: done,
            categories: _categories,
            selectedCat: _selectedCategory,
            onCatChange: (c) => setState(() => _selectedCategory = c),
            emptyEmoji: '✅',
            emptyTitle: 'Nothing Done Yet',
            emptySub: 'Complete tasks to see them here',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTask(context, state),
        backgroundColor: AppTheme.blue,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showAddTask(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    String category = 'Work';
    DateTime? dueDate;

    AppBottomSheet.show(context,
      title: 'New Task',
      accentColor: AppTheme.blue,
      child: StatefulBuilder(
        builder: (ctx, setS) => Column(
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'What needs to be done?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('PRIORITY', style: AppText.label),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((p) {
                final colors = [AppTheme.pink, AppTheme.orange, AppTheme.purple];
                final labels = ['High', 'Medium', 'Low'];
                final selected = priority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setS(() => priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? colors[p.index].withOpacity(0.15) : AppTheme.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? colors[p.index].withOpacity(0.5) : AppTheme.border,
                        ),
                      ),
                      child: Text(labels[p.index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? colors[p.index] : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('CATEGORY', style: AppText.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ['Work', 'Health', 'Learning', 'Personal', 'Career', 'Finance']
                  .map((c) => AppChip(
                    label: c,
                    selected: category == c,
                    onTap: () => setS(() => category = c),
                    color: AppTheme.blue,
                  )).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.blue,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                state.addTask(TaskModel(
                  id: _uuid.v4(),
                  title: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  priority: priority,
                  category: category,
                  createdAt: DateTime.now(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add Task', style: TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<String> categories;
  final String selectedCat;
  final Function(String) onCatChange;
  final String emptyEmoji, emptyTitle, emptySub;

  const _TaskList({
    required this.tasks, required this.categories,
    required this.selectedCat, required this.onCatChange,
    required this.emptyEmoji, required this.emptyTitle, required this.emptySub,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filtered = selectedCat == 'All'
        ? tasks : tasks.where((t) => t.category == selectedCat).toList();

    return Column(
      children: [
        // Category chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: categories.length,
            itemBuilder: (_, i) => AppChip(
              label: categories[i],
              selected: selectedCat == categories[i],
              onTap: () => onCatChange(categories[i]),
              color: AppTheme.blue,
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(emoji: emptyEmoji, title: emptyTitle, subtitle: emptySub)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final t = filtered[i];
                    return Dismissible(
                      key: Key(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.pink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppTheme.pink),
                      ),
                      onDismissed: (_) => state.deleteTask(t.id),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () => state.toggleTask(t.id),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: t.isDone ? AppTheme.green : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: t.isDone ? AppTheme.green : AppTheme.textMuted,
                                  width: 1.5,
                                ),
                              ),
                              child: t.isDone
                                  ? const Icon(Icons.check_rounded, size: 15,
                                      color: Colors.black)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.title, style: TextStyle(
                                    fontSize: 14,
                                    color: t.isDone ? AppTheme.textMuted : AppTheme.textPrimary,
                                    decoration: t.isDone ? TextDecoration.lineThrough : null,
                                    fontWeight: FontWeight.w500,
                                  )),
                                  if (t.description != null) ...[
                                    const SizedBox(height: 2),
                                    Text(t.description!, style: AppText.label,
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                  if (t.category != null) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(t.category!, style: TextStyle(
                                        fontSize: 10, color: AppTheme.blue)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            PriorityDot(color: t.priorityColor),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
