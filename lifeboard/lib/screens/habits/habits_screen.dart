// ═══════════════════════════════════════════════
//  HABITS SCREEN
// ═══════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

const _uuid = Uuid();

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final habits = state.habits;
    final maxStreak = habits.isEmpty ? 0
        : habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Habit Tracker', style: AppText.heading),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Stats row
          Row(children: [
            Expanded(child: GlassCard(
              accentColor: AppTheme.orange,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Best Streak', style: AppText.label),
                const SizedBox(height: 4),
                Text('$maxStreak 🔥', style: AppText.statNumber.copyWith(
                    fontSize: 32, color: AppTheme.orange)),
              ]),
            )),
            const SizedBox(width: 12),
            Expanded(child: GlassCard(
              accentColor: AppTheme.green,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Today Done', style: AppText.label),
                const SizedBox(height: 4),
                Text('${habits.where((h) => h.isCompletedToday()).length}/${habits.length}',
                  style: AppText.statNumber.copyWith(fontSize: 32, color: AppTheme.green)),
              ]),
            )),
          ]),
          const SizedBox(height: 20),

          // Habits list
          ...habits.map((habit) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HabitCard(habit: habit),
          )),

          const SizedBox(height: 12),

          // Heatmap
          if (habits.isNotEmpty) _HeatmapSection(habits: habits),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabit(context, state),
        backgroundColor: AppTheme.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Habit', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showAddHabit(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController();
    String emoji = '⭐';
    Color color = AppTheme.green;
    final emojis = ['⭐', '🏋️', '📚', '🧘', '💻', '💧', '🏃', '🎯', '🌱', '💊'];
    final colors = [AppTheme.green, AppTheme.blue, AppTheme.purple,
        AppTheme.orange, AppTheme.pink, AppTheme.yellow];

    AppBottomSheet.show(context,
      title: 'New Habit',
      accentColor: AppTheme.purple,
      child: StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Habit Name'),
            ),
            const SizedBox(height: 16),
            Text('EMOJI', style: AppText.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: emojis.map((e) => GestureDetector(
                onTap: () => setS(() => emoji = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: emoji == e ? AppTheme.surface3 : AppTheme.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: emoji == e ? AppTheme.green : AppTheme.border),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text('COLOR', style: AppText.label),
            const SizedBox(height: 8),
            Row(children: colors.map((c) => GestureDetector(
              onTap: () => setS(() => color = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 32, height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: color == c ? Border.all(
                    color: Colors.white, width: 3) : null,
                  boxShadow: color == c ? [BoxShadow(
                    color: c.withOpacity(0.5), blurRadius: 8)] : null,
                ),
              ),
            )).toList()),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purple,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                state.addHabit(HabitModel(
                  id: _uuid.v4(),
                  name: nameCtrl.text.trim(),
                  emoji: emoji,
                  color: color,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Create Habit',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final HabitModel habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final done = habit.isCompletedToday();

    return GlassCard(
      accentColor: habit.color,
      child: Row(children: [
        // Emoji + toggle
        GestureDetector(
          onTap: () => state.toggleHabitToday(habit.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: done ? habit.color.withOpacity(0.2) : AppTheme.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: done ? habit.color.withOpacity(0.5) : AppTheme.border,
              ),
            ),
            child: Center(child: Text(habit.emoji,
                style: const TextStyle(fontSize: 26))),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(habit.name, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Row(children: [
            Text('${habit.currentStreak}d streak', style: TextStyle(
                fontSize: 11, color: habit.color, fontWeight: FontWeight.w500)),
            const Text(' · ', style: TextStyle(color: AppTheme.textMuted)),
            Text('${(habit.completionRate * 100).round()}% rate',
                style: AppText.label),
          ]),
          const SizedBox(height: 8),
          // Last 7 days mini dots
          Row(children: List.generate(7, (i) {
            final date = DateTime.now().subtract(Duration(days: 6 - i));
            final done = habit.completedDates.any((d) =>
                d.year == date.year && d.month == date.month && d.day == date.day);
            return Container(
              width: 20, height: 20,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: done ? habit.color.withOpacity(0.7) : AppTheme.surface3,
                borderRadius: BorderRadius.circular(5),
              ),
              child: done ? Icon(Icons.check_rounded, size: 12,
                  color: Colors.black.withOpacity(0.7)) : null,
            );
          })),
        ])),
        if (done) ...[
          const SizedBox(width: 8),
          Icon(Icons.check_circle_rounded, color: habit.color, size: 24),
        ],
      ]),
    );
  }
}

class _HeatmapSection extends StatelessWidget {
  final List<HabitModel> habits;
  const _HeatmapSection({required this.habits});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: AppTheme.purple,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ACTIVITY HEATMAP — LAST 60 DAYS', style: AppText.cardTitle),
        const SizedBox(height: 14),
        Wrap(
          spacing: 4, runSpacing: 4,
          children: List.generate(60, (i) {
            final date = DateTime.now().subtract(Duration(days: 59 - i));
            final count = habits.where((h) => h.completedDates.any((d) =>
                d.year == date.year && d.month == date.month && d.day == date.day)).length;
            final opacity = habits.isEmpty ? 0.0 : count / habits.length;
            return Tooltip(
              message: '${count}/${habits.length} habits',
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: opacity == 0 ? AppTheme.surface3
                      : AppTheme.purple.withOpacity(0.2 + opacity * 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}
