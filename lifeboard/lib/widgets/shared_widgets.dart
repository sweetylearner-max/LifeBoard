import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── GLASS CARD ──────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? height;
  final bool noPadding;

  const GlassCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.padding,
    this.height,
    this.noPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border, width: 1),
          boxShadow: onTap != null ? [
            BoxShadow(
              color: (accentColor ?? AppTheme.green).withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              if (accentColor != null)
                Positioned(
                  top: 0, left: 0, right: 0, height: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor!, accentColor!.withOpacity(0.3)],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: noPadding
                    ? EdgeInsets.zero
                    : (padding ?? const EdgeInsets.all(20)),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CARD HEADER ─────────────────────────────────────────
class CardHeader extends StatelessWidget {
  final String title;
  final String emoji;
  final String? badge;
  final Color? badgeColor;
  final Widget? trailing;

  const CardHeader({
    super.key,
    required this.title,
    required this.emoji,
    this.badge,
    this.badgeColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppText.cardTitle,
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (badgeColor ?? AppTheme.green).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (badgeColor ?? AppTheme.green).withOpacity(0.25),
              ),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                fontSize: 10,
                color: badgeColor ?? AppTheme.green,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

// ─── BIG STAT ─────────────────────────────────────────────
class BigStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final double fontSize;

  const BigStat({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.fontSize = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (r) => LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ).createShader(r),
          child: Text(
            value,
            style: AppText.statNumber.copyWith(
              fontSize: fontSize,
              color: Colors.white,
              shadows: [Shadow(color: color.withOpacity(0.4), blurRadius: 20)],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppText.label),
      ],
    );
  }
}

// ─── MINI PROGRESS BAR ───────────────────────────────────
class MiniProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const MiniProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: AppTheme.surface3,
        valueColor: AlwaysStoppedAnimation(color),
        minHeight: height,
      ),
    );
  }
}

// ─── CIRCULAR PROGRESS ───────────────────────────────────
class CircularStat extends StatelessWidget {
  final double progress;
  final String label;
  final Color color;
  final double size;

  const CircularStat({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size, height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppTheme.surface3,
              valueColor: AlwaysStoppedAnimation(color),
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECTION TITLE ───────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.heading),
        if (action != null) action!,
      ],
    );
  }
}

// ─── CHIP TAG ────────────────────────────────────────────
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.green;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.15) : AppTheme.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? c.withOpacity(0.4) : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? c : AppTheme.textMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── PRIORITY DOT ────────────────────────────────────────
class PriorityDot extends StatelessWidget {
  final Color color;
  final double size;

  const PriorityDot({super.key, required this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
      ),
    );
  }
}

// ─── ANIMATED COUNTER ────────────────────────────────────
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _oldVal = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.value.toDouble())
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _oldVal = old.value;
      _anim = Tween<double>(begin: _oldVal.toDouble(), end: widget.value.toDouble())
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Text(_anim.value.round().toString(), style: widget.style),
    );
  }
}

// ─── BOTTOM SHEET WRAPPER ────────────────────────────────
class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? accentColor;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.accentColor,
  });

  static Future<T?> show<T>(BuildContext context, {
    required String title,
    required Widget child,
    Color? accentColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheet(
        title: title, child: child, accentColor: accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surface3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                if (accentColor != null)
                  Container(
                    width: 4, height: 22,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Expanded(
                  child: Text(title, style: AppText.heading),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surface2,
                    foregroundColor: AppTheme.textMuted,
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(title, style: AppText.heading, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: AppText.label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
