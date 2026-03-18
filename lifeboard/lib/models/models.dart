import 'package:flutter/material.dart';

// ─── TASK MODEL ───────────────────────────────────────────
enum TaskPriority { high, medium, low }

class TaskModel {
  String id;
  String title;
  String? description;
  TaskPriority priority;
  bool isDone;
  DateTime createdAt;
  DateTime? dueDate;
  String? category;
  bool isRecurring;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.category,
    this.isRecurring = false,
  });

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high: return const Color(0xFFFF6F91);
      case TaskPriority.medium: return const Color(0xFFFFB347);
      case TaskPriority.low: return const Color(0xFF7C6FFF);
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'description': description,
    'priority': priority.index, 'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'category': category, 'isRecurring': isRecurring,
  };

  factory TaskModel.fromMap(Map<String, dynamic> m) => TaskModel(
    id: m['id'], title: m['title'], description: m['description'],
    priority: TaskPriority.values[m['priority'] ?? 1],
    isDone: m['isDone'] ?? false,
    createdAt: DateTime.parse(m['createdAt']),
    dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
    category: m['category'], isRecurring: m['isRecurring'] ?? false,
  );
}

// ─── HABIT MODEL ──────────────────────────────────────────
class HabitModel {
  String id;
  String name;
  String emoji;
  Color color;
  List<DateTime> completedDates;
  String frequency; // daily, weekly
  String? targetTime;
  int targetCount;

  HabitModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    List<DateTime>? completedDates,
    this.frequency = 'daily',
    this.targetTime,
    this.targetCount = 1,
  }) : completedDates = completedDates ?? [];

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = [...completedDates]..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime check = DateTime.now();
    for (final d in sorted) {
      final diff = check.difference(d).inDays;
      if (diff <= 1) { streak++; check = d; } else break;
    }
    return streak;
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
  }

  double get completionRate {
    if (completedDates.isEmpty) return 0.0;
    final last30 = DateTime.now().subtract(const Duration(days: 30));
    final recent = completedDates.where((d) => d.isAfter(last30)).length;
    return recent / 30;
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'emoji': emoji,
    'color': color.value,
    'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
    'frequency': frequency, 'targetTime': targetTime,
    'targetCount': targetCount,
  };

  factory HabitModel.fromMap(Map<String, dynamic> m) => HabitModel(
    id: m['id'], name: m['name'], emoji: m['emoji'],
    color: Color(m['color']),
    completedDates: (m['completedDates'] as List<dynamic>? ?? [])
        .map((d) => DateTime.parse(d.toString())).toList(),
    frequency: m['frequency'] ?? 'daily',
    targetTime: m['targetTime'],
    targetCount: m['targetCount'] ?? 1,
  );
}

// ─── FINANCE MODEL ────────────────────────────────────────
enum TransactionType { income, expense, investment, savings }

class Transaction {
  String id;
  String description;
  double amount;
  TransactionType type;
  String category;
  DateTime date;
  String? note;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  Color get typeColor {
    switch (type) {
      case TransactionType.income: return const Color(0xFF4FFFB0);
      case TransactionType.expense: return const Color(0xFFFF6F91);
      case TransactionType.investment: return const Color(0xFF7C6FFF);
      case TransactionType.savings: return const Color(0xFFFFB347);
    }
  }

  String get typeSign => type == TransactionType.income ? '+' : '-';

  Map<String, dynamic> toMap() => {
    'id': id, 'description': description, 'amount': amount,
    'type': type.index, 'category': category,
    'date': date.toIso8601String(), 'note': note,
  };

  factory Transaction.fromMap(Map<String, dynamic> m) => Transaction(
    id: m['id'], description: m['description'],
    amount: (m['amount'] as num).toDouble(),
    type: TransactionType.values[m['type']],
    category: m['category'],
    date: DateTime.parse(m['date']),
    note: m['note'],
  );
}

// ─── HEALTH MODEL ─────────────────────────────────────────
class HealthLog {
  String id;
  DateTime date;
  int steps;
  double waterLiters;
  int caloriesConsumed;
  int caloriesBurned;
  double sleepHours;
  int heartRate;
  String? workout;
  String? notes;

  HealthLog({
    required this.id,
    required this.date,
    this.steps = 0,
    this.waterLiters = 0.0,
    this.caloriesConsumed = 0,
    this.caloriesBurned = 0,
    this.sleepHours = 0.0,
    this.heartRate = 0,
    this.workout,
    this.notes,
  });

  double get healthScore {
    double score = 0;
    if (steps >= 10000) score += 25; else score += (steps / 10000) * 25;
    if (waterLiters >= 2.5) score += 20; else score += (waterLiters / 2.5) * 20;
    if (sleepHours >= 7 && sleepHours <= 9) score += 25; else score += 15;
    if (caloriesBurned >= 300) score += 15; else score += (caloriesBurned / 300) * 15;
    if (workout != null && workout!.isNotEmpty) score += 15;
    return score.clamp(0, 100);
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'date': date.toIso8601String(),
    'steps': steps, 'waterLiters': waterLiters,
    'caloriesConsumed': caloriesConsumed, 'caloriesBurned': caloriesBurned,
    'sleepHours': sleepHours, 'heartRate': heartRate,
    'workout': workout, 'notes': notes,
  };

  factory HealthLog.fromMap(Map<String, dynamic> m) => HealthLog(
    id: m['id'], date: DateTime.parse(m['date']),
    steps: m['steps'] ?? 0, waterLiters: (m['waterLiters'] as num?)?.toDouble() ?? 0,
    caloriesConsumed: m['caloriesConsumed'] ?? 0,
    caloriesBurned: m['caloriesBurned'] ?? 0,
    sleepHours: (m['sleepHours'] as num?)?.toDouble() ?? 0,
    heartRate: m['heartRate'] ?? 0,
    workout: m['workout'], notes: m['notes'],
  );
}

// ─── JOURNAL MODEL ────────────────────────────────────────
enum MoodType { terrible, bad, okay, good, amazing }

class JournalEntry {
  String id;
  DateTime date;
  MoodType mood;
  String content;
  List<String> gratitude;
  List<String> tags;
  String? aiInsight;

  JournalEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.content,
    List<String>? gratitude,
    List<String>? tags,
    this.aiInsight,
  })  : gratitude = gratitude ?? [],
        tags = tags ?? [];

  String get moodEmoji {
    switch (mood) {
      case MoodType.terrible: return '😫';
      case MoodType.bad: return '😞';
      case MoodType.okay: return '😐';
      case MoodType.good: return '😊';
      case MoodType.amazing: return '🤩';
    }
  }

  Color get moodColor {
    switch (mood) {
      case MoodType.terrible: return const Color(0xFFFF4444);
      case MoodType.bad: return const Color(0xFFFF6F91);
      case MoodType.okay: return const Color(0xFFFFB347);
      case MoodType.good: return const Color(0xFF4FC3F7);
      case MoodType.amazing: return const Color(0xFF4FFFB0);
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'date': date.toIso8601String(),
    'mood': mood.index, 'content': content,
    'gratitude': gratitude, 'tags': tags, 'aiInsight': aiInsight,
  };

  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry(
    id: m['id'], date: DateTime.parse(m['date']),
    mood: MoodType.values[m['mood'] ?? 2],
    content: m['content'] ?? '',
    gratitude: List<String>.from(m['gratitude'] ?? []),
    tags: List<String>.from(m['tags'] ?? []),
    aiInsight: m['aiInsight'],
  );
}

// ─── GOAL MODEL ───────────────────────────────────────────
enum GoalCategory { personal, career, health, finance, education, creative }

class GoalModel {
  String id;
  String title;
  String? description;
  GoalCategory category;
  double progress; // 0.0 to 1.0
  DateTime createdAt;
  DateTime? targetDate;
  bool isCompleted;
  List<String> milestones;
  List<String> completedMilestones;
  Color color;

  GoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.progress = 0.0,
    required this.createdAt,
    this.targetDate,
    this.isCompleted = false,
    List<String>? milestones,
    List<String>? completedMilestones,
    required this.color,
  })  : milestones = milestones ?? [],
        completedMilestones = completedMilestones ?? [];

  int? get daysLeft => targetDate?.difference(DateTime.now()).inDays;

  String get categoryEmoji {
    switch (category) {
      case GoalCategory.personal: return '⭐';
      case GoalCategory.career: return '💼';
      case GoalCategory.health: return '❤️';
      case GoalCategory.finance: return '₹';
      case GoalCategory.education: return '📚';
      case GoalCategory.creative: return '🎨';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'description': description,
    'category': category.index, 'progress': progress,
    'createdAt': createdAt.toIso8601String(),
    'targetDate': targetDate?.toIso8601String(),
    'isCompleted': isCompleted, 'milestones': milestones,
    'completedMilestones': completedMilestones, 'color': color.value,
  };

  factory GoalModel.fromMap(Map<String, dynamic> m) => GoalModel(
    id: m['id'], title: m['title'], description: m['description'],
    category: GoalCategory.values[m['category'] ?? 0],
    progress: (m['progress'] as num?)?.toDouble() ?? 0.0,
    createdAt: DateTime.parse(m['createdAt']),
    targetDate: m['targetDate'] != null ? DateTime.parse(m['targetDate']) : null,
    isCompleted: m['isCompleted'] ?? false,
    milestones: List<String>.from(m['milestones'] ?? []),
    completedMilestones: List<String>.from(m['completedMilestones'] ?? []),
    color: Color(m['color'] ?? 0xFF4FFFB0),
  );
}

// ─── POMODORO SESSION ─────────────────────────────────────
class PomodoroSession {
  String id;
  String? taskName;
  DateTime startTime;
  DateTime? endTime;
  int durationMinutes;
  bool isCompleted;

  PomodoroSession({
    required this.id,
    this.taskName,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.isCompleted = false,
  });
}

// ─── USER PROFILE ─────────────────────────────────────────
class UserProfile {
  String name;
  String? avatarPath;
  int level;
  int xp;
  int totalXpForLevel;
  List<String> achievements;
  DateTime joinDate;

  UserProfile({
    required this.name,
    this.avatarPath,
    this.level = 1,
    this.xp = 0,
    this.totalXpForLevel = 1000,
    List<String>? achievements,
    required this.joinDate,
  }) : achievements = achievements ?? [];

  double get xpProgress => xp / totalXpForLevel;

  String get levelTitle {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Explorer';
    if (level < 15) return 'Achiever';
    if (level < 20) return 'Master';
    return 'Legend';
  }
}
