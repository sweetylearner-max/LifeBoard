import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

enum PomoState { idle, running, paused, breakTime }
enum PomoMode { work, shortBreak, longBreak, custom }

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  PomoState _state = PomoState.idle;
  PomoMode _mode = PomoMode.work;
  int _seconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  int _completedSessions = 0;
  int _currentSession = 1;
  Timer? _timer;
  String _currentTask = '';

  late AnimationController _ringCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _sessions = [];
  final _taskCtrl = TextEditingController();

  final Map<PomoMode, int> _modeDurations = {
    PomoMode.work: 25,
    PomoMode.shortBreak: 5,
    PomoMode.longBreak: 15,
    PomoMode.custom: 30,
  };

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    _taskCtrl.dispose();
    super.dispose();
  }

  void _setMode(PomoMode mode) {
    _timer?.cancel();
    setState(() {
      _mode = mode;
      _state = PomoState.idle;
      final mins = _modeDurations[mode]!;
      _seconds = mins * 60;
      _totalSeconds = mins * 60;
    });
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_state == PomoState.running) {
      _timer?.cancel();
      setState(() => _state = PomoState.paused);
    } else {
      setState(() => _state = PomoState.running);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_seconds <= 0) {
          _onComplete();
        } else {
          setState(() => _seconds--);
        }
      });
    }
  }

  void _onComplete() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      if (_mode == PomoMode.work) {
        _completedSessions++;
        _sessions.insert(0, {
          'task': _currentTask.isEmpty ? 'Focus Session' : _currentTask,
          'duration': _modeDurations[PomoMode.work],
          'time': TimeOfDay.now().format(context),
        });
      }
      _state = PomoState.idle;
      _seconds = _totalSeconds;
    });
    _showCompleteDialog();
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _state = PomoState.idle;
      _seconds = _totalSeconds;
    });
  }

  void _showCompleteDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(_mode == PomoMode.work ? 'Session Complete!' : 'Break Over!',
            style: AppText.heading),
          const SizedBox(height: 8),
          Text(
            _mode == PomoMode.work
                ? 'Great focus! Time for a ${_completedSessions % 4 == 0 ? "long" : "short"} break.'
                : 'Ready to focus again?',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_mode == PomoMode.work) {
                _setMode(_completedSessions % 4 == 0
                    ? PomoMode.longBreak : PomoMode.shortBreak);
              } else {
                _setMode(PomoMode.work);
              }
            },
            child: Text(_mode == PomoMode.work ? '☕ Start Break' : '🚀 Start Focus'),
          ),
        ],
      ),
    ));
  }

  String get _timeString {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress => _totalSeconds > 0 ? 1 - (_seconds / _totalSeconds) : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Focus Timer', style: AppText.heading),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ─── MODE TABS ──────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  _ModeTab('Work', PomoMode.work, _mode, _setMode),
                  _ModeTab('Short Break', PomoMode.shortBreak, _mode, _setMode),
                  _ModeTab('Long Break', PomoMode.longBreak, _mode, _setMode),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ─── TIMER RING ─────────────────────────
            ScaleTransition(
              scale: _state == PomoState.running ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
              child: SizedBox(
                width: 240, height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow
                    Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: _state == PomoState.running ? [
                          BoxShadow(
                            color: AppTheme.green.withOpacity(0.2),
                            blurRadius: 40, spreadRadius: 10,
                          ),
                        ] : [],
                      ),
                    ),
                    // Ring
                    SizedBox(
                      width: 220, height: 220,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _progress),
                        duration: const Duration(milliseconds: 100),
                        builder: (_, v, __) => CircularProgressIndicator(
                          value: v,
                          backgroundColor: AppTheme.surface3,
                          valueColor: AlwaysStoppedAnimation(
                            _mode == PomoMode.work ? AppTheme.green
                                : _mode == PomoMode.shortBreak ? AppTheme.blue
                                : AppTheme.purple,
                          ),
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    // Time
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_timeString,
                          style: AppText.statNumber.copyWith(
                            fontSize: 56,
                            color: _mode == PomoMode.work ? AppTheme.green
                                : _mode == PomoMode.shortBreak ? AppTheme.blue
                                : AppTheme.purple,
                          ),
                        ),
                        Text(
                          _state == PomoState.idle ? 'Ready'
                              : _state == PomoState.running ? 'Focusing...'
                              : _state == PomoState.paused ? 'Paused'
                              : 'Break',
                          style: AppText.label,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── SESSION DOTS ───────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                width: 12, height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: i < _completedSessions % 4
                      ? AppTheme.green : AppTheme.surface3,
                  shape: BoxShape.circle,
                  boxShadow: i < _completedSessions % 4 ? [
                    BoxShadow(color: AppTheme.green.withOpacity(0.5), blurRadius: 8),
                  ] : [],
                ),
              )),
            ),

            const SizedBox(height: 8),
            Text('Session ${(_completedSessions % 4) + 1} of 4',
              style: AppText.label),

            const SizedBox(height: 32),

            // ─── CONTROLS ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset
                _CircleButton(
                  icon: Icons.refresh_rounded,
                  onTap: _resetTimer,
                  size: 52,
                ),
                const SizedBox(width: 20),
                // Play/Pause
                GestureDetector(
                  onTap: _toggleTimer,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _mode == PomoMode.work
                            ? [AppTheme.green, AppTheme.green.withOpacity(0.7)]
                            : [AppTheme.blue, AppTheme.blue.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: (_mode == PomoMode.work ? AppTheme.green : AppTheme.blue)
                            .withOpacity(0.4),
                        blurRadius: 20,
                      )],
                    ),
                    child: Icon(
                      _state == PomoState.running
                          ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 36, color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Skip
                _CircleButton(
                  icon: Icons.skip_next_rounded,
                  onTap: _onComplete,
                  size: 52,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ─── CURRENT TASK ───────────────────────
            GlassCard(
              accentColor: AppTheme.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WORKING ON', style: AppText.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _taskCtrl,
                    onChanged: (v) => _currentTask = v,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'What are you focusing on?',
                      hintStyle: TextStyle(color: AppTheme.textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── STATS ROW ──────────────────────────
            Row(
              children: [
                Expanded(child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today', style: AppText.label),
                      const SizedBox(height: 4),
                      Text('$_completedSessions',
                        style: AppText.statNumber.copyWith(
                          fontSize: 32, color: AppTheme.green)),
                      Text('sessions', style: AppText.label),
                    ],
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus Time', style: AppText.label),
                      const SizedBox(height: 4),
                      Text('${_completedSessions * 25}m',
                        style: AppText.statNumber.copyWith(
                          fontSize: 32, color: AppTheme.purple)),
                      Text('total', style: AppText.label),
                    ],
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Streak', style: AppText.label),
                      const SizedBox(height: 4),
                      Text('21🔥', style: AppText.statNumber.copyWith(
                          fontSize: 28, color: AppTheme.orange)),
                      Text('days', style: AppText.label),
                    ],
                  ),
                )),
              ],
            ),

            const SizedBox(height: 16),

            // ─── SESSION HISTORY ────────────────────
            if (_sessions.isNotEmpty) ...[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TODAY'S SESSIONS", style: AppText.cardTitle),
                    const SizedBox(height: 12),
                    ..._sessions.take(5).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('✓',
                              style: TextStyle(
                                fontSize: 11, color: AppTheme.green)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(s['task'],
                            style: const TextStyle(fontSize: 13,
                                color: AppTheme.textPrimary))),
                          Text('${s['duration']}m · ${s['time']}',
                            style: AppText.label),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final PomoMode mode;
  final PomoMode current;
  final Function(PomoMode) onSelect;

  const _ModeTab(this.label, this.mode, this.current, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final selected = mode == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.surface3 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: selected ? AppTheme.textPrimary : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CircleButton({required this.icon, required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: AppTheme.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: size * 0.4, color: AppTheme.textMuted),
      ),
    );
  }
}
