import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryBudget {
  final int? id;
  final String? firebaseId;
  final String category;
  final double budgetAmount;
  final int month; // 1-12
  final int year;

  CategoryBudget({
    this.id,
    this.firebaseId,
    required this.category,
    required this.budgetAmount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'budget_amount': budgetAmount,
      'month': month,
      'year': year,
    };
  }

  factory CategoryBudget.fromMap(Map<String, dynamic> map) {
    return CategoryBudget(
      id: map['id'] as int?,
      category: map['category'] as String,
      budgetAmount: map['budget_amount'] as double,
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  // Firestore serialization
  factory CategoryBudget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryBudget(
      firebaseId: doc.id,
      category: data['category'] as String,
      budgetAmount: (data['budgetAmount'] as num).toDouble(),
      month: data['month'] as int,
      year: data['year'] as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'budgetAmount': budgetAmount,
      'month': month,
      'year': year,
    };
  }

  CategoryBudget copyWith({
    int? id,
    String? firebaseId,
    String? category,
    double? budgetAmount,
    int? month,
    int? year,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      category: category ?? this.category,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
