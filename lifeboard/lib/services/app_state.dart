import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _uuid = Uuid();

class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _initialized = false;

  // User
  UserProfile _profile = UserProfile(name: 'Champion', joinDate: DateTime.now());

  // Data
  List<TaskModel> _tasks = [];
  List<HabitModel> _habits = [];
  List<Transaction> _transactions = [];
  List<HealthLog> _healthLogs = [];
  List<JournalEntry> _journalEntries = [];
  List<GoalModel> _goals = [];
  List<PomodoroSession> _pomodoroSessions = [];

  // Getters
  UserProfile get profile => _profile;
  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get todayTasks => _tasks.where((t) {
    final now = DateTime.now();
    if (t.dueDate != null) {
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }
    return t.createdAt.year == now.year &&
        t.createdAt.month == now.month &&
        t.createdAt.day == now.day;
  }).toList();

  List<HabitModel> get habits => _habits;
  List<Transaction> get transactions => _transactions;
  List<HealthLog> get healthLogs => _healthLogs;
  HealthLog? get todayHealth {
    final now = DateTime.now();
    try {
      return _healthLogs.firstWhere((h) =>
          h.date.year == now.year && h.date.month == now.month && h.date.day == now.day);
    } catch (_) { return null; }
  }

  List<JournalEntry> get journalEntries => _journalEntries;
  JournalEntry? get todayJournal {
    final now = DateTime.now();
    try {
      return _journalEntries.firstWhere((j) =>
          j.date.year == now.year && j.date.month == now.month && j.date.day == now.day);
    } catch (_) { return null; }
  }

  List<GoalModel> get goals => _goals;
  List<PomodoroSession> get pomodoroSessions => _pomodoroSessions;

  // Finance computed
  double get totalBalance {
    double bal = 0;
    for (final t in _transactions) {
      if (t.type == TransactionType.income) bal += t.amount;
      if (t.type == TransactionType.expense) bal -= t.amount;
      if (t.type == TransactionType.investment) bal -= t.amount;
      if (t.type == TransactionType.savings) bal -= t.amount;
    }
    return bal;
  }

  double get monthlySpending {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.expense &&
            t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlySavings {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.savings &&
            t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Life score
  int get lifeScore {
    int score = 50;
    final td = todayTasks;
    if (td.isNotEmpty) {
      final done = td.where((t) => t.isDone).length;
      score += ((done / td.length) * 20).round();
    }
    if (todayHealth != null) score += (todayHealth!.healthScore * 0.15).round();
    final activeHabits = _habits.where((h) => h.isCompletedToday()).length;
    if (_habits.isNotEmpty) score += ((activeHabits / _habits.length) * 15).round();
    return score.clamp(0, 100);
  }

  // Init
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadAll();
    _seedDemoData();
    _initialized = true;
    notifyListeners();
  }

  void _loadAll() {
    // Load tasks
    final taskJson = _prefs.getString('tasks');
    if (taskJson != null) {
      final list = jsonDecode(taskJson) as List;
      _tasks = list.map((m) => TaskModel.fromMap(m)).toList();
    }
    // Load habits
    final habitJson = _prefs.getString('habits');
    if (habitJson != null) {
      final list = jsonDecode(habitJson) as List;
      _habits = list.map((m) => HabitModel.fromMap(m)).toList();
    }
    // Load transactions
    final txnJson = _prefs.getString('transactions');
    if (txnJson != null) {
      final list = jsonDecode(txnJson) as List;
      _transactions = list.map((m) => Transaction.fromMap(m)).toList();
    }
    // Load health
    final healthJson = _prefs.getString('health');
    if (healthJson != null) {
      final list = jsonDecode(healthJson) as List;
      _healthLogs = list.map((m) => HealthLog.fromMap(m)).toList();
    }
    // Load journal
    final journalJson = _prefs.getString('journal');
    if (journalJson != null) {
      final list = jsonDecode(journalJson) as List;
      _journalEntries = list.map((m) => JournalEntry.fromMap(m)).toList();
    }
    // Load goals
    final goalsJson = _prefs.getString('goals');
    if (goalsJson != null) {
      final list = jsonDecode(goalsJson) as List;
      _goals = list.map((m) => GoalModel.fromMap(m)).toList();
    }
    // Load profile
    final profileName = _prefs.getString('profile_name');
    if (profileName != null) _profile.name = profileName;
    _profile.level = _prefs.getInt('profile_level') ?? 12;
    _profile.xp = _prefs.getInt('profile_xp') ?? 3420;
  }

  void _seedDemoData() {
    if (_tasks.isEmpty) {
      _tasks = [
        TaskModel(id: _uuid.v4(), title: 'Morning workout — 30 min', priority: TaskPriority.high,
            isDone: true, createdAt: DateTime.now(), category: 'Health'),
        TaskModel(id: _uuid.v4(), title: 'Review project proposal', priority: TaskPriority.high,
            isDone: true, createdAt: DateTime.now(), category: 'Work'),
        TaskModel(id: _uuid.v4(), title: 'Submit hackathon registration', priority: TaskPriority.high,
            isDone: false, createdAt: DateTime.now(), category: 'Career'),
        TaskModel(id: _uuid.v4(), title: 'Read 20 pages — Deep Work', priority: TaskPriority.medium,
            isDone: false, createdAt: DateTime.now(), category: 'Learning'),
        TaskModel(id: _uuid.v4(), title: 'Meditate 10 minutes', priority: TaskPriority.low,
            isDone: false, createdAt: DateTime.now(), category: 'Health'),
        TaskModel(id: _uuid.v4(), title: 'Call family', priority: TaskPriority.medium,
            isDone: false, createdAt: DateTime.now(), category: 'Personal'),
        TaskModel(id: _uuid.v4(), title: 'Code review session', priority: TaskPriority.high,
            isDone: false, createdAt: DateTime.now(), category: 'Work'),
      ];
      _saveTasks();
    }
    if (_habits.isEmpty) {
      _habits = [
        HabitModel(id: _uuid.v4(), name: 'Exercise', emoji: '🏋️',
            color: const Color(0xFF4FFFB0),
            completedDates: _last21Days()),
        HabitModel(id: _uuid.v4(), name: 'Read', emoji: '📚',
            color: const Color(0xFF4FC3F7),
            completedDates: _last18Days()),
        HabitModel(id: _uuid.v4(), name: 'Meditate', emoji: '🧘',
            color: const Color(0xFF7C6FFF),
            completedDates: _last30Days()),
        HabitModel(id: _uuid.v4(), name: 'Code', emoji: '💻',
            color: const Color(0xFFFFB347),
            completedDates: _last14Days()),
        HabitModel(id: _uuid.v4(), name: 'Water 2L', emoji: '💧',
            color: const Color(0xFFFF6F91),
            completedDates: _last7Days()),
      ];
      _saveHabits();
    }
    if (_transactions.isEmpty) {
      _transactions = [
        Transaction(id: _uuid.v4(), description: 'Salary', amount: 55000,
            type: TransactionType.income, category: 'Income',
            date: DateTime.now().subtract(const Duration(days: 1))),
        Transaction(id: _uuid.v4(), description: 'Grocery', amount: 850,
            type: TransactionType.expense, category: 'Food',
            date: DateTime.now()),
        Transaction(id: _uuid.v4(), description: 'SIP Investment', amount: 8000,
            type: TransactionType.investment, category: 'Investment',
            date: DateTime.now().subtract(const Duration(days: 2))),
        Transaction(id: _uuid.v4(), description: 'Electricity Bill', amount: 1200,
            type: TransactionType.expense, category: 'Utilities',
            date: DateTime.now().subtract(const Duration(days: 1))),
        Transaction(id: _uuid.v4(), description: 'Savings Transfer', amount: 12000,
            type: TransactionType.savings, category: 'Savings',
            date: DateTime.now().subtract(const Duration(days: 1))),
        Transaction(id: _uuid.v4(), description: 'Swiggy', amount: 340,
            type: TransactionType.expense, category: 'Food',
            date: DateTime.now().subtract(const Duration(days: 2))),
      ];
      _saveTransactions();
    }
    if (_healthLogs.isEmpty) {
      _healthLogs = [
        HealthLog(id: _uuid.v4(), date: DateTime.now(),
            steps: 7842, waterLiters: 1.8, caloriesConsumed: 1840,
            caloriesBurned: 420, sleepHours: 7.3, heartRate: 72,
            workout: 'Morning run 5km'),
      ];
      _saveHealth();
    }
    if (_goals.isEmpty) {
      _goals = [
        GoalModel(id: _uuid.v4(), title: 'Build LifeBoard v2.0', category: GoalCategory.career,
            progress: 0.68, createdAt: DateTime.now().subtract(const Duration(days: 30)),
            targetDate: DateTime.now().add(const Duration(days: 19)),
            color: const Color(0xFF4FFFB0),
            milestones: ['Design UI', 'Core features', 'Testing', 'Launch'],
            completedMilestones: ['Design UI', 'Core features']),
        GoalModel(id: _uuid.v4(), title: 'Read 12 books this year', category: GoalCategory.education,
            progress: 0.25, createdAt: DateTime(2026, 1, 1),
            targetDate: DateTime(2026, 12, 31),
            color: const Color(0xFF7C6FFF)),
        GoalModel(id: _uuid.v4(), title: 'Save ₹1.5L this year', category: GoalCategory.finance,
            progress: 0.41, createdAt: DateTime(2026, 1, 1),
            targetDate: DateTime(2026, 12, 31),
            color: const Color(0xFFFFB347)),
        GoalModel(id: _uuid.v4(), title: 'Run 300km total', category: GoalCategory.health,
            progress: 0.53, createdAt: DateTime(2026, 1, 1),
            targetDate: DateTime(2026, 12, 31),
            color: const Color(0xFFFF6F91)),
        GoalModel(id: _uuid.v4(), title: 'Win National Hackathon 🏆', category: GoalCategory.career,
            progress: 0.80, createdAt: DateTime(2026, 2, 1),
            targetDate: DateTime.now().add(const Duration(days: 4)),
            color: const Color(0xFF4FFFB0)),
      ];
      _saveGoals();
    }
  }

  List<DateTime> _last21Days() => List.generate(21, (i) =>
      DateTime.now().subtract(Duration(days: i)));
  List<DateTime> _last18Days() => List.generate(18, (i) =>
      DateTime.now().subtract(Duration(days: i)));
  List<DateTime> _last30Days() => List.generate(30, (i) =>
      DateTime.now().subtract(Duration(days: i)));
  List<DateTime> _last14Days() => List.generate(14, (i) =>
      DateTime.now().subtract(Duration(days: i)));
  List<DateTime> _last7Days() => List.generate(7, (i) =>
      DateTime.now().subtract(Duration(days: i)));

  // ─── TASK ACTIONS ─────────────────────────────────────
  void addTask(TaskModel task) {
    _tasks.insert(0, task);
    _saveTasks();
    _addXP(10);
    notifyListeners();
  }

  void toggleTask(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tasks[idx].isDone = !_tasks[idx].isDone;
      if (_tasks[idx].isDone) _addXP(15);
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  // ─── HABIT ACTIONS ────────────────────────────────────
  void addHabit(HabitModel habit) {
    _habits.add(habit);
    _saveHabits();
    _addXP(20);
    notifyListeners();
  }

  void toggleHabitToday(String id) {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx != -1) {
      final today = DateTime.now();
      final habit = _habits[idx];
      if (habit.isCompletedToday()) {
        habit.completedDates.removeWhere((d) =>
            d.year == today.year && d.month == today.month && d.day == today.day);
      } else {
        habit.completedDates.add(today);
        _addXP(10);
      }
      _saveHabits();
      notifyListeners();
    }
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    _saveHabits();
    notifyListeners();
  }

  // ─── FINANCE ACTIONS ──────────────────────────────────
  void addTransaction(Transaction txn) {
    _transactions.insert(0, txn);
    _saveTransactions();
    _addXP(5);
    notifyListeners();
  }

  // ─── HEALTH ACTIONS ───────────────────────────────────
  void saveHealthLog(HealthLog log) {
    final now = DateTime.now();
    _healthLogs.removeWhere((h) =>
        h.date.year == now.year && h.date.month == now.month && h.date.day == now.day);
    _healthLogs.insert(0, log);
    _saveHealth();
    _addXP(20);
    notifyListeners();
  }

  // ─── JOURNAL ACTIONS ──────────────────────────────────
  void saveJournalEntry(JournalEntry entry) {
    final now = DateTime.now();
    _journalEntries.removeWhere((j) =>
        j.date.year == now.year && j.date.month == now.month && j.date.day == now.day);
    _journalEntries.insert(0, entry);
    _saveJournal();
    _addXP(15);
    notifyListeners();
  }

  // ─── GOAL ACTIONS ─────────────────────────────────────
  void addGoal(GoalModel goal) {
    _goals.add(goal);
    _saveGoals();
    _addXP(25);
    notifyListeners();
  }

  void updateGoalProgress(String id, double progress) {
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx != -1) {
      _goals[idx].progress = progress.clamp(0.0, 1.0);
      if (progress >= 1.0) {
        _goals[idx].isCompleted = true;
        _addXP(100);
      }
      _saveGoals();
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    _saveGoals();
    notifyListeners();
  }

  // ─── XP SYSTEM ────────────────────────────────────────
  void _addXP(int amount) {
    _profile.xp += amount;
    while (_profile.xp >= _profile.totalXpForLevel) {
      _profile.xp -= _profile.totalXpForLevel;
      _profile.level++;
      _profile.totalXpForLevel = (_profile.totalXpForLevel * 1.2).round();
    }
    _prefs.setInt('profile_level', _profile.level);
    _prefs.setInt('profile_xp', _profile.xp);
  }

  void updateProfileName(String name) {
    _profile.name = name;
    _prefs.setString('profile_name', name);
    notifyListeners();
  }

  // ─── PERSIST ──────────────────────────────────────────
  void _saveTasks() => _prefs.setString('tasks',
      jsonEncode(_tasks.map((t) => t.toMap()).toList()));
  void _saveHabits() => _prefs.setString('habits',
      jsonEncode(_habits.map((h) => h.toMap()).toList()));
  void _saveTransactions() => _prefs.setString('transactions',
      jsonEncode(_transactions.map((t) => t.toMap()).toList()));
  void _saveHealth() => _prefs.setString('health',
      jsonEncode(_healthLogs.map((h) => h.toMap()).toList()));
  void _saveJournal() => _prefs.setString('journal',
      jsonEncode(_journalEntries.map((j) => j.toMap()).toList()));
  void _saveGoals() => _prefs.setString('goals',
      jsonEncode(_goals.map((g) => g.toMap()).toList()));
}
