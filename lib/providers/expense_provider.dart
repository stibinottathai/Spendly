import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

// Firestore instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provides the list of all expenses via StreamNotifier
final expensesProvider =
    StreamNotifierProvider<ExpensesNotifier, List<Expense>>(
      ExpensesNotifier.new,
    );

class ExpensesNotifier extends StreamNotifier<List<Expense>> {
  @override
  Stream<List<Expense>> build() {
    // Watch auth state to rebuild stream on user change
    ref.watch(authStateProvider);
    final firestore = ref.watch(firestoreServiceProvider);
    return firestore.getExpensesStream();
  }

  Future<void> addExpense(Expense expense) async {
    final firestore = ref.read(firestoreServiceProvider);
    // Optimistic updates or just wait for stream?
    // Stream will update automatically.
    await firestore.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.updateExpense(expense);
  }

  Future<void> deleteExpense(String firebaseId) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.deleteExpense(firebaseId);
  }
}

// Filtered Providers
final recentExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  // Return top 5 recent expenses
  return expenses.take(5).toList();
});

final totalBalanceProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  return expenses.fold(0, (sum, item) => sum + item.amount);
});

final monthlySpendingProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  final now = DateTime.now();
  final currentMonthExpenses = expenses.where((element) {
    return element.date.year == now.year && element.date.month == now.month;
  });
  return currentMonthExpenses.fold(0, (sum, item) => sum + item.amount);
});

// For Chart Data - Group by Category
final categoryTotalsProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  final Map<String, double> totals = {};

  for (var expense in expenses) {
    totals.update(
      expense.category,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
});

// For Weekly Chart - Last 7 days
final weeklySpendingProvider = Provider<List<double>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  final now = DateTime.now();
  final List<double> weeklyData = List.filled(7, 0.0);

  for (int i = 0; i < 7; i++) {
    final day = now.subtract(Duration(days: i));
    final dayExpenses = expenses.where(
      (e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day,
    );
    weeklyData[6 - i] = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }
  return weeklyData;
});

// For Payment Source Chart - Group by Payment Source
final paymentSourceTotalsProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  final Map<String, double> totals = {};

  for (var expense in expenses) {
    totals.update(
      expense.paymentSource,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
});
