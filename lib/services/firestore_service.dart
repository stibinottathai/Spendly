import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Collection References
  CollectionReference get _usersRef => _db.collection('users');

  CollectionReference get _expensesRef {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not authenticated');
    return _usersRef.doc(uid).collection('expenses');
  }

  CollectionReference get _budgetsRef {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not authenticated');
    return _usersRef.doc(uid).collection('budgets');
  }

  // --- Expenses ---

  Stream<List<Expense>> getExpensesStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _expensesRef.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Expense.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _expensesRef.add(expense.toFirestore());
    await _updateLastTransactionDate();
  }

  Future<void> updateExpense(Expense expense) async {
    if (expense.firebaseId == null) return;
    await _expensesRef.doc(expense.firebaseId).update(expense.toFirestore());
    await _updateLastTransactionDate();
  }

  Future<void> _updateLastTransactionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_transaction_date', today);
  }

  Future<void> deleteExpense(String firebaseId) async {
    await _expensesRef.doc(firebaseId).delete();
  }

  // --- Budgets ---

  Stream<List<CategoryBudget>> getBudgetsStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _budgetsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryBudget.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> setBudget(CategoryBudget budget) async {
    // We want unique budget per category/month/year
    // We can use a composite ID or query first
    final id = '${budget.category}_${budget.month}_${budget.year}';
    await _budgetsRef.doc(id).set(budget.toFirestore());
  }

  Future<void> deleteBudget(String id) async {
    await _budgetsRef.doc(id).delete();
  }

  // --- Migration ---
  // Migration code removed as local database is deprecated.
}
