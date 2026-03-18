import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../services/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

const _uuidJ = Uuid();

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  MoodType _selectedMood = MoodType.okay;
  final _contentCtrl = TextEditingController();
  final _grat1Ctrl = TextEditingController();
  final _grat2Ctrl = TextEditingController();
  final _grat3Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);

    // Load existing today journal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = context.read<AppState>().todayJournal;
      if (today != null) {
        setState(() => _selectedMood = today.mood);
        _contentCtrl.text = today.content;
        if (today.gratitude.isNotEmpty) _grat1Ctrl.text = today.gratitude[0];
        if (today.gratitude.length > 1) _grat2Ctrl.text = today.gratitude[1];
        if (today.gratitude.length > 2) _grat3Ctrl.text = today.gratitude[2];
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _contentCtrl.dispose();
    _grat1Ctrl.dispose();
    _grat2Ctrl.dispose();
    _grat3Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Journal', style: AppText.heading),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.purple,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [Tab(text: 'Write'), Tab(text: 'Entries'), Tab(text: 'Mood Trend')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _buildWrite(context, state),
        _buildEntries(state),
        _buildMoodTrend(state),
      ]),
    );
  }

  Widget _buildWrite(BuildContext context, AppState state) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Date
      Text(DateFormat('EEEE, MMMM d yyyy').format(DateTime.now()).toUpperCase(),
          style: AppText.label),
      const SizedBox(height: 16),

      // Mood selector
      Text('HOW ARE YOU FEELING?', style: AppText.cardTitle),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: MoodType.values.map((mood) {
          final emojis = ['😫', '😞', '😐', '😊', '🤩'];
          final selected = _selectedMood == mood;
          return GestureDetector(
            onTap: () => setState(() => _selectedMood = mood),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58, height: 58,
              decoration: BoxDecoration(
                color: selected ? _moodColor(mood).withOpacity(0.15) : AppTheme.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? _moodColor(mood).withOpacity(0.6) : AppTheme.border,
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected ? [BoxShadow(
                  color: _moodColor(mood).withOpacity(0.3), blurRadius: 12,
                )] : [],
              ),
              child: Center(child: Text(emojis[mood.index],
                  style: const TextStyle(fontSize: 28))),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),

      // Journal entry
      Text("TODAY'S ENTRY", style: AppText.cardTitle),
      const SizedBox(height: 8),
      TextField(
        controller: _contentCtrl,
        style: const TextStyle(color: AppTheme.textPrimary, height: 1.6, fontSize: 14),
        maxLines: 8,
        decoration: InputDecoration(
          hintText: 'What happened today? How do you feel? What are you thinking about?',
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          filled: true, fillColor: AppTheme.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.purple.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),

      const SizedBox(height: 20),

      // Gratitude
      Text('GRATITUDE', style: AppText.cardTitle),
      const SizedBox(height: 8),
      _GratTextField('1. I\'m grateful for...', _grat1Ctrl),
      const SizedBox(height: 8),
      _GratTextField('2. I\'m grateful for...', _grat2Ctrl),
      const SizedBox(height: 8),
      _GratTextField('3. I\'m grateful for...', _grat3Ctrl),

      const SizedBox(height: 24),

      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.purple,
          minimumSize: const Size.fromHeight(52),
        ),
        onPressed: () {
          if (_contentCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Write something first!')));
            return;
          }
          state.saveJournalEntry(JournalEntry(
            id: _uuidJ.v4(),
            date: DateTime.now(),
            mood: _selectedMood,
            content: _contentCtrl.text.trim(),
            gratitude: [_grat1Ctrl.text, _grat2Ctrl.text, _grat3Ctrl.text]
                .where((s) => s.isNotEmpty).toList(),
          ));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('📔 Journal entry saved!')));
          _tab.animateTo(1);
        },
        child: const Text('Save Entry',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
      ),
      const SizedBox(height: 40),
    ]);
  }

  Color _moodColor(MoodType m) {
    switch (m) {
      case MoodType.terrible: return const Color(0xFFFF4444);
      case MoodType.bad: return const Color(0xFFFF6F91);
      case MoodType.okay: return const Color(0xFFFFB347);
      case MoodType.good: return const Color(0xFF4FC3F7);
      case MoodType.amazing: return const Color(0xFF4FFFB0);
    }
  }

  Widget _buildEntries(AppState state) {
    final entries = state.journalEntries;
    if (entries.isEmpty) {
      return const EmptyState(emoji: '📔', title: 'No Entries Yet',
          subtitle: 'Start writing to see your journal here');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        return GlassCard(
          accentColor: e.moodColor,
          onTap: () => _showEntry(context, e),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(e.moodEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(DateFormat('MMMM d, yyyy').format(e.date),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
                Text(e.mood.name.toUpperCase(), style: TextStyle(
                    fontSize: 10, color: e.moodColor, letterSpacing: 0.5)),
              ])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
            ]),
            const SizedBox(height: 8),
            Text(
              e.content.length > 120 ? '${e.content.substring(0, 120)}...' : e.content,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
            if (e.gratitude.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Text('🙏 ', style: TextStyle(fontSize: 12)),
                Expanded(child: Text(e.gratitude.first,
                    style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ],
          ]),
        );
      },
    );
  }

  void _showEntry(BuildContext context, JournalEntry e) {
    AppBottomSheet.show(context,
      title: '${e.moodEmoji} ${DateFormat("MMMM d").format(e.date)}',
      accentColor: e.moodColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e.content, style: const TextStyle(
            fontSize: 14, color: AppTheme.textPrimary, height: 1.7)),
        if (e.gratitude.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('GRATITUDE', style: AppText.cardTitle),
          const SizedBox(height: 8),
          ...e.gratitude.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Text('🙏 '),
              Expanded(child: Text(g, style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary))),
            ]),
          )),
        ],
      ]),
    );
  }

  Widget _buildMoodTrend(AppState state) {
    final entries = state.journalEntries.take(14).toList().reversed.toList();
    if (entries.isEmpty) {
      return const EmptyState(emoji: '📊', title: 'No Data Yet',
          subtitle: 'Write journal entries to see your mood trend');
    }

    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('MOOD TREND — LAST 14 DAYS', style: AppText.cardTitle),
      const SizedBox(height: 20),
      SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: entries.map((e) {
            final h = ((e.mood.index + 1) / 5) * 140;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(e.moodEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: h),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => Container(
                        height: v,
                        decoration: BoxDecoration(
                          color: e.moodColor.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          border: Border.all(color: e.moodColor.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 16),
      // Average mood
      GlassCard(
        accentColor: AppTheme.purple,
        child: Row(children: [
          const Text('📊', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Average Mood', style: AppText.label),
            Text(
              _avgMoodLabel(entries),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
          ]),
        ]),
      ),
    ]);
  }

  String _avgMoodLabel(List<JournalEntry> entries) {
    if (entries.isEmpty) return 'No data';
    final avg = entries.map((e) => e.mood.index).reduce((a, b) => a + b) / entries.length;
    final labels = ['Terrible', 'Bad', 'Okay', 'Good', 'Amazing'];
    return labels[avg.round().clamp(0, 4)];
  }
}

class _GratTextField extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  const _GratTextField(this.hint, this.ctrl);

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
