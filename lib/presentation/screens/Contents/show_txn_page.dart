import 'package:firebase_auth/firebase_auth.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/logic/expense/expense_cubit.dart';
import 'package:kharchasutra/logic/expense/expense_state.dart';
import 'package:kharchasutra/logic/income/income_cubit.dart';
import 'package:kharchasutra/logic/income/income_state.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_constants.dart';
import '../../../data/models/txn_model.dart';
import '../../../router/route_name.dart';
import '../../../util/colors.dart';
import '../../widgets/showBottomModel.dart';

enum TransactionType { income, expense }

// ── Filter state ──────────────────────────────────────────────────────────────
enum _DateFilter { none, thisWeek, thisMonth, custom }
enum _AmountFilter { none, below1000, above1000, custom }

class _ActiveFilters {
  _DateFilter date;
  _AmountFilter amount;
  Set<String> categories;
  DateTime? customDateStart;
  DateTime? customDateEnd;
  double? customAmountMin;
  double? customAmountMax;

  _ActiveFilters({
    this.date = _DateFilter.none,
    this.amount = _AmountFilter.none,
    Set<String>? categories,
    this.customDateStart,
    this.customDateEnd,
    this.customAmountMin,
    this.customAmountMax,
  }) : categories = categories ?? {};

  bool get hasDate     => date != _DateFilter.none;
  bool get hasAmount   => amount != _AmountFilter.none;
  bool get hasCategory => categories.isNotEmpty;
  bool get hasAny      => hasDate || hasAmount || hasCategory;

  _ActiveFilters copyWith({
    _DateFilter? date,
    _AmountFilter? amount,
    Set<String>? categories,
    DateTime? customDateStart,
    DateTime? customDateEnd,
    double? customAmountMin,
    double? customAmountMax,
    bool clearCustomDate = false,
    bool clearCustomAmount = false,
  }) {
    return _ActiveFilters(
      date: date ?? this.date,
      amount: amount ?? this.amount,
      categories: categories ?? Set.from(this.categories),
      customDateStart: clearCustomDate ? null : (customDateStart ?? this.customDateStart),
      customDateEnd: clearCustomDate ? null : (customDateEnd ?? this.customDateEnd),
      customAmountMin: clearCustomAmount ? null : (customAmountMin ?? this.customAmountMin),
      customAmountMax: clearCustomAmount ? null : (customAmountMax ?? this.customAmountMax),
    );
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────
class ShowTransactionPage extends StatefulWidget {
  final TransactionType type;
  const ShowTransactionPage({super.key, required this.type});

  @override
  State<ShowTransactionPage> createState() => _ShowTransactionPageState();
}

class _ShowTransactionPageState extends State<ShowTransactionPage> {
  _ActiveFilters _filters = _ActiveFilters();
  bool _isFiltering = false;

  bool get _isExpense => widget.type == TransactionType.expense;
  Color get _accent   => _isExpense ? WidgetColors.red   : WidgetColors.green;
  Color get _accentBg => _isExpense ? WidgetColors.redBg : WidgetColors.greenBg;

  // ── Delete ────────────────────────────────────────────────
  void _confirmDelete(TransactionModel txn) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData
        .any((p) => p.providerId == 'google.com') ?? false;

    context.showCustomDialog(
      title: 'Delete Transaction',
      description: 'Are you sure you want to delete "${txn.category}" of '
          '₹${txn.amount.toStringAsFixed(0)}? This action cannot be undone.',
      icon: Icons.delete_outline_rounded,
      iconColor: WidgetColors.red,
      buttonText: 'Delete',
      onPressed: () {
        if (isGoogleUser) {
          _deleteTransaction(txn);
        } else {
          context.pushTo(
            RouteName.verifyPassword,
            extra: {
              'purpose': _isExpense
                  ? AppConstants.purposeDeleteExpenseTxn
                  : AppConstants.purposeDeleteIncomeTxn,
              'count': 1,
              'txnId': txn.id,
            },
          );
        }
      },
    );
  }

  void _deleteTransaction(TransactionModel txn) {
    if (_isExpense) {
      context.read<ExpenseCubit>().deleteExpense(txn.id);
    } else {
      context.read<IncomeCubit>().deleteIncome(txn.id);
    }
    context.hideLoader(context);
    context.goTo(RouteName.dashboard);
    context.showCustomDialog(
      description: 'Transaction deleted successfully',
      icon: Icons.check_circle_outline_rounded,
      iconColor: Colors.green,
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WidgetColors.page,
      appBar: context.customAppBar(
        title: _isExpense ? 'Expenses' : 'Income',
      ),
      body: SafeArea(
        child: _isExpense ? _buildExpenseContent() : _buildIncomeContent(),
      ),
    );
  }

  Widget _buildIncomeContent() {
    return BlocBuilder<IncomeCubit, IncomeState>(
      builder: (context, state) {
        if (state is IncomeLoaded) return _buildContent(state.incomes);
        return Center(
          child: SpinKitThreeBounce(color: _accent, size: context.getPercentWidth(12)),
        );
      },
    );
  }

  Widget _buildExpenseContent() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded) return _buildContent(state.expenses);
        return Center(
          child: SpinKitThreeBounce(color: _accent, size: context.getPercentWidth(12)),
        );
      },
    );
  }

  // ── Main content ──────────────────────────────────────────
  Widget _buildContent(List<TransactionModel> data) {
    final filtered = _applyFilters(data);

    return Stack(
      children: [
        Column(
          children: [
            _buildFilterBar(data),
            _buildActiveFilterTags(),
            _buildSummaryCard(filtered),
            SizedBox(height: context.getPercentHeight(0.5)),
            Expanded(child: _buildTransactionList(filtered)),
          ],
        ),
        if (_isFiltering)
          Container(
            color: Colors.black.withOpacity(0.15),
            child: Center(
              child: SpinKitThreeBounce(color: _accent, size: context.getPercentWidth(12)),
            ),
          ),
      ],
    );
  }

  // ── Filter bar ────────────────────────────────────────────
  Widget _buildFilterBar(List<TransactionModel> allData) {
    final isAll = !_filters.hasAny;

    return Container(
      color: WidgetColors.surface,
      padding: EdgeInsets.symmetric(
        vertical: context.getPercentHeight(1),
        horizontal: context.getPercentWidth(4),
      ),
      child: Row(
        children: [
          // All chip
          _buildTopChip(
            label: 'All',
            isActive: isAll,
            onTap: () {
              setState(() => _filters = _ActiveFilters());
            },
          ),
          SizedBox(width: context.getPercentWidth(2)),

          // Dates chip
          _buildTopChip(
            label: 'Dates',
            isActive: _filters.hasDate,
            onTap: () => _showDateDialog(),
          ),
          SizedBox(width: context.getPercentWidth(2)),

          // Categories chip
          _buildTopChip(
            label: 'Categories',
            isActive: _filters.hasCategory,
            onTap: () => _showCategoryDialog(allData),
          ),
          SizedBox(width: context.getPercentWidth(2)),

          // Amount chip
          _buildTopChip(
            label: 'Amount',
            isActive: _filters.hasAmount,
            onTap: () => _showAmountDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.getPercentWidth(3),
          vertical: context.getPercentHeight(0.7),
        ),
        decoration: BoxDecoration(
          color: isActive ? _accentBg : WidgetColors.chipInactive,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _accent.withOpacity(0.4) : WidgetColors.chipInactiveBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? _accent : WidgetColors.ink2,
          ),
        ),
      ),
    );
  }

  // ── Active filter tags row ────────────────────────────────
  Widget _buildActiveFilterTags() {
    final tags = <_FilterTag>[];

    // Date tag
    if (_filters.hasDate) {
      String label;
      switch (_filters.date) {
        case _DateFilter.thisWeek:  label = 'This Week'; break;
        case _DateFilter.thisMonth: label = 'This Month'; break;
        case _DateFilter.custom:
          final fmt = DateFormat('dd MMM');
          label = '${fmt.format(_filters.customDateStart!)} → ${fmt.format(_filters.customDateEnd!)}';
          break;
        default: label = '';
      }
      tags.add(_FilterTag(label: label, onRemove: () {
        setState(() => _filters = _filters.copyWith(
          date: _DateFilter.none, clearCustomDate: true,
        ));
      }));
    }

    // Category tags
    for (final cat in _filters.categories) {
      tags.add(_FilterTag(label: cat, onRemove: () {
        setState(() {
          final updated = Set<String>.from(_filters.categories)..remove(cat);
          _filters = _filters.copyWith(categories: updated);
        });
      }));
    }

    // Amount tag
    if (_filters.hasAmount) {
      String label;
      switch (_filters.amount) {
        case _AmountFilter.below1000: label = 'Below ₹1000'; break;
        case _AmountFilter.above1000: label = 'Above ₹1000'; break;
        case _AmountFilter.custom:
          label = '₹${_filters.customAmountMin!.toStringAsFixed(0)}'
              ' – ₹${_filters.customAmountMax!.toStringAsFixed(0)}';
          break;
        default: label = '';
      }
      tags.add(_FilterTag(label: label, onRemove: () {
        setState(() => _filters = _filters.copyWith(
          amount: _AmountFilter.none, clearCustomAmount: true,
        ));
      }));
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Container(
      color: WidgetColors.surface,
      padding: EdgeInsets.only(
        left: context.getPercentWidth(4),
        right: context.getPercentWidth(4),
        bottom: context.getPercentHeight(1),
      ),
      child: Wrap(
        spacing: context.getPercentWidth(2),
        runSpacing: context.getPercentHeight(0.6),
        children: tags,
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────
  Widget _buildSummaryCard(List<TransactionModel> filtered) {
    final total = filtered.fold<double>(0, (s, e) => s + e.amount);
    final label = _filters.hasAny ? 'Filtered Total' : 'Total (All time)';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.getPercentWidth(4),
        context.getPercentHeight(1.5),
        context.getPercentWidth(4),
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.getPercentWidth(5),
          vertical: context.getPercentHeight(1.8),
        ),
        decoration: BoxDecoration(
          color: _accentBg,
          borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
          border: Border.all(color: _accent.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _accent.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: context.getPercentHeight(0.3)),
                Text(
                  '₹ ${total.toStringAsFixed(0)}',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ],
            ),
            Text(
              '${filtered.length} ${filtered.length == 1 ? 'txn' : 'txns'}',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: WidgetColors.ink3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Date dialog ───────────────────────────────────────────
  Future<void> _showDateDialog() async {
    _DateFilter tempDate         = _filters.date;
    DateTime?   tempStart        = _filters.customDateStart;
    DateTime?   tempEnd          = _filters.customDateEnd;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
            ),
            title: _dialogTitle(ctx, 'Filter by Date', Icons.date_range_rounded),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogOption(
                  ctx,
                  label: 'This Week',
                  isSelected: tempDate == _DateFilter.thisWeek,
                  onTap: () => setDlg(() {
                    tempDate = tempDate == _DateFilter.thisWeek
                        ? _DateFilter.none
                        : _DateFilter.thisWeek;
                  }),
                ),
                _dialogOption(
                  ctx,
                  label: 'This Month',
                  isSelected: tempDate == _DateFilter.thisMonth,
                  onTap: () => setDlg(() {
                    tempDate = tempDate == _DateFilter.thisMonth
                        ? _DateFilter.none
                        : _DateFilter.thisMonth;
                  }),
                ),
                _dialogOption(
                  ctx,
                  label: 'Date Range',
                  isSelected: tempDate == _DateFilter.custom,
                  onTap: () async {
                    // pick start
                    final start = await showDatePicker(
                      context: ctx,
                      initialDate: tempStart ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: _datePickerTheme,
                    );
                    if (start == null) return;
                    // pick end
                    final end = await showDatePicker(
                      context: ctx,
                      initialDate: tempEnd ?? DateTime.now(),
                      firstDate: start.add(const Duration(days: 1)),
                      lastDate: DateTime.now(),
                      builder: _datePickerTheme,
                    );
                    if (end == null) return;
                    setDlg(() {
                      tempDate  = _DateFilter.custom;
                      tempStart = start;
                      tempEnd   = end;
                    });
                  },
                ),
                // Show selected range label
                if (tempDate == _DateFilter.custom &&
                    tempStart != null &&
                    tempEnd != null)
                  Padding(
                    padding: EdgeInsets.only(top: context.getPercentHeight(1)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: _accent),
                        SizedBox(width: context.getPercentWidth(1.5)),
                        Text(
                          '${DateFormat('dd MMM yyyy').format(tempStart!)} → '
                          '${DateFormat('dd MMM yyyy').format(tempEnd!)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: _accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: _dialogActions(
              ctx,
              onApply: () {
                setState(() {
                  _filters = _filters.copyWith(
                    date: tempDate,
                    customDateStart: tempStart,
                    customDateEnd: tempEnd,
                    clearCustomDate: tempDate != _DateFilter.custom,
                  );
                });
              },
              onRemove: _filters.hasDate ? () {
                setState(() => _filters = _filters.copyWith(
                  date: _DateFilter.none,
                  clearCustomDate: true,
                ));
              } : null,
            ),
          );
        },
      ),
    );
  }

  // ── Category dialog ───────────────────────────────────────
  Future<void> _showCategoryDialog(List<TransactionModel> allData) async {
    final usedCategories = allData.map((e) => e.category).toSet().toList()
      ..sort();
    Set<String> tempSelected = Set.from(_filters.categories);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
            ),
            title: _dialogTitle(ctx, 'Filter by Category', Icons.category_rounded),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: context.getPercentHeight(40),
              ),
              child: usedCategories.isEmpty
                ? Text(
                    'No categories found.',
                    style: GoogleFonts.dmSans(color: WidgetColors.ink3),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: usedCategories.map((cat) {
                        final isSelected = tempSelected.contains(cat);
                        final color = CategoryColorHelper.getColor(cat);
                        final bgColor = TransactionConstants.isCustomCategory(cat)
                            ? TransactionConstants.customCategoryBgColor(cat)
                            : (TransactionConstants.categoryIconBg[cat] ?? WidgetColors.catBgOther);
                        final emoji = TransactionConstants.isCustomCategory(cat)
                            ? '🏷️'
                            : TransactionConstants.emojiFor(cat);

                        return GestureDetector(
                          onTap: () => setDlg(() {
                            if (isSelected) {
                              tempSelected.remove(cat);
                            } else {
                              tempSelected.add(cat);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: EdgeInsets.only(
                              bottom: context.getPercentHeight(0.8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.getPercentWidth(3),
                              vertical: context.getPercentHeight(1.2),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.08) : WidgetColors.page,
                              borderRadius: BorderRadius.circular(context.getPercentWidth(3)),
                              border: Border.all(
                                color: isSelected ? color.withOpacity(0.5) : WidgetColors.chipInactiveBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: context.getPercentWidth(8),
                                  height: context.getPercentWidth(8),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(context.getPercentWidth(2)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: TextStyle(fontSize: context.getPercentWidth(4)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: context.getPercentWidth(3)),
                                Expanded(
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? color : WidgetColors.ink,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: color, 
                                    size: context.getPercentWidth(5)
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            ),
            actions: _dialogActions(
              ctx,
              onApply: () {
                setState(() {
                  _filters = _filters.copyWith(categories: tempSelected);
                });
              },
              onRemove: _filters.hasCategory ? () {
                setState(() => _filters = _filters.copyWith(categories: {}));
              } : null,
            ),
          );
        },
      ),
    );
  }

  // ── Amount dialog ─────────────────────────────────────────
  Future<void> _showAmountDialog() async {
    _AmountFilter tempAmount = _filters.amount;
    final minCtrl = TextEditingController(
      text: _filters.customAmountMin?.toStringAsFixed(0) ?? '',
    );
    final maxCtrl = TextEditingController(
      text: _filters.customAmountMax?.toStringAsFixed(0) ?? '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
            ),
            title: _dialogTitle(ctx, 'Filter by Amount', Icons.currency_rupee_rounded),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogOption(ctx,
                  label: 'Below ₹1000',
                  isSelected: tempAmount == _AmountFilter.below1000,
                  onTap: () => setDlg(() {
                    tempAmount = tempAmount == _AmountFilter.below1000
                        ? _AmountFilter.none
                        : _AmountFilter.below1000;
                  }),
                ),
                _dialogOption(ctx,
                  label: 'Above ₹1000',
                  isSelected: tempAmount == _AmountFilter.above1000,
                  onTap: () => setDlg(() {
                    tempAmount = tempAmount == _AmountFilter.above1000
                        ? _AmountFilter.none
                        : _AmountFilter.above1000;
                  }),
                ),
                _dialogOption(ctx,
                  label: 'Amount Range',
                  isSelected: tempAmount == _AmountFilter.custom,
                  onTap: () => setDlg(() {
                    tempAmount = tempAmount == _AmountFilter.custom
                        ? _AmountFilter.none
                        : _AmountFilter.custom;
                  }),
                ),
                // Range inputs
                if (tempAmount == _AmountFilter.custom) ...[
                  SizedBox(height: context.getPercentHeight(1.5)),
                  Row(
                    children: [
                      Expanded(
                        child: _amountTextField(
                          controller: minCtrl,
                          hint: 'Min ₹',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.getPercentWidth(2),
                        ),
                        child: Text('–',
                          style: GoogleFonts.sora(
                            fontWeight: FontWeight.w700,
                            color: WidgetColors.ink2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _amountTextField(
                          controller: maxCtrl,
                          hint: 'Max ₹',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: _dialogActions(
              ctx, 
              onApply: () {
                double? min;
                double? max;
                if (tempAmount == _AmountFilter.custom) {
                  min = double.tryParse(minCtrl.text.trim());
                  max = double.tryParse(maxCtrl.text.trim());
                  if (min == null || max == null || min >= max) {
                    context.showCustomDialog(
                      description: 'Please enter a valid min and max amount.',
                    );
                    return;
                  }
                }
                setState(() {
                  _filters = _filters.copyWith(
                    amount: tempAmount,
                    customAmountMin: min,
                    customAmountMax: max,
                    clearCustomAmount: tempAmount != _AmountFilter.custom,
                  );
                });
              },
              onRemove: _filters.hasAmount ? () {
                setState(() => _filters = _filters.copyWith(
                  amount: _AmountFilter.none,
                  clearCustomAmount: true,
                ));
              } : null,
            ),
          );
        },
      ),
    );
  }

  // ── Shared dialog widgets ─────────────────────────────────
  Widget _dialogTitle(BuildContext ctx, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 22),
        SizedBox(width: context.getPercentWidth(2.5)),
        Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: WidgetColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _dialogOption(
    BuildContext ctx, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(bottom: context.getPercentHeight(0.8)),
        padding: EdgeInsets.symmetric(
          horizontal: context.getPercentWidth(4),
          vertical: context.getPercentHeight(1.4),
        ),
        decoration: BoxDecoration(
          color: isSelected ? _accentBg : WidgetColors.page,
          borderRadius: BorderRadius.circular(context.getPercentWidth(3)),
          border: Border.all(
            color: isSelected ? _accent.withOpacity(0.4) : WidgetColors.chipInactiveBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _accent : WidgetColors.ink,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: _accent, size: context.getPercentWidth(5)),
          ],
        ),
      ),
    );
  }

  List<Widget> _dialogActions(
    BuildContext ctx, {
    required VoidCallback onApply,
    VoidCallback? onRemove,
  }) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remove button — only shown if filter is currently active
          if (onRemove != null)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onRemove();
              },
              child: Text(
                'Remove',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: WidgetColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          // Cancel + Apply
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: WidgetColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: context.getPercentWidth(2)),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onApply();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.getPercentWidth(5),
                    vertical: context.getPercentHeight(1.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.getPercentWidth(12)),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  Widget _amountTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.dmSans(fontSize: 14, color: WidgetColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: WidgetColors.ink3, fontSize: 13),
        filled: true,
        fillColor: WidgetColors.page,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.getPercentWidth(3),
          vertical: context.getPercentHeight(1.2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.getPercentWidth(3)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: _accent,
        onPrimary: Colors.white,
        surface: WidgetColors.surface,
      ),
    ),
    child: child!,
  );

  // ── Transaction list ──────────────────────────────────────
  Widget _buildTransactionList(List<TransactionModel> list) {
    if (list.isEmpty) return _buildEmptyState();

    final Map<String, List<TransactionModel>> grouped = {};
    for (final e in list) {
      grouped
          .putIfAbsent(DateFormat('dd MMM yyyy').format(e.date), () => [])
          .add(e);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: context.getPercentHeight(2),
        horizontal: context.getPercentWidth(4),
      ),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final dateKey = grouped.keys.elementAt(i);
        final items   = grouped[dateKey]!;
        final dayTotal = items.fold<double>(0, (s, e) => s + e.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.getPercentHeight(1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateHeader(dateKey),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: WidgetColors.ink2,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    '₹ ${dayTotal.toStringAsFixed(0)}',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((e) => _buildTransactionCard(e)),
            SizedBox(height: context.getPercentHeight(1)),
          ],
        );
      },
    );
  }

  // ── Transaction card ──────────────────────────────────────
  Widget _buildTransactionCard(TransactionModel e) {
    final isCustom = TransactionConstants.isCustomCategory(e.category);
    final bgColor  = isCustom
        ? TransactionConstants.customCategoryBgColor(e.category)
        : TransactionConstants.iconBgFor(e.category);
    final emoji    = isCustom ? '🏷️' : TransactionConstants.emojiFor(e.category);

    return GestureDetector(
      onTap: () => ShowBottomModel.open(context, e, onDelete: () => _confirmDelete(e)),
      onLongPress: () => _confirmDelete(e),
      child: Container(
        margin: EdgeInsets.only(bottom: context.getPercentHeight(1)),
        padding: EdgeInsets.symmetric(
          horizontal: context.getPercentWidth(4),
          vertical: context.getPercentHeight(1.6),
        ),
        decoration: BoxDecoration(
          color: WidgetColors.surface,
          borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
          border: Border.all(color: WidgetColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: context.getPercentWidth(11),
              height: context.getPercentHeight(5),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(context.getPercentWidth(3)),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: context.getPercentWidth(5.5)),
                ),
              ),
            ),
            SizedBox(width: context.getPercentWidth(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.category,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: WidgetColors.ink,
                    ),
                  ),
                  SizedBox(height: context.getPercentHeight(0.5)),
                  if (e.title.isNotEmpty && e.title != 'No description')
                    Text(
                      e.title.length <= 25 ? e.title : '${e.title.substring(0, 20)}...',
                      style: GoogleFonts.dmSans(fontSize: 12, color: WidgetColors.ink3),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹ ${e.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
                Text(
                  DateFormat('hh:mm a').format(e.date),
                  style: GoogleFonts.dmSans(fontSize: 11, color: WidgetColors.ink3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.getPercentWidth(16),
            height: context.getPercentHeight(16),
            decoration: BoxDecoration(color: _accentBg, shape: BoxShape.circle),
            child: Icon(Icons.inbox_rounded,
                color: _accent, size: context.getPercentWidth(7.5)),
          ),
          SizedBox(height: context.getPercentHeight(2)),
          Text('No transactions found',
            style: GoogleFonts.sora(
              fontSize: 16, fontWeight: FontWeight.w700, color: WidgetColors.ink)),
          SizedBox(height: context.getPercentHeight(0.8)),
          Text('Try adjusting your filters',
            style: GoogleFonts.dmSans(fontSize: 13, color: WidgetColors.ink3)),
        ],
      ),
    );
  }

  // ── Filter logic ──────────────────────────────────────────
  List<TransactionModel> _applyFilters(List<TransactionModel> list) {
    var result = list.where((e) {
      // Date filter
      if (_filters.hasDate) {
        final now   = DateTime.now();
        DateTime? start;
        DateTime? end;

        switch (_filters.date) {
          case _DateFilter.thisWeek:
            start = DateTime(now.year, now.month, now.day)
                .subtract(Duration(days: now.weekday - 1));
            break;
          case _DateFilter.thisMonth:
            start = DateTime(now.year, now.month, 1);
            break;
          case _DateFilter.custom:
            start = _filters.customDateStart;
            end   = _filters.customDateEnd?.add(const Duration(days: 1));
            break;
          default: break;
        }

        if (start != null && e.date.isBefore(start)) return false;
        if (end   != null && e.date.isAfter(end))    return false;
      }

      // Category filter
      if (_filters.hasCategory && !_filters.categories.contains(e.category)) {
        return false;
      }

      // Amount filter
      if (_filters.hasAmount) {
        switch (_filters.amount) {
          case _AmountFilter.below1000:
            if (e.amount >= 1000) return false;
            break;
          case _AmountFilter.above1000:
            if (e.amount <= 1000) return false;
            break;
          case _AmountFilter.custom:
            if (_filters.customAmountMin != null && e.amount < _filters.customAmountMin!) return false;
            if (_filters.customAmountMax != null && e.amount > _filters.customAmountMax!) return false;
            break;
          default: break;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  String _formatDateHeader(String dateKey) {
    final date  = DateFormat('dd MMM yyyy').parse(dateKey);
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Today · $dateKey';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday · $dateKey';
    return dateKey;
  }
}

// ── Filter tag widget ─────────────────────────────────────────────────────────
class _FilterTag extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterTag({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getPercentWidth(2.5),
        vertical: context.getPercentHeight(0.5),
      ),
      decoration: BoxDecoration(
        color: WidgetColors.indigoBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WidgetColors.indigo400.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WidgetColors.indigo500,
            ),
          ),
          SizedBox(width: context.getPercentWidth(1.5)),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: context.getPercentWidth(3.5),
              color: WidgetColors.indigo500,
            ),
          ),
        ],
      ),
    );
  }
}