import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

/// Festival Budget Model
class FestivalBudget {
  final String id;
  final String festivalId;
  final String festivalName;
  final String festivalNameHi;
  final DateTime festivalDate;
  final double totalBudget;
  final double spentAmount;
  final Map<String, BudgetCategory> categories;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final bool isActive;

  FestivalBudget({
    required this.id,
    required this.festivalId,
    required this.festivalName,
    required this.festivalNameHi,
    required this.festivalDate,
    required this.totalBudget,
    required this.categories,
    this.spentAmount = 0,
    DateTime? createdAt,
    this.lastUpdated,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  double get remainingBudget => totalBudget - spentAmount;
  double get spentPercentage =>
      totalBudget > 0 ? (spentAmount / totalBudget) * 100 : 0;
  bool get isOverBudget => spentAmount > totalBudget;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'festivalId': festivalId,
      'festivalName': festivalName,
      'festivalNameHi': festivalNameHi,
      'festivalDate': festivalDate.toIso8601String(),
      'totalBudget': totalBudget,
      'spentAmount': spentAmount,
      'categories':
          categories.map((key, value) => MapEntry(key, value.toJson())),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory FestivalBudget.fromJson(Map<String, dynamic> json) {
    return FestivalBudget(
      id: json['id'],
      festivalId: json['festivalId'],
      festivalName: json['festivalName'],
      festivalNameHi: json['festivalNameHi'],
      festivalDate: DateTime.parse(json['festivalDate']),
      totalBudget: json['totalBudget'].toDouble(),
      spentAmount: json['spentAmount']?.toDouble() ?? 0,
      categories: (json['categories'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, BudgetCategory.fromJson(value))),
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }
}

/// Budget Category Model
class BudgetCategory {
  final String category;
  final String categoryHi;
  final double budgetedAmount;
  final double spentAmount;
  final List<String> items;
  final List<BudgetExpense> expenses;

  BudgetCategory({
    required this.category,
    required this.categoryHi,
    required this.budgetedAmount,
    required this.items,
    this.spentAmount = 0,
    this.expenses = const [],
  });

  double get remainingAmount => budgetedAmount - spentAmount;
  double get spentPercentage =>
      budgetedAmount > 0 ? (spentAmount / budgetedAmount) * 100 : 0;
  bool get isOverBudget => spentAmount > budgetedAmount;

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'categoryHi': categoryHi,
      'budgetedAmount': budgetedAmount,
      'spentAmount': spentAmount,
      'items': items,
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };
  }

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      category: json['category'],
      categoryHi: json['categoryHi'],
      budgetedAmount: json['budgetedAmount'].toDouble(),
      spentAmount: json['spentAmount']?.toDouble() ?? 0,
      items: List<String>.from(json['items']),
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => BudgetExpense.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Budget Expense Model
class BudgetExpense {
  final String id;
  final String itemName;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? vendor;

  BudgetExpense({
    required this.id,
    required this.itemName,
    required this.amount,
    required this.date,
    this.notes,
    this.vendor,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'vendor': vendor,
    };
  }

  factory BudgetExpense.fromJson(Map<String, dynamic> json) {
    return BudgetExpense(
      id: json['id'],
      itemName: json['itemName'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      vendor: json['vendor'],
    );
  }
}

/// Festival from JSON
class Festival {
  final String id;
  final String nameEn;
  final String nameHi;
  final DateTime date;
  final String category;
  final String region;
  final String description;
  final String culturalSignificance;
  final String emoji;
  final List<BudgetCategoryTemplate> budgetCategories;

  Festival({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.date,
    required this.category,
    required this.region,
    required this.description,
    required this.culturalSignificance,
    required this.emoji,
    required this.budgetCategories,
  });

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      id: json['id'],
      nameEn: json['nameEn'],
      nameHi: json['nameHi'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      region: json['region'],
      description: json['description'],
      culturalSignificance: json['culturalSignificance'],
      emoji: json['emoji'],
      budgetCategories: (json['budgetCategories'] as List<dynamic>)
          .map((e) => BudgetCategoryTemplate.fromJson(e))
          .toList(),
    );
  }
}

class BudgetCategoryTemplate {
  final String category;
  final String categoryHi;
  final double estimatedCost;
  final List<String> items;

  BudgetCategoryTemplate({
    required this.category,
    required this.categoryHi,
    required this.estimatedCost,
    required this.items,
  });

  factory BudgetCategoryTemplate.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryTemplate(
      category: json['category'],
      categoryHi: json['categoryHi'],
      estimatedCost: json['estimatedCost'].toDouble(),
      items: List<String>.from(json['items']),
    );
  }
}

/// Event Budget Service
class EventBudgetService extends ChangeNotifier {
  static const String _boxName = 'event_budgets';
  static const String _budgetsKey = 'festival_budgets';

  static EventBudgetService? _instance;
  static EventBudgetService get instance =>
      _instance ??= EventBudgetService._internal();

  EventBudgetService._internal();

  List<FestivalBudget> _budgets = [];
  List<Festival> _festivals = [];
  Map<String, dynamic> _budgetTemplates = {};
  bool _isInitialized = false;

  List<FestivalBudget> get budgets => List.unmodifiable(_budgets);
  List<Festival> get festivals => List.unmodifiable(_festivals);
  Map<String, dynamic> get budgetTemplates =>
      Map.unmodifiable(_budgetTemplates);
  bool get isInitialized => _isInitialized;

  /// Initialize service
  static Future<void> initialize() async {
    _instance ??= EventBudgetService._internal();
    await _instance!._initializeService();
  }

  /// Initialize the budget service
  Future<void> _initializeService() async {
    try {
      // Load festivals from JSON
      await _loadFestivalsFromJson();

      // Initialize Hive box
      await Hive.openBox(_boxName);

      // Load saved budgets
      await _loadBudgets();

      _isInitialized = true;
      notifyListeners();

      debugPrint(
          '✅ Event Budget Service initialized with ${_budgets.length} budgets and ${_festivals.length} festivals');
    } catch (e) {
      debugPrint('❌ Error initializing Event Budget Service: $e');
      _isInitialized = false;
    }
  }

  /// Load festivals from JSON file
  Future<void> _loadFestivalsFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('Demo_data/TrueCircle_Festivals_Data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Process festivals from TrueCircle format
      final List<dynamic> festivalsList = jsonData['festivals'] as List<dynamic>;
      _festivals = festivalsList.map((festivalData) {
        // Convert TrueCircle festival format to internal Festival format
        return Festival(
          id: festivalData['id'] ?? '',
          nameEn: festivalData['name'] ?? '',
          nameHi: festivalData['hindiName'] ?? '',
          date: _parseFestivalDate(festivalData['month'] ?? ''),
          category: festivalData['type'] ?? 'cultural',
          region: (festivalData['regions'] as List<dynamic>?)?.join(', ') ?? 'Pan-India',
          description: festivalData['description'] ?? '',
          culturalSignificance: festivalData['description'] ?? '',
          emoji: _getFestivalEmoji(festivalData['id'] ?? ''),
          budgetCategories: _getBudgetCategoriesForFestival(festivalData['id'] ?? ''),
        );
      }).toList();

      // Load 30-day sample budget data
      await _loadSampleBudgetData();

      debugPrint('✅ Loaded ${_festivals.length} festivals from TrueCircle data');
    } catch (e) {
      debugPrint('❌ Error loading festivals JSON: $e');
      _festivals = [];
      _budgetTemplates = {};
      // Load fallback sample data
      await _loadSampleBudgetData();
    }
  }

  /// Load saved budgets from Hive
  Future<void> _loadBudgets() async {
    try {
      final box = Hive.box(_boxName);
      final List<dynamic> budgetData =
          box.get(_budgetsKey, defaultValue: <dynamic>[]);

      _budgets = budgetData
          .map((data) =>
              FestivalBudget.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading budgets: $e');
      _budgets = [];
    }
  }

  /// Save budgets to Hive
  Future<void> _saveBudgets() async {
    try {
      final box = Hive.box(_boxName);
      final List<Map<String, dynamic>> budgetData =
          _budgets.map((budget) => budget.toJson()).toList();

      await box.put(_budgetsKey, budgetData);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error saving budgets: $e');
    }
  }

  /// Create budget for a festival
  Future<FestivalBudget> createFestivalBudget({
    required String festivalId,
    required double totalBudget,
    String? budgetTemplate,
  }) async {
    final festival = _festivals.firstWhere((f) => f.id == festivalId);

    // Create budget categories from festival template
    final Map<String, BudgetCategory> categories = {};

    for (final template in festival.budgetCategories) {
      // Adjust category budget based on total budget
      double categoryBudget = template.estimatedCost;

      // If using budget template, adjust proportionally
      if (budgetTemplate != null &&
          _budgetTemplates.containsKey(budgetTemplate)) {
        // Get template budget (unused variable removed)
        final totalTemplateBudget = festival.budgetCategories
            .fold<double>(0, (sum, cat) => sum + cat.estimatedCost);
        categoryBudget =
            (template.estimatedCost / totalTemplateBudget) * totalBudget;
      }

      categories[template.category] = BudgetCategory(
        category: template.category,
        categoryHi: template.categoryHi,
        budgetedAmount: categoryBudget,
        items: template.items,
      );
    }

    final budget = FestivalBudget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      festivalId: festival.id,
      festivalName: festival.nameEn,
      festivalNameHi: festival.nameHi,
      festivalDate: festival.date,
      totalBudget: totalBudget,
      categories: categories,
    );

    _budgets.add(budget);
    await _saveBudgets();

    debugPrint(
        '✅ Created budget for ${festival.nameEn}: ₹${totalBudget.toStringAsFixed(0)}');
    return budget;
  }

  /// Add expense to budget
  Future<void> addExpense({
    required String budgetId,
    required String category,
    required String itemName,
    required double amount,
    String? notes,
    String? vendor,
  }) async {
    final budgetIndex = _budgets.indexWhere((b) => b.id == budgetId);
    if (budgetIndex == -1) return;

    final budget = _budgets[budgetIndex];
    final categoryData = budget.categories[category];
    if (categoryData == null) return;

    final expense = BudgetExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: itemName,
      amount: amount,
      date: DateTime.now(),
      notes: notes,
      vendor: vendor,
    );

    final updatedExpenses = List<BudgetExpense>.from(categoryData.expenses)
      ..add(expense);
    final updatedSpentAmount = categoryData.spentAmount + amount;

    final updatedCategory = BudgetCategory(
      category: categoryData.category,
      categoryHi: categoryData.categoryHi,
      budgetedAmount: categoryData.budgetedAmount,
      spentAmount: updatedSpentAmount,
      items: categoryData.items,
      expenses: updatedExpenses,
    );

    final updatedCategories =
        Map<String, BudgetCategory>.from(budget.categories);
    updatedCategories[category] = updatedCategory;

    final totalSpent = updatedCategories.values
        .fold<double>(0, (sum, cat) => sum + cat.spentAmount);

    _budgets[budgetIndex] = FestivalBudget(
      id: budget.id,
      festivalId: budget.festivalId,
      festivalName: budget.festivalName,
      festivalNameHi: budget.festivalNameHi,
      festivalDate: budget.festivalDate,
      totalBudget: budget.totalBudget,
      spentAmount: totalSpent,
      categories: updatedCategories,
      createdAt: budget.createdAt,
      lastUpdated: DateTime.now(),
      isActive: budget.isActive,
    );

    await _saveBudgets();
    debugPrint('✅ Added expense: ₹$amount for $itemName in $category');
  }

  /// Get upcoming festivals (next 60 days)
  List<Festival> getUpcomingFestivals() {
    final now = DateTime.now();
    final next60Days = now.add(const Duration(days: 60));

    return _festivals
        .where((festival) =>
            festival.date.isAfter(now) && festival.date.isBefore(next60Days))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get budget for specific festival
  FestivalBudget? getBudgetForFestival(String festivalId) {
    try {
      return _budgets.firstWhere((budget) => budget.festivalId == festivalId);
    } catch (e) {
      return null;
    }
  }

  /// Get budget summary
  Map<String, dynamic> getBudgetSummary() {
    if (_budgets.isEmpty) {
      return {
        'totalBudgets': 0,
        'totalPlanned': 0.0,
        'totalSpent': 0.0,
        'averageBudget': 0.0,
        'activeBudgets': 0,
      };
    }

    final activeBudgets = _budgets.where((b) => b.isActive).toList();
    final totalPlanned =
        activeBudgets.fold<double>(0, (sum, b) => sum + b.totalBudget);
    final totalSpent =
        activeBudgets.fold<double>(0, (sum, b) => sum + b.spentAmount);

    return {
      'totalBudgets': _budgets.length,
      'totalPlanned': totalPlanned,
      'totalSpent': totalSpent,
      'averageBudget':
          activeBudgets.isNotEmpty ? totalPlanned / activeBudgets.length : 0,
      'activeBudgets': activeBudgets.length,
      'remainingBudget': totalPlanned - totalSpent,
      'spentPercentage':
          totalPlanned > 0 ? (totalSpent / totalPlanned) * 100 : 0,
    };
  }

  /// Delete budget
  Future<void> deleteBudget(String budgetId) async {
    _budgets.removeWhere((budget) => budget.id == budgetId);
    await _saveBudgets();
    debugPrint('✅ Deleted budget: $budgetId');
  }

  /// Update budget
  Future<void> updateBudget(FestivalBudget updatedBudget) async {
    final index = _budgets.indexWhere((b) => b.id == updatedBudget.id);
    if (index != -1) {
      _budgets[index] = updatedBudget;
      await _saveBudgets();
      debugPrint('✅ Updated budget: ${updatedBudget.festivalName}');
    }
  }

  /// Parse festival date from month string
  DateTime _parseFestivalDate(String month) {
    final now = DateTime.now();
    final monthMap = {
      'January': 1, 'February': 2, 'March': 3, 'April': 4,
      'May': 5, 'June': 6, 'July': 7, 'August': 8,
      'September': 9, 'October': 10, 'November': 11, 'December': 12
    };
    
    final monthNum = monthMap[month] ?? now.month;
    var year = now.year;
    
    // If month has passed this year, set to next year
    if (monthNum < now.month) {
      year = now.year + 1;
    }
    
    return DateTime(year, monthNum, 15); // Mid-month date
  }

  /// Get emoji for festival
  String _getFestivalEmoji(String festivalId) {
    final emojiMap = {
      'diwali': '🪔', 'holi': '🌈', 'navratri': '💃', 'ganesh_chaturthi': '🐘',
      'janmashtami': '🦚', 'raksha_bandhan': '🎀', 'dussehra': '🏹',
      'eid_ul_fitr': '🌙', 'christmas': '🎄', 'independence_day': '🇮🇳',
      'republic_day': '🇮🇳', 'makar_sankranti': '🪁', 'maha_shivratri': '🕉️',
      'ram_navami': '🙏', 'karva_chauth': '🌙', 'lohri': '🔥', 'pongal': '🌾',
      'ugadi': '🌸', 'gudi_padwa': '🎏', 'vasant_panchami': '📚'
    };
    return emojiMap[festivalId.toLowerCase()] ?? '🎉';
  }

  /// Get budget categories for festival
  List<BudgetCategoryTemplate> _getBudgetCategoriesForFestival(String festivalId) {
    // Common categories for all festivals
    final commonCategories = [
      BudgetCategoryTemplate(
        category: 'Decorations',
        categoryHi: 'सजावट',
        estimatedCost: 2000,
        items: ['Flowers', 'Lights', 'Rangoli items', 'Candles'],
      ),
      BudgetCategoryTemplate(
        category: 'Food & Sweets',
        categoryHi: 'खाना और मिठाई',
        estimatedCost: 3000,
        items: ['Sweets', 'Snacks', 'Main dishes', 'Ingredients'],
      ),
      BudgetCategoryTemplate(
        category: 'Gifts',
        categoryHi: 'उपहार',
        estimatedCost: 1500,
        items: ['Family gifts', 'Friend gifts', 'Donation items'],
      ),
      BudgetCategoryTemplate(
        category: 'Clothing',
        categoryHi: 'कपड़े',
        estimatedCost: 2500,
        items: ['Traditional wear', 'Accessories', 'Footwear'],
      ),
    ];

    // Festival-specific categories
    switch (festivalId.toLowerCase()) {
      case 'diwali':
        return commonCategories + [
          BudgetCategoryTemplate(
            category: 'Firecrackers',
            categoryHi: 'पटाखे',
            estimatedCost: 1000,
            items: ['Sparklers', 'Rockets', 'Crackers'],
          ),
        ];
      case 'holi':
        return commonCategories + [
          BudgetCategoryTemplate(
            category: 'Colors & Water',
            categoryHi: 'रंग और पानी',
            estimatedCost: 500,
            items: ['Gulal', 'Water balloons', 'Pichkari'],
          ),
        ];
      default:
        return commonCategories;
    }
  }

  /// Load 30-day sample budget data
  Future<void> _loadSampleBudgetData() async {
    if (_budgets.isNotEmpty) return; // Don't override existing data

    try {
      // Generate 30 days of sample festival budget data
      final now = DateTime.now();
      final sampleBudgets = <FestivalBudget>[];

      // Last 30 days festivals with budget data
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        
        // Create budget entries for various festivals
        if (i % 7 == 0) { // Weekly festival budget
          final festivalNames = ['Diwali', 'Holi', 'Navratri', 'Janmashtami'];
          final festivalNamesHi = ['दिवाली', 'होली', 'नवरात्रि', 'जन्माष्टमी'];
          final festivalIndex = i ~/ 7;
          
          if (festivalIndex < festivalNames.length) {
            final totalBudget = 5000.0 + (i * 200); // Varying budgets
            final spentAmount = totalBudget * (0.6 + (i * 0.01)); // 60-90% spent
            
            final budget = FestivalBudget(
              id: 'sample_${i}_${date.millisecondsSinceEpoch}',
              festivalId: 'festival_$i',
              festivalName: festivalNames[festivalIndex],
              festivalNameHi: festivalNamesHi[festivalIndex],
              festivalDate: date,
              totalBudget: totalBudget,
              spentAmount: spentAmount,
              categories: _generateSampleCategories(totalBudget, spentAmount),
              createdAt: date.subtract(const Duration(days: 5)),
              lastUpdated: date,
              isActive: i < 10, // Recent budgets are active
            );
            
            sampleBudgets.add(budget);
          }
        }
      }

      _budgets = sampleBudgets;
      debugPrint('✅ Generated ${_budgets.length} sample budget entries for 30 days');
      
    } catch (e) {
      debugPrint('❌ Error loading sample budget data: $e');
    }
  }

  /// Generate sample categories with spent amounts
  Map<String, BudgetCategory> _generateSampleCategories(double totalBudget, double totalSpent) {
    final categories = <String, BudgetCategory>{};
    final categoryTemplates = _getBudgetCategoriesForFestival('diwali');
    
    double remainingSpent = totalSpent;
    
    for (int i = 0; i < categoryTemplates.length; i++) {
      final template = categoryTemplates[i];
      final budgetedAmount = (totalBudget / categoryTemplates.length);
      final spentAmount = i < categoryTemplates.length - 1 
          ? (remainingSpent / (categoryTemplates.length - i)) * (0.8 + (i * 0.1))
          : remainingSpent;
      
      remainingSpent -= spentAmount;
      
      // Generate sample expenses
      final expenses = <BudgetExpense>[];
      final numExpenses = (spentAmount / 500).ceil(); // ~500 per expense
      
      for (int j = 0; j < numExpenses && j < 5; j++) {
        final expenseAmount = spentAmount / numExpenses;
        expenses.add(BudgetExpense(
          id: 'expense_${i}_$j',
          itemName: template.items[j % template.items.length],
          amount: expenseAmount,
          date: DateTime.now().subtract(Duration(days: j + 1)),
          notes: 'Sample expense for ${template.category}',
          vendor: 'Sample Vendor ${j + 1}',
        ));
      }
      
      categories[template.category] = BudgetCategory(
        category: template.category,
        categoryHi: template.categoryHi,
        budgetedAmount: budgetedAmount,
        spentAmount: spentAmount > 0 ? spentAmount : 0,
        items: template.items,
        expenses: expenses,
      );
    }
    
    return categories;
  }
}
