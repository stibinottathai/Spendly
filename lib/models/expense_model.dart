import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final int? id; // Keep for local DB compatibility during migration, if needed
  final String? firebaseId;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String description;
  final String paymentSource;

  Expense({
    this.id,
    this.firebaseId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
    this.paymentSource = 'Cash',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
      'payment_source': paymentSource,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      description: map['description'] as String,
      paymentSource: map['payment_source'] as String? ?? 'Cash',
    );
  }

  // Firestore serialization
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      firebaseId: doc.id,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] as String,
      description: data['description'] as String,
      paymentSource: data['paymentSource'] as String? ?? 'Cash',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'description': description,
      'paymentSource': paymentSource,
    };
  }

  Expense copyWith({
    int? id,
    String? firebaseId,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? description,
    String? paymentSource,
  }) {
    return Expense(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentSource: paymentSource ?? this.paymentSource,
    );
  }
}
