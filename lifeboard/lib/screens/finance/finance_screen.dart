import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../services/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

const _uuid = Uuid();

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final fmt = NumberFormat('#,##,###', 'en_IN');

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

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Finance Tracker', style: AppText.heading),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.orange,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Add'),
          ],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        // OVERVIEW
        _buildOverview(context, state),
        // TRANSACTIONS
        _buildTransactions(context, state),
        // ADD
        _buildAddForm(context, state),
      ]),
    );
  }

  Widget _buildOverview(BuildContext context, AppState state) {
    final categories = <String, double>{};
    for (final t in state.transactions) {
      if (t.type == TransactionType.expense) {
        categories[t.category] = (categories[t.category] ?? 0) + t.amount;
      }
    }

    return ListView(padding: const EdgeInsets.all(20), children: [
      // Balance card
      GlassCard(
        accentColor: AppTheme.orange,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TOTAL BALANCE', style: AppText.cardTitle),
          const SizedBox(height: 8),
          Text('₹${fmt.format(state.totalBalance.abs())}',
            style: AppText.statNumber.copyWith(fontSize: 44, color: AppTheme.orange)),
          const SizedBox(height: 16),
          Row(children: [
            _FinStat('Income', '₹${fmt.format(_getMonthlyIncome(state))}', AppTheme.green),
            const SizedBox(width: 12),
            _FinStat('Expense', '₹${fmt.format(state.monthlySpending)}', AppTheme.pink),
            const SizedBox(width: 12),
            _FinStat('Saved', '₹${fmt.format(state.monthlySavings)}', AppTheme.blue),
          ]),
        ]),
      ),
      const SizedBox(height: 16),

      // Spending breakdown
      GlassCard(
        accentColor: AppTheme.pink,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SPENDING BREAKDOWN', style: AppText.cardTitle),
          const SizedBox(height: 14),
          ...categories.entries.map((e) {
            final total = categories.values.fold(0.0, (a, b) => a + b);
            final pct = total > 0 ? e.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(e.key, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                  Text('₹${fmt.format(e.value)} · ${(pct * 100).round()}%',
                    style: TextStyle(fontSize: 11, color: AppTheme.orange)),
                ]),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => MiniProgressBar(progress: v, color: AppTheme.orange),
                ),
              ]),
            );
          }),
        ]),
      ),
      const SizedBox(height: 16),

      // Budget goals
      GlassCard(
        accentColor: AppTheme.green,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MONTHLY BUDGET', style: AppText.cardTitle),
          const SizedBox(height: 14),
          _BudgetRow('Monthly Budget', state.monthlySpending, 30000, AppTheme.orange),
          const SizedBox(height: 10),
          _BudgetRow('Savings Goal', state.monthlySavings, 15000, AppTheme.green),
          const SizedBox(height: 10),
          _BudgetRow('Investment', _getMonthlyInvestment(state), 10000, AppTheme.purple),
        ]),
      ),
    ]);
  }

  double _getMonthlyIncome(AppState state) {
    final now = DateTime.now();
    return state.transactions
        .where((t) => t.type == TransactionType.income &&
            t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double _getMonthlyInvestment(AppState state) {
    final now = DateTime.now();
    return state.transactions
        .where((t) => t.type == TransactionType.investment &&
            t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (s, t) => s + t.amount);
  }

  Widget _buildTransactions(BuildContext context, AppState state) {
    final txns = state.transactions;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: txns.length,
      itemBuilder: (_, i) {
        final t = txns[i];
        return GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: t.typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(
                t.type == TransactionType.income ? '📈'
                    : t.type == TransactionType.investment ? '📊'
                    : t.type == TransactionType.savings ? '🏦' : '💸',
                style: const TextStyle(fontSize: 18),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.description, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              Text('${t.category} · ${DateFormat('MMM d').format(t.date)}',
                  style: AppText.label),
            ])),
            Text(
              '${t.typeSign}₹${fmt.format(t.amount)}',
              style: TextStyle(fontSize: 14, color: t.typeColor, fontWeight: FontWeight.w700),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildAddForm(BuildContext context, AppState state) {
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    TransactionType type = TransactionType.expense;
    String category = 'Food';

    return StatefulBuilder(
      builder: (ctx, setS) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('ADD TRANSACTION', style: AppText.cardTitle),
          const SizedBox(height: 16),

          // Type selector
          Row(children: TransactionType.values.map((t) {
            final labels = ['Income', 'Expense', 'Invest', 'Save'];
            final icons = ['📈', '💸', '📊', '🏦'];
            final colors = [AppTheme.green, AppTheme.pink, AppTheme.purple, AppTheme.blue];
            final sel = type == t;
            return Expanded(child: GestureDetector(
              onTap: () => setS(() => type = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? colors[t.index].withOpacity(0.15) : AppTheme.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? colors[t.index].withOpacity(0.5) : AppTheme.border),
                ),
                child: Column(children: [
                  Text(icons[t.index], style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(labels[t.index], style: TextStyle(
                    fontSize: 10, color: sel ? colors[t.index] : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  )),
                ]),
              ),
            ));
          }).toList()),
          const SizedBox(height: 16),

          TextField(
            controller: descCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amtCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
              prefixStyle: TextStyle(color: AppTheme.orange, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          Text('CATEGORY', style: AppText.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['Food', 'Transport', 'Utilities', 'Health',
                'Entertainment', 'Shopping', 'Income', 'Investment', 'Other']
                .map((c) => AppChip(
                  label: c, selected: category == c,
                  onTap: () => setS(() => category = c),
                  color: AppTheme.orange,
                )).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text);
              if (descCtrl.text.isEmpty || amt == null) return;
              state.addTransaction(Transaction(
                id: _uuid.v4(),
                description: descCtrl.text,
                amount: amt,
                type: type,
                category: category,
                date: DateTime.now(),
              ));
              descCtrl.clear(); amtCtrl.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction added!')));
            },
            child: const Text('Add Transaction',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _FinStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _FinStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.label),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
    ],
  ));
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double current, target;
  final Color color;
  const _BudgetRow(this.label, this.current, this.target, this.color);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,###', 'en_IN');
    final pct = (current / target).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
        Text('₹${fmt.format(current)} / ₹${fmt.format(target)}',
          style: TextStyle(fontSize: 11, color: color)),
      ]),
      const SizedBox(height: 5),
      MiniProgressBar(progress: pct, color: color),
    ]);
  }
}
