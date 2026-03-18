import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Analytics', style: AppText.heading),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [

        // ─── Life Score ───────────────────────────
        GlassCard(
          accentColor: AppTheme.green,
          child: Row(children: [
            SizedBox(width: 90, height: 90, child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: state.lifeScore / 100),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => CircularProgressIndicator(
                    value: v, strokeWidth: 7,
                    backgroundColor: AppTheme.surface3,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.green),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${state.lifeScore}', style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.green)),
                  Text('pts', style: AppText.label),
                ]),
              ],
            )),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LIFE SCORE', style: AppText.cardTitle),
              const SizedBox(height: 6),
              Text(
                _getScoreLabel(state.lifeScore),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text('Level ${state.profile.level} · ${state.profile.levelTitle}',
                  style: AppText.label),
            ])),
          ]),
        ),

        const SizedBox(height: 16),

        // ─── Weekly stats ─────────────────────────
        Text('WEEKLY OVERVIEW', style: AppText.cardTitle),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _StatCard('89%', 'Task Rate', AppTheme.blue, '⬆ +5%')),
          const SizedBox(width: 8),
          Expanded(child: _StatCard('14.2h', 'Focus', AppTheme.purple, '⬆ +2.1h')),
          const SizedBox(width: 8),
          Expanded(child: _StatCard('21🔥', 'Streak', AppTheme.orange, 'Best Ever')),
        ]),

        const SizedBox(height: 16),

        // ─── Weekly chart ─────────────────────────
        GlassCard(
          accentColor: AppTheme.blue,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PRODUCTIVITY CHART', style: AppText.cardTitle),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _buildWeekBars(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => Text(d, style: AppText.label.copyWith(fontSize: 10)))
                  .toList(),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // ─── Daily breakdown table ────────────────
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DAILY BREAKDOWN', style: AppText.cardTitle),
            const SizedBox(height: 14),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(0.8),
                4: FlexColumnWidth(0.8),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.border))),
                  children: ['Day', 'Tasks', 'Focus', 'Mood', 'Score']
                      .map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(h.toUpperCase(),
                          style: AppText.label.copyWith(fontSize: 9)),
                      )).toList(),
                ),
                ...[
                  ['Mon', '6/7', '3.5h', '😊', '85'],
                  ['Tue', '7/7', '4.2h', '🤩', '96'],
                  ['Wed', '5/7', '2.8h', '😐', '72'],
                  ['Thu', '7/8', '4.0h', '😊', '88'],
                  ['Fri', '8/8', '5.1h', '🤩', '99'],
                  ['Sat', '3/4', '1.5h', '😊', '76'],
                  ['Sun', '2/3', '1.0h', '😞', '60'],
                ].map((row) => TableRow(
                  children: row.asMap().map((i, v) => MapEntry(i,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(v, style: TextStyle(
                        fontSize: 12,
                        color: i == 4
                            ? _scoreColor(int.parse(v))
                            : AppTheme.textPrimary,
                        fontWeight: i == 4 ? FontWeight.w700 : FontWeight.w400,
                      )),
                    ),
                  )).values.toList(),
                )),
              ],
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // ─── Habits analytics ─────────────────────
        GlassCard(
          accentColor: AppTheme.purple,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HABIT COMPLETION RATES', style: AppText.cardTitle),
            const SizedBox(height: 14),
            ...state.habits.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(h.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(h.name, style: const TextStyle(
                      fontSize: 12, color: AppTheme.textPrimary))),
                  Text('${(h.completionRate * 100).round()}%',
                    style: TextStyle(fontSize: 11, color: h.color, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 5),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: h.completionRate),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => MiniProgressBar(progress: v, color: h.color),
                ),
              ]),
            )),
          ]),
        ),

        const SizedBox(height: 16),

        // ─── Finance snapshot ─────────────────────
        GlassCard(
          accentColor: AppTheme.orange,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('FINANCE SNAPSHOT', style: AppText.cardTitle),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _FinanceMini(
                  'Income', 'var(--green)', '₹55,000', AppTheme.green)),
              Expanded(child: _FinanceMini(
                  'Expense', '', '₹18,200', AppTheme.pink)),
              Expanded(child: _FinanceMini(
                  'Saved', '', '₹12,000', AppTheme.blue)),
            ]),
          ]),
        ),

        const SizedBox(height: 80),
      ]),
    );
  }

  List<Widget> _buildWeekBars() {
    final data = [
      ('Mon', 0.72, false),
      ('Tue', 0.88, false),
      ('Wed', 0.65, false),
      ('Thu', 0.91, false),
      ('Fri', 0.78, false),
      ('Sat', 0.55, false),
      ('Sun', 0.83, true),
    ];

    return data.map((d) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: d.$2),
          duration: Duration(milliseconds: 600 + data.indexOf(d) * 80),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => Container(
            height: 120 * v,
            decoration: BoxDecoration(
              color: d.$3
                  ? AppTheme.blue : AppTheme.blue.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              boxShadow: d.$3 ? [BoxShadow(
                color: AppTheme.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, -2),
              )] : [],
            ),
          ),
        ),
      ),
    )).toList();
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return '🏆 Outstanding';
    if (score >= 75) return '🚀 Excellent';
    if (score >= 60) return '✅ Good';
    if (score >= 45) return '📈 Improving';
    return '💪 Keep Going';
  }

  Color _scoreColor(int score) {
    if (score >= 90) return AppTheme.green;
    if (score >= 75) return AppTheme.blue;
    if (score >= 60) return AppTheme.orange;
    return AppTheme.pink;
  }
}

class _StatCard extends StatelessWidget {
  final String value, label, color, delta;
  const _StatCard(this.value, this.label, this.color, this.delta);

  @override
  Widget build(BuildContext context) {
    final c = const {
      'blue': AppTheme.blue, 'purple': AppTheme.purple, 'orange': AppTheme.orange,
    }[color] ?? AppTheme.blue;
    return GlassCard(
      accentColor: c,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c)),
        Text(label, style: AppText.label),
        const SizedBox(height: 4),
        Text(delta, style: TextStyle(fontSize: 10, color: AppTheme.green)),
      ]),
    );
  }
}

class _FinanceMini extends StatelessWidget {
  final String label, _, value;
  final Color color;
  const _FinanceMini(this.label, this._, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.label),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
    ],
  );
}
