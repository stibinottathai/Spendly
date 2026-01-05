import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/budget_model.dart';
import '../utils/category_utils.dart';
import '../services/auth_service.dart';
import 'expense_provider.dart';

// Provider for current month/year selection
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Provider for all budgets for the selected month (Listening to Stream)
final budgetsProvider = StreamProvider<List<CategoryBudget>>((ref) {
  // Watch auth state to rebuild stream on user change
  ref.watch(authStateProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore
      .getBudgetsStream(); // In real app, we might want to filter by month client-side or query
});

// Provider for monthly spending by category (Helper, can be optimized)
final monthlySpendingByCategoryProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  final selectedDate = ref.watch(selectedMonthProvider);

  final Map<String, double> spending = {};

  for (var expense in expenses) {
    if (expense.date.year == selectedDate.year &&
        expense.date.month == selectedDate.month) {
      spending.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
  }
  return spending;
});

// Provider for budget summary with balance for each category - Returns AsyncValue
final budgetSummaryProvider = Provider<AsyncValue<List<CategoryBudgetSummary>>>(
  (ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final selectedDate = ref.watch(selectedMonthProvider);

    if (budgetsAsync.isLoading || expensesAsync.isLoading) {
      return const AsyncValue.loading();
    }

    if (budgetsAsync.hasError) {
      return AsyncValue.error(budgetsAsync.error!, budgetsAsync.stackTrace!);
    }
    if (expensesAsync.hasError) {
      return AsyncValue.error(expensesAsync.error!, expensesAsync.stackTrace!);
    }

    final budgets = budgetsAsync.asData?.value ?? [];
    final expenses = expensesAsync.asData?.value ?? [];

    // Calculate spending
    final Map<String, double> spending = {};
    for (var expense in expenses) {
      if (expense.date.year == selectedDate.year &&
          expense.date.month == selectedDate.month) {
        spending.update(
          expense.category,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }

    // Get all categories from CategoryUtils
    final allCategories = CategoryUtils.categoryIcons.keys.toList();

    final List<CategoryBudgetSummary> summaries = [];

    for (final category in allCategories) {
      // Filter budget for this specific month/year
      final budget = budgets
          .where(
            (b) =>
                b.category == category &&
                b.month == selectedDate.month &&
                b.year == selectedDate.year,
          )
          .firstOrNull;
      final spent = spending[category] ?? 0.0;

      summaries.add(
        CategoryBudgetSummary(
          category: category,
          budgetAmount: budget?.budgetAmount ?? 0.0,
          spentAmount: spent,
          month: selectedDate.month,
          year: selectedDate.year,
        ),
      );
    }

    return AsyncValue.data(summaries);
  },
);

// Check if any category is over budget
final hasOverBudgetProvider = Provider<bool>((ref) {
  final summariesAsync = ref.watch(budgetSummaryProvider);
  return summariesAsync.maybeWhen(
    data: (summaries) =>
        summaries.any((s) => s.budgetAmount > 0 && s.isOverBudget),
    orElse: () => false, // Default to false if loading or error
  );
});

// Notifier for managing budgets
class BudgetNotifier extends StreamNotifier<List<CategoryBudget>> {
  @override
  Stream<List<CategoryBudget>> build() {
    // Watch auth state to rebuild stream on user change
    ref.watch(authStateProvider);
    final firestore = ref.watch(firestoreServiceProvider);
    return firestore.getBudgetsStream();
  }

  Future<void> setBudget(String category, double amount) async {
    final firestore = ref.read(firestoreServiceProvider);
    final selectedDate = ref.read(selectedMonthProvider);
    final budget = CategoryBudget(
      category: category,
      budgetAmount: amount,
      month: selectedDate.month,
      year: selectedDate.year,
    );
    await firestore.setBudget(budget);
  }

  Future<void> deleteBudget(String id) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.deleteBudget(id);
  }
}

final budgetNotifierProvider =
    StreamNotifierProvider<BudgetNotifier, List<CategoryBudget>>(
      BudgetNotifier.new,
    );

// Helper class for budget summary
class CategoryBudgetSummary {
  final String category;
  final double budgetAmount;
  final double spentAmount;
  final int month;
  final int year;

  CategoryBudgetSummary({
    required this.category,
    required this.budgetAmount,
    required this.spentAmount,
    required this.month,
    required this.year,
  });

  double get remainingAmount => budgetAmount - spentAmount;
  bool get isOverBudget => budgetAmount > 0 && spentAmount > budgetAmount;
  double get percentUsed =>
      budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 1.5) : 0.0;
}
