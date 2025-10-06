import 'package:flutter/material.dart';
import '../services/event_budget_service.dart';

/// Event Budget Page - Festival Wise Budget Management
class EventBudgetPage extends StatefulWidget {
  const EventBudgetPage({super.key});

  @override
  State<EventBudgetPage> createState() => _EventBudgetPageState();
}

class _EventBudgetPageState extends State<EventBudgetPage>
    with TickerProviderStateMixin {
  final EventBudgetService _budgetService = EventBudgetService.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeService();
  }

  Future<void> _initializeService() async {
    if (!_budgetService.isInitialized) {
      await EventBudgetService.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Event Budget Manager'),
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.upcoming), text: 'Upcoming'),
            Tab(
                icon: Icon(Icons.account_balance_wallet),
                text: 'Active Budgets'),
            Tab(icon: Icon(Icons.analytics), text: 'Summary'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showCreateBudgetDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Create New Budget',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.teal[50]!,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUpcomingFestivalsTab(),
            _buildActiveBudgetsTab(),
            _buildSummaryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingFestivalsTab() {
    if (!_budgetService.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final upcomingFestivals = _budgetService.getUpcomingFestivals();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingFestivals.length,
      itemBuilder: (context, index) {
        final festival = upcomingFestivals[index];
        final existingBudget = _budgetService.getBudgetForFestival(festival.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(festival.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            festival.nameEn,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            festival.nameHi,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(festival.date),
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (existingBudget != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Budget Set',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  festival.description,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),

                // Budget categories preview
                Text(
                  'Budget Categories:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: festival.budgetCategories.map((category) {
                    return Chip(
                      label: Text(
                        '${category.category} ₹${category.estimatedCost.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Colors.green[100],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => existingBudget != null
                        ? _viewBudget(existingBudget)
                        : _createBudgetForFestival(festival),
                    icon: Icon(
                        existingBudget != null ? Icons.visibility : Icons.add),
                    label: Text(existingBudget != null
                        ? 'View Budget'
                        : 'Create Budget'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          existingBudget != null ? Colors.blue : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveBudgetsTab() {
    final activeBudgets =
        _budgetService.budgets.where((b) => b.isActive).toList();

    if (activeBudgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Active Budgets',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create budgets for upcoming festivals',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateBudgetDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeBudgets.length,
      itemBuilder: (context, index) {
        final budget = activeBudgets[index];
        return _buildBudgetCard(budget);
      },
    );
  }

  Widget _buildBudgetCard(FestivalBudget budget) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewBudget(budget),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.festivalName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          budget.festivalNameHi,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(budget.festivalDate),
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${budget.totalBudget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Spent: ₹${budget.spentAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: budget.isOverBudget
                              ? Colors.red
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar
              LinearProgressIndicator(
                value: budget.spentPercentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  budget.isOverBudget ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${budget.spentPercentage.toStringAsFixed(1)}% spent',
                    style: TextStyle(
                      color:
                          budget.isOverBudget ? Colors.red : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Remaining: ₹${budget.remainingBudget.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: budget.remainingBudget < 0
                          ? Colors.red
                          : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    final summary = _budgetService.getBudgetSummary();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Budgets',
                  '${summary['totalBudgets']}',
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Active Budgets',
                  '${summary['activeBudgets']}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Planned',
                  '₹${(summary['totalPlanned'] as double).toStringAsFixed(0)}',
                  Icons.savings,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Spent',
                  '₹${(summary['totalSpent'] as double).toStringAsFixed(0)}',
                  Icons.money_off,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Spending chart placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Budget vs Spending',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (summary['spentPercentage'] as double) / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      (summary['spentPercentage'] as double) > 100
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(summary['spentPercentage'] as double).toStringAsFixed(1)}% of planned budget spent',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining: ₹${(summary['remainingBudget'] as double).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: (summary['remainingBudget'] as double) < 0
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Average: ₹${(summary['averageBudget'] as double).toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showCreateBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Festival Budget'),
        content: const Text('Select a festival to create a budget for it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(0); // Go to upcoming festivals tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select Festival'),
          ),
        ],
      ),
    );
  }

  void _createBudgetForFestival(Festival festival) {
    showDialog(
      context: context,
      builder: (context) => _BudgetCreationDialog(festival: festival),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh the page
      }
    });
  }

  void _viewBudget(FestivalBudget budget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailPage(budget: budget),
      ),
    ).then((_) => setState(() {}));
  }
}

/// Budget Creation Dialog
class _BudgetCreationDialog extends StatefulWidget {
  final Festival festival;

  const _BudgetCreationDialog({required this.festival});

  @override
  State<_BudgetCreationDialog> createState() => _BudgetCreationDialogState();
}

class _BudgetCreationDialogState extends State<_BudgetCreationDialog> {
  final _budgetController = TextEditingController();
  String? _selectedTemplate;
  final EventBudgetService _budgetService = EventBudgetService.instance;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estimatedTotal = widget.festival.budgetCategories
        .fold<double>(0, (sum, cat) => sum + cat.estimatedCost);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Budget for ${widget.festival.nameEn}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated total: ₹${estimatedTotal.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _budgetController,
            decoration: const InputDecoration(
              labelText: 'Total Budget Amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text(
            'Budget Templates:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          ...(_budgetService.budgetTemplates.entries.map((entry) {
            return ListTile(
              title: Text(entry.value['nameEn']),
              subtitle: Text(
                '₹${entry.value['budget']} - ${entry.value['description']}',
              ),
              // ignore: deprecated_member_use
              leading: Radio<String>(
                value: entry.key,
                // ignore: deprecated_member_use
                groupValue: _selectedTemplate,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() {
                    _selectedTemplate = value;
                    _budgetController.text = entry.value['budget'].toString();
                  });
                },
                toggleable: false,
              ),
              onTap: () {
                setState(() {
                  _selectedTemplate = entry.key;
                  _budgetController.text = entry.value['budget'].toString();
                });
              },
            );
          }).toList()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createBudget,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createBudget() async {
    final budgetText = _budgetController.text.trim();
    if (budgetText.isEmpty) return;

    final budgetAmount = double.tryParse(budgetText);
    if (budgetAmount == null || budgetAmount <= 0) return;

    try {
      await _budgetService.createFestivalBudget(
        festivalId: widget.festival.id,
        totalBudget: budgetAmount,
        budgetTemplate: _selectedTemplate,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget created for ${widget.festival.nameEn}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating budget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Budget Detail Page
class BudgetDetailPage extends StatefulWidget {
  final FestivalBudget budget;

  const BudgetDetailPage({super.key, required this.budget});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  late FestivalBudget _budget;
  final EventBudgetService _budgetService = EventBudgetService.instance;

  @override
  void initState() {
    super.initState();
    _budget = widget.budget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_budget.festivalName),
        backgroundColor: Colors.green[100],
        actions: [
          IconButton(
            onPressed: _showAddExpenseDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Expense',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Budget overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _budget.festivalName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _budget.festivalNameHi,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBudgetStat(
                        'Total Budget',
                        '₹${_budget.totalBudget.toStringAsFixed(0)}',
                        Colors.blue,
                      ),
                      _buildBudgetStat(
                        'Spent',
                        '₹${_budget.spentAmount.toStringAsFixed(0)}',
                        Colors.red,
                      ),
                      _buildBudgetStat(
                        'Remaining',
                        '₹${_budget.remainingBudget.toStringAsFixed(0)}',
                        _budget.remainingBudget < 0 ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _budget.spentPercentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _budget.isOverBudget ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_budget.spentPercentage.toStringAsFixed(1)}% of budget used',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category breakdown
          ...(_budget.categories.entries.map((entry) {
            return _buildCategoryCard(entry.key, entry.value);
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String categoryKey, BudgetCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(category.category),
        subtitle: Text(category.categoryHi),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${category.spentAmount.toStringAsFixed(0)} / ₹${category.budgetedAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${category.spentPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: category.isOverBudget ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: category.spentPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    category.isOverBudget ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 12),

                // Suggested items
                const Text(
                  'Suggested Items:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Wrap(
                  spacing: 8,
                  children: category.items.map((item) {
                    return Chip(
                      label: Text(item, style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.grey[100],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Expenses
                if (category.expenses.isNotEmpty) ...[
                  const Text(
                    'Expenses:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  ...category.expenses.map((expense) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(expense.itemName),
                      subtitle: Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                      ),
                      trailing: Text(
                        '₹${expense.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }),
                ],

                ElevatedButton.icon(
                  onPressed: () => _showAddExpenseDialog(category: categoryKey),
                  icon: const Icon(Icons.add),
                  label: Text('Add Expense to ${category.category}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog({String? category}) {
    showDialog(
      context: context,
      builder: (context) => _AddExpenseDialog(
        budget: _budget,
        preselectedCategory: category,
      ),
    ).then((result) {
      if (result == true) {
        // Refresh budget data
        final updatedBudget =
            _budgetService.getBudgetForFestival(_budget.festivalId);
        if (updatedBudget != null) {
          setState(() {
            _budget = updatedBudget;
          });
        }
      }
    });
  }
}

/// Add Expense Dialog
class _AddExpenseDialog extends StatefulWidget {
  final FestivalBudget budget;
  final String? preselectedCategory;

  const _AddExpenseDialog({
    required this.budget,
    this.preselectedCategory,
  });

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _itemController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _vendorController = TextEditingController();
  String? _selectedCategory;
  final EventBudgetService _budgetService = EventBudgetService.instance;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory;
  }

  @override
  void dispose() {
    _itemController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: widget.budget.categories.keys.map((category) {
                final cat = widget.budget.categories[category]!;
                return DropdownMenuItem(
                  value: category,
                  child: Text('${cat.category} (${cat.categoryHi})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vendorController,
              decoration: const InputDecoration(
                labelText: 'Vendor/Store (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addExpense,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _addExpense() async {
    if (_selectedCategory == null ||
        _itemController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _budgetService.addExpense(
        budgetId: widget.budget.id,
        category: _selectedCategory!,
        itemName: _itemController.text.trim(),
        amount: amount,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        vendor: _vendorController.text.trim().isNotEmpty
            ? _vendorController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
