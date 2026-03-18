import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../services/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

const _uuidG = Uuid();

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

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
    final active = state.goals.where((g) => !g.isCompleted).toList();
    final completed = state.goals.where((g) => g.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Goal Tracker', style: AppText.heading),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.green,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: [
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Add Goal'),
            Tab(text: 'Done (${completed.length})'),
          ],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _buildActiveGoals(context, state, active),
        _buildAddGoal(context, state),
        _buildCompleted(completed),
      ]),
    );
  }

  Widget _buildActiveGoals(BuildContext context, AppState state, List<GoalModel> goals) {
    if (goals.isEmpty) {
      return const EmptyState(emoji: '🎯', title: 'No Active Goals',
          subtitle: 'Add a goal to start tracking your progress');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: goals.length,
      itemBuilder: (_, i) => _GoalCard(goal: goals[i]),
    );
  }

  Widget _buildAddGoal(BuildContext context, AppState state) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    GoalCategory category = GoalCategory.personal;
    Color color = AppTheme.green;
    DateTime? targetDate;
    final milestoneCtrl = TextEditingController();
    final List<String> milestones = [];

    final categoryColors = {
      GoalCategory.personal: AppTheme.green,
      GoalCategory.career: AppTheme.blue,
      GoalCategory.health: AppTheme.pink,
      GoalCategory.finance: AppTheme.orange,
      GoalCategory.education: AppTheme.purple,
      GoalCategory.creative: AppTheme.yellow,
    };

    return StatefulBuilder(
      builder: (ctx, setS) => ListView(padding: const EdgeInsets.all(20), children: [
        TextField(
          controller: titleCtrl,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16,
              fontWeight: FontWeight.w600),
          decoration: const InputDecoration(labelText: 'Goal Title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descCtrl,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Text('CATEGORY', style: AppText.cardTitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: GoalCategory.values.map((c) {
            final labels = ['Personal', 'Career', 'Health', 'Finance', 'Education', 'Creative'];
            final emojis = ['⭐', '💼', '❤️', '₹', '📚', '🎨'];
            final sel = category == c;
            final clr = categoryColors[c]!;
            return GestureDetector(
              onTap: () => setS(() { category = c; color = clr; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? clr.withOpacity(0.15) : AppTheme.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? clr.withOpacity(0.5) : AppTheme.border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(emojis[c.index], style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(labels[c.index], style: TextStyle(
                    fontSize: 12, color: sel ? clr : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  )),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Target date
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: ctx,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
              builder: (_, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: AppTheme.green),
                ),
                child: child!,
              ),
            );
            if (d != null) setS(() => targetDate = d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.textMuted),
              const SizedBox(width: 10),
              Text(
                targetDate != null
                    ? DateFormat('MMM d, yyyy').format(targetDate!)
                    : 'Set Target Date',
                style: TextStyle(
                  color: targetDate != null ? AppTheme.textPrimary : AppTheme.textMuted,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        // Milestones
        Text('MILESTONES', style: AppText.cardTitle),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(
            controller: milestoneCtrl,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: const InputDecoration(hintText: 'Add milestone...'),
          )),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (milestoneCtrl.text.isNotEmpty) {
                setS(() { milestones.add(milestoneCtrl.text); milestoneCtrl.clear(); });
              }
            },
            icon: const Icon(Icons.add_circle_rounded, color: AppTheme.green),
          ),
        ]),
        if (milestones.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...milestones.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              const Text('▸ ', style: TextStyle(color: AppTheme.green)),
              Expanded(child: Text(m, style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary))),
              GestureDetector(
                onTap: () => setS(() => milestones.remove(m)),
                child: const Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
              ),
            ]),
          )),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () {
            if (titleCtrl.text.trim().isEmpty) return;
            state.addGoal(GoalModel(
              id: _uuidG.v4(),
              title: titleCtrl.text.trim(),
              description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
              category: category,
              createdAt: DateTime.now(),
              targetDate: targetDate,
              color: color,
              milestones: milestones,
            ));
            titleCtrl.clear(); descCtrl.clear();
            setS(() { milestones.clear(); targetDate = null; });
            _tab.animateTo(0);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎯 Goal added!')));
          },
          child: const Text('Create Goal',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 15)),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildCompleted(List<GoalModel> goals) {
    if (goals.isEmpty) {
      return const EmptyState(emoji: '🏆', title: 'No Completed Goals Yet',
          subtitle: 'Complete your active goals to see them here');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: goals.length,
      itemBuilder: (_, i) => _GoalCard(goal: goals[i]),
    );
  }
}

class _GoalCard extends StatefulWidget {
  final GoalModel goal;
  const _GoalCard({required this.goal});
  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;
    final state = context.read<AppState>();
    final daysLeft = g.daysLeft;

    return GlassCard(
      accentColor: g.color,
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(g.categoryEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(g.title, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
          if (daysLeft != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: daysLeft < 7 ? AppTheme.pink.withOpacity(0.15) : AppTheme.surface3,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$daysLeft days', style: TextStyle(
                  fontSize: 10, color: daysLeft < 7 ? AppTheme.pink : AppTheme.textMuted)),
            ),
          const SizedBox(width: 8),
          Text('${(g.progress * 100).round()}%',
            style: TextStyle(fontSize: 13, color: g.color, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: g.progress),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => MiniProgressBar(progress: v, color: g.color, height: 6),
        ),
        if (_expanded) ...[
          const SizedBox(height: 14),
          if (g.description != null)
            Text(g.description!, style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
          if (g.milestones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('MILESTONES', style: AppText.cardTitle),
            const SizedBox(height: 8),
            ...g.milestones.map((m) {
              final done = g.completedMilestones.contains(m);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Icon(
                    done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 16, color: done ? g.color : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(m, style: TextStyle(
                    fontSize: 12,
                    color: done ? AppTheme.textMuted : AppTheme.textPrimary,
                    decoration: done ? TextDecoration.lineThrough : null,
                  )),
                ]),
              );
            }),
          ],
          const SizedBox(height: 14),
          // Progress slider
          Text('UPDATE PROGRESS', style: AppText.label),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: g.color,
              thumbColor: g.color,
              inactiveTrackColor: AppTheme.surface3,
              overlayColor: g.color.withOpacity(0.2),
            ),
            child: Slider(
              value: g.progress,
              onChanged: (v) => state.updateGoalProgress(g.id, v),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: () => state.deleteGoal(g.id),
              child: const Text('Delete', style: TextStyle(color: AppTheme.pink, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            if (!g.isCompleted)
              ElevatedButton(
                onPressed: () => state.updateGoalProgress(g.id, 1.0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: g.color,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Mark Complete',
                    style: TextStyle(fontSize: 12, color: Colors.black,
                        fontWeight: FontWeight.w700)),
              ),
          ]),
        ],
      ]),
    );
  }
}
