// HEALTH SCREEN
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

const _uuidH = Uuid();

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
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
    final today = state.todayHealth;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Health & Fitness', style: AppText.heading),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.pink,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [Tab(text: 'Today'), Tab(text: 'History'), Tab(text: 'Log')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _buildToday(context, today),
        _buildHistory(state),
        _buildLog(context, state),
      ]),
    );
  }

  Widget _buildToday(BuildContext context, HealthLog? h) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Health score ring
      GlassCard(
        accentColor: AppTheme.pink,
        child: Row(children: [
          SizedBox(width: 90, height: 90, child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (h?.healthScore ?? 0) / 100),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => CircularProgressIndicator(
                  value: v, strokeWidth: 7,
                  backgroundColor: AppTheme.surface3,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.pink),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${h?.healthScore.round() ?? 0}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppTheme.pink)),
                Text('pts', style: AppText.label),
              ]),
            ],
          )),
          const SizedBox(width: 20),
          Expanded(child: Column(children: [
            _MetricTile('👟', 'Steps', '${h?.steps ?? 0}', 10000, AppTheme.green),
            _MetricTile('💧', 'Water', '${h?.waterLiters ?? 0}L', null, AppTheme.blue),
            _MetricTile('🔥', 'Calories', '${h?.caloriesConsumed ?? 0}', 2000, AppTheme.orange),
            _MetricTile('😴', 'Sleep', '${h?.sleepHours ?? 0}h', 8, AppTheme.purple),
          ])),
        ]),
      ),
      const SizedBox(height: 16),

      // Quick log buttons
      Row(children: [
        _QuickBtn('💧 +250ml', AppTheme.blue, () {}),
        const SizedBox(width: 8),
        _QuickBtn('👟 +1000', AppTheme.green, () {}),
        const SizedBox(width: 8),
        _QuickBtn('🍎 Log Meal', AppTheme.orange, () => _tab.animateTo(2)),
      ]),

      const SizedBox(height: 16),

      if (h?.workout != null && h!.workout!.isNotEmpty)
        GlassCard(
          accentColor: AppTheme.pink,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TODAY\'S WORKOUT', style: AppText.cardTitle),
            const SizedBox(height: 8),
            Text(h.workout!, style: const TextStyle(
                fontSize: 14, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('🔥 ${h.caloriesBurned} kcal burned', style: TextStyle(
                fontSize: 12, color: AppTheme.orange)),
          ]),
        ),
    ]);
  }

  Widget _buildHistory(AppState state) {
    final logs = state.healthLogs;
    if (logs.isEmpty) {
      return const EmptyState(emoji: '📊', title: 'No History',
          subtitle: 'Start logging your health data');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: logs.length,
      itemBuilder: (_, i) {
        final log = logs[i];
        return GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_formatDate(log.date), style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${log.healthScore.round()} pts',
                  style: const TextStyle(fontSize: 11, color: AppTheme.pink,
                      fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 12, children: [
              Text('👟 ${log.steps}', style: AppText.label),
              Text('💧 ${log.waterLiters}L', style: AppText.label),
              Text('😴 ${log.sleepHours}h', style: AppText.label),
              Text('🔥 ${log.caloriesBurned}kcal', style: AppText.label),
            ]),
          ]),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }

  Widget _buildLog(BuildContext context, AppState state) {
    final stepsCtrl = TextEditingController(text: '${state.todayHealth?.steps ?? 0}');
    final waterCtrl = TextEditingController(text: '${state.todayHealth?.waterLiters ?? 0}');
    final calInCtrl = TextEditingController(text: '${state.todayHealth?.caloriesConsumed ?? 0}');
    final calOutCtrl = TextEditingController(text: '${state.todayHealth?.caloriesBurned ?? 0}');
    final sleepCtrl = TextEditingController(text: '${state.todayHealth?.sleepHours ?? 7}');
    final hrCtrl = TextEditingController(text: '${state.todayHealth?.heartRate ?? 72}');
    final workoutCtrl = TextEditingController(text: state.todayHealth?.workout ?? '');

    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('LOG TODAY\'S HEALTH', style: AppText.cardTitle),
      const SizedBox(height: 16),
      _NumField('👟 Steps', stepsCtrl, AppTheme.green),
      _NumField('💧 Water (L)', waterCtrl, AppTheme.blue),
      _NumField('🍎 Calories In', calInCtrl, AppTheme.orange),
      _NumField('🔥 Calories Burned', calOutCtrl, AppTheme.pink),
      _NumField('😴 Sleep Hours', sleepCtrl, AppTheme.purple),
      _NumField('❤️ Heart Rate (bpm)', hrCtrl, AppTheme.pink),
      const SizedBox(height: 4),
      TextField(
        controller: workoutCtrl,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: const InputDecoration(labelText: '🏋️ Workout Details'),
        maxLines: 2,
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.pink,
          minimumSize: const Size.fromHeight(52),
        ),
        onPressed: () {
          state.saveHealthLog(HealthLog(
            id: _uuidH.v4(), date: DateTime.now(),
            steps: int.tryParse(stepsCtrl.text) ?? 0,
            waterLiters: double.tryParse(waterCtrl.text) ?? 0,
            caloriesConsumed: int.tryParse(calInCtrl.text) ?? 0,
            caloriesBurned: int.tryParse(calOutCtrl.text) ?? 0,
            sleepHours: double.tryParse(sleepCtrl.text) ?? 0,
            heartRate: int.tryParse(hrCtrl.text) ?? 0,
            workout: workoutCtrl.text.isEmpty ? null : workoutCtrl.text,
          ));
          _tab.animateTo(0);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Health data saved!')));
        },
        child: const Text('Save Health Log',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 15)),
      ),
    ]);
  }
}

class _MetricTile extends StatelessWidget {
  final String emoji, label, value;
  final num? target;
  final Color color;
  const _MetricTile(this.emoji, this.label, this.value, this.target, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 6),
      Expanded(child: Text(label, style: AppText.label)),
      Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickBtn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ),
    ),
  );
}

class _NumField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final Color color;
  const _NumField(this.label, this.ctrl, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted),
      ),
    ),
  );
}
