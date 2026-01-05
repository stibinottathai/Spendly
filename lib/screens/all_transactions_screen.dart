import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense_model.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/expense_form_sheet.dart';
import '../theme/app_theme.dart';

enum FilterType { thisWeek, thisMonth, thisYear, custom }

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  ConsumerState<AllTransactionsScreen> createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  FilterType _selectedFilter = FilterType.thisMonth;
  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(expensesProvider).value ?? [];
    final filteredExpenses = _filterExpenses(allExpenses);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'All Transactions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  // Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: AppTheme.glassDecoration(context),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<FilterType>(
                        value: _selectedFilter,
                        isExpanded: true,
                        icon: Icon(
                          LucideIcons.chevronDown,
                          color: AppTheme.primaryGradientStart,
                        ),
                        dropdownColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkCard
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: [
                          DropdownMenuItem(
                            value: FilterType.thisWeek,
                            child: _buildFilterItem(
                              LucideIcons.calendar,
                              'This Week',
                            ),
                          ),
                          DropdownMenuItem(
                            value: FilterType.thisMonth,
                            child: _buildFilterItem(
                              LucideIcons.calendarDays,
                              'This Month',
                            ),
                          ),
                          DropdownMenuItem(
                            value: FilterType.thisYear,
                            child: _buildFilterItem(
                              LucideIcons.calendarRange,
                              'This Year',
                            ),
                          ),
                          DropdownMenuItem(
                            value: FilterType.custom,
                            child: _buildFilterItem(
                              LucideIcons.calendarSearch,
                              'Custom Date Range',
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == FilterType.custom) {
                            final range = await _showDateRangePicker();
                            if (range != null) {
                              setState(() {
                                _selectedFilter = value!;
                                _customDateRange = range;
                              });
                            }
                          } else if (value != null) {
                            setState(() {
                              _selectedFilter = value;
                              _customDateRange = null;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  // Custom Date Range Display
                  if (_selectedFilter == FilterType.custom &&
                      _customDateRange != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final range = await _showDateRangePicker();
                        if (range != null) {
                          setState(() {
                            _customDateRange = range;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryGradientStart.withValues(
                                alpha: 0.1,
                              ),
                              AppTheme.primaryGradientEnd.withValues(
                                alpha: 0.1,
                              ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryGradientStart.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 18,
                              color: AppTheme.primaryGradientStart,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${DateFormat('MMM d, yyyy').format(_customDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_customDateRange!.end)}',
                              style: TextStyle(
                                color: AppTheme.primaryGradientStart,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              LucideIcons.edit3,
                              size: 14,
                              color: AppTheme.primaryGradientStart,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Transactions Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredExpenses.length} Transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (filteredExpenses.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total: ₹${_calculateTotal(filteredExpenses).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppTheme.dangerColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Transactions List
            Expanded(
              child: filteredExpenses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return TransactionListItem(
                          expense: expense,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) =>
                                  ExpenseFormSheet(expense: expense),
                            );
                          },
                          onDelete: () {
                            if (expense.firebaseId != null) {
                              ref
                                  .read(expensesProvider.notifier)
                                  .deleteExpense(expense.firebaseId!);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGradientStart),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGradientStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.receipt,
              size: 48,
              color: AppTheme.primaryGradientStart,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Transactions Found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No transactions match the selected filter',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTimeRange?> _showDateRangePicker() async {
    final now = DateTime.now();
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange:
          _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryGradientStart,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case FilterType.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        );
        return expenses.where((e) {
          return e.date.isAfter(
                startOfWeek.subtract(const Duration(days: 1)),
              ) &&
              e.date.isBefore(now.add(const Duration(days: 1)));
        }).toList();

      case FilterType.thisMonth:
        return expenses.where((e) {
          return e.date.year == now.year && e.date.month == now.month;
        }).toList();

      case FilterType.thisYear:
        return expenses.where((e) {
          return e.date.year == now.year;
        }).toList();

      case FilterType.custom:
        if (_customDateRange == null) return expenses;
        return expenses.where((e) {
          return e.date.isAfter(
                _customDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              e.date.isBefore(
                _customDateRange!.end.add(const Duration(days: 1)),
              );
        }).toList();
    }
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }
}
