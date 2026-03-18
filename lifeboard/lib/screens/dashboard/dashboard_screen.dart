import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/habits/habits_screen.dart';
import '../screens/finance/finance_screen.dart';
import '../screens/health/health_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/focus/focus_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _gridCtrl;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _gridCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _gridCtrl.forward());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _gridCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── APP BAR ───────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bg.withOpacity(0.95),
            elevation: 0,
            expandedHeight: 0,
            toolbarHeight: 60,
            flexibleSpace: FadeTransition(
              opacity: _headerAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        gradient: AppGradients.greenPurple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(
                          color: AppTheme.green.withOpacity(0.3),
                          blurRadius: 12,
                        )],
                      ),
                      child: const Center(
                        child: Text('⬡', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (r) => AppGradients.greenPurple.createShader(r),
                      child: Text('LifeBoard',
                        style: AppText.heading.copyWith(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Life Score chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.green.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(
                              color: AppTheme.green,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: AppTheme.green.withOpacity(0.6),
                                blurRadius: 6,
                              )],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Score: ${state.lifeScore}',
                            style: TextStyle(
                              fontSize: 12, color: AppTheme.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Notification
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                        size: 20, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── GREETING ────────────────────────
                  FadeTransition(
                    opacity: _headerAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                          .animate(_headerAnim),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: AppText.displayLarge.copyWith(fontSize: 30),
                              children: [
                                TextSpan(text: '${_greeting()}, '),
                                TextSpan(
                                  text: state.profile.name,
                                  style: TextStyle(
                                    color: AppTheme.green,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const TextSpan(text: ' 👋'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE · MMMM d, yyyy').format(DateTime.now())
                                .toUpperCase() +
                            ' · WEEK ${_weekOfYear()} OF 52',
                            style: AppText.label,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── XP BAR ──────────────────────────
                  FadeTransition(
                    opacity: _headerAnim,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.yellow.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('⚡', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Level ${state.profile.level} · ${state.profile.levelTitle}',
                                      style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${state.profile.xp} / ${state.profile.totalXpForLevel} XP',
                                      style: TextStyle(
                                        fontSize: 11, color: AppTheme.yellow,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: state.profile.xpProgress),
                                  duration: const Duration(milliseconds: 1200),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, v, __) => MiniProgressBar(
                                    progress: v,
                                    color: AppTheme.yellow,
                                    height: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── DASHBOARD GRID ──────────────────
                  _DashboardGrid(animCtrl: _gridCtrl),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _weekOfYear() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    return ((now.difference(start).inDays) / 7).ceil();
  }
}

// ─── DASHBOARD GRID ──────────────────────────────────────
class _DashboardGrid extends StatelessWidget {
  final AnimationController animCtrl;

  const _DashboardGrid({required this.animCtrl});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _FocusTimerCard(),
      _HabitCard(),
      _TaskCard(),
      _FinanceCard(),
      _HealthCard(),
      _JournalCard(),
      _GoalsCard(),
      _AnalyticsCard(),
    ];

    return Column(
      children: List.generate(cards.length, (i) {
        return AnimatedBuilder(
          animation: animCtrl,
          builder: (_, child) {
            final delay = (i * 0.1).clamp(0.0, 0.8);
            final t = ((animCtrl.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
            final curve = Curves.easeOutCubic.transform(t);
            return Opacity(
              opacity: curve,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - curve)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: cards[i],
          ),
        );
      }),
    );
  }
}

// ─── CARD 1: FOCUS TIMER ─────────────────────────────────
class _FocusTimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: AppTheme.green,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const FocusScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: 'Focus Timer', emoji: '⏱',
              badge: 'POMODORO', badgeColor: AppTheme.green),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (r) => LinearGradient(
                        colors: [AppTheme.green, AppTheme.green.withOpacity(0.6)],
                      ).createShader(r),
                      child: Text('25:00',
                        style: AppText.statNumber.copyWith(
                          fontSize: 52, color: Colors.white,
                        ),
                      ),
                    ),
                    Text('Ready to focus', style: AppText.label),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(4, (i) => Container(
                        width: 10, height: 10,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: i < 2 ? AppTheme.green : AppTheme.surface3,
                          shape: BoxShape.circle,
                          boxShadow: i < 2 ? [BoxShadow(
                            color: AppTheme.green.withOpacity(0.5), blurRadius: 6,
                          )] : null,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _PomoButton(label: '▶ Start', color: AppTheme.green),
                  const SizedBox(height: 8),
                  _PomoButton(label: '↺ Reset', color: AppTheme.textMuted, outlined: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PomoButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  const _PomoButton({required this.label, required this.color, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: outlined ? AppTheme.surface2 : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: outlined ? AppTheme.border : color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 12, color: outlined ? AppTheme.textMuted : color,
        fontWeight: FontWeight.w700,
      )),
    );
  }
}

// ─── CARD 2: HABITS ──────────────────────────────────────
class _HabitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final habits = state.habits;
    final maxStreak = habits.isEmpty ? 0 :
        habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);

    return GlassCard(
      accentColor: AppTheme.purple,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const HabitsScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: 'Habits', emoji: '🔥',
              badge: '$maxStreak-day streak', badgeColor: AppTheme.orange),
          const SizedBox(height: 16),
          // Habit dots
          Wrap(
            spacing: 8, runSpacing: 8,
            children: habits.map((h) {
              final done = h.isCompletedToday();
              return GestureDetector(
                onTap: () => state.toggleHabitToday(h.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: done ? h.color.withOpacity(0.15) : AppTheme.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: done ? h.color.withOpacity(0.4) : AppTheme.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(h.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(h.name, style: TextStyle(
                        fontSize: 12, color: done ? h.color : AppTheme.textSecondary,
                        fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                      )),
                      if (done) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.check_circle_rounded, size: 14, color: h.color),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Mini heatmap row
          Row(
            children: List.generate(14, (i) {
              final date = DateTime.now().subtract(Duration(days: 13 - i));
              final anyDone = habits.any((h) => h.completedDates.any((d) =>
                  d.year == date.year && d.month == date.month && d.day == date.day));
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: anyDone ? AppTheme.purple.withOpacity(0.6) : AppTheme.surface3,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── CARD 3: TASKS ───────────────────────────────────────
class _TaskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tasks = state.todayTasks;
    final done = tasks.where((t) => t.isDone).length;

    return GlassCard(
      accentColor: AppTheme.blue,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const TasksScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: "Today's Tasks", emoji: '✅',
              badge: '$done of ${tasks.length}', badgeColor: AppTheme.blue),
          const SizedBox(height: 14),
          // Progress
          MiniProgressBar(
            progress: tasks.isEmpty ? 0 : done / tasks.length,
            color: AppTheme.blue,
            height: 4,
          ),
          const SizedBox(height: 14),
          // First 4 tasks
          ...tasks.take(4).map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => state.toggleTask(t.id),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: t.isDone ? AppTheme.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: t.isDone ? AppTheme.green : AppTheme.textMuted,
                        width: 1.5,
                      ),
                    ),
                    child: t.isDone
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.title,
                      style: TextStyle(
                        fontSize: 13,
                        color: t.isDone ? AppTheme.textMuted : AppTheme.textPrimary,
                        decoration: t.isDone ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PriorityDot(color: t.priorityColor, size: 6),
                ],
              ),
            ),
          )),
          if (tasks.length > 4)
            Text('+${tasks.length - 4} more', style: AppText.label),
        ],
      ),
    );
  }
}

// ─── CARD 4: FINANCE ─────────────────────────────────────
class _FinanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final fmt = NumberFormat('#,##,###', 'en_IN');

    return GlassCard(
      accentColor: AppTheme.orange,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const FinanceScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: 'Finance', emoji: '₹',
              badge: 'March 2026', badgeColor: AppTheme.orange),
          const SizedBox(height: 14),
          BigStat(
            value: '₹${fmt.format(state.totalBalance.abs())}',
            label: 'Available Balance',
            color: AppTheme.orange,
            fontSize: 34,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _FinancePill('Spent', '₹${fmt.format(state.monthlySpending)}', AppTheme.pink),
              const SizedBox(width: 8),
              _FinancePill('Saved', '₹${fmt.format(state.monthlySavings)}', AppTheme.green),
            ],
          ),
          const SizedBox(height: 12),
          // Spend bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Budget', style: AppText.label),
                  Text('${((state.monthlySpending / 30000) * 100).round()}%',
                    style: TextStyle(fontSize: 11, color: AppTheme.orange)),
                ],
              ),
              const SizedBox(height: 4),
              MiniProgressBar(
                progress: state.monthlySpending / 30000,
                color: AppTheme.orange,
                height: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FinancePill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.label),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(
              fontSize: 13, color: color, fontWeight: FontWeight.w700,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── CARD 5: HEALTH ──────────────────────────────────────
class _HealthCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final h = state.todayHealth;

    return GlassCard(
      accentColor: AppTheme.pink,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const HealthScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: 'Health', emoji: '❤️',
              badge: 'Today', badgeColor: AppTheme.pink),
          const SizedBox(height: 16),
          Row(
            children: [
              // Ring
              SizedBox(
                width: 80, height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: (h?.healthScore ?? 75) / 100),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => CircularProgressIndicator(
                        value: v, strokeWidth: 6,
                        backgroundColor: AppTheme.surface3,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.pink),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text('${h?.healthScore.round() ?? 75}%',
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.pink,
                      )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricRow('👟', 'Steps', '${h?.steps ?? 0}'),
                    _MetricRow('💧', 'Water', '${h?.waterLiters ?? 0}L'),
                    _MetricRow('🔥', 'Burned', '${h?.caloriesBurned ?? 0} kcal'),
                    _MetricRow('😴', 'Sleep', '${h?.sleepHours ?? 0}h'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String emoji, label, value;
  const _MetricRow(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Text(label, style: AppText.label),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12,
            color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// ─── CARD 6: JOURNAL ─────────────────────────────────────
class _JournalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final today = state.todayJournal;
    final moods = ['😫', '😞', '😐', '😊', '🤩'];

    return GlassCard(
      accentColor: AppTheme.purple,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const JournalScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: 'Journal', emoji: '📔',
              badge: today != null ? today.moodEmoji : 'Write today',
              badgeColor: AppTheme.purple),
          const SizedBox(height: 14),
          if (today != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                today.content.length > 100
                    ? '${today.content.substring(0, 100)}...'
                    : today.content,
                style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.5,
                ),
              ),
            )
          else ...[
            // Mood picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: moods.map((m) => GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JournalScreen())),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Center(child: Text(m,
                      style: const TextStyle(fontSize: 22))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 10),
            Text('How are you feeling today?', style: AppText.label),
          ],
        ],
      ),
    );
  }
}

// ─── CARD 7: GOALS ───────────────────────────────────────
class _GoalsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final goals = context.watch<AppState>().goals;

    return GlassCard(
      accentColor: AppTheme.green,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const GoalsScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: 'Goals', emoji: '🎯',
              badge: 'Q1 2026', badgeColor: AppTheme.green),
          const SizedBox(height: 16),
          ...goals.take(4).map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(g.categoryEmoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(g.title,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${(g.progress * 100).round()}%',
                      style: TextStyle(fontSize: 11, color: g.color, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 5),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: g.progress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => MiniProgressBar(progress: v, color: g.color),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── CARD 8: ANALYTICS ───────────────────────────────────
class _AnalyticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: AppTheme.blue,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: 'Weekly Analytics', emoji: '📊',
              badge: 'Last 7 days', badgeColor: AppTheme.blue),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: BigStat(value: '89%', label: 'Task Rate',
                  color: AppTheme.blue, fontSize: 26)),
              Expanded(child: BigStat(value: '14.2h', label: 'Deep Work',
                  color: AppTheme.purple, fontSize: 26)),
              Expanded(child: BigStat(value: '+12%', label: 'vs Last Week',
                  color: AppTheme.green, fontSize: 26)),
            ],
          ),
          const SizedBox(height: 16),
          // Sparkline bars
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [0.72, 0.88, 0.65, 0.91, 0.78, 0.55, 0.83].map((v) {
              final isToday = [0.72, 0.88, 0.65, 0.91, 0.78, 0.55, 0.83].indexOf(v) == 6;
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: v),
                      duration: Duration(milliseconds: 800 + ([0.72, 0.88, 0.65, 0.91, 0.78, 0.55, 0.83].indexOf(v) * 80)),
                      curve: Curves.easeOutCubic,
                      builder: (_, val, __) => Container(
                        height: 60 * val,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isToday ? AppTheme.blue : AppTheme.blue.withOpacity(0.25),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(['M','T','W','T','F','S','S'][[0.72, 0.88, 0.65, 0.91, 0.78, 0.55, 0.83].indexOf(v)],
                      style: AppText.label.copyWith(fontSize: 9)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
