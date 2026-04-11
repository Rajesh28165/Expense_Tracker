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
import '../../../util/colors.dart';
import '../../widgets/showBottomModel.dart';

enum TransactionType { income, expense }
enum _Filter { all, thisWeek, thisMonth, custom }

class ShowTransactionPage extends StatefulWidget {
  final TransactionType type;

  const ShowTransactionPage({
    super.key, 
    required this.type
  });

  @override
  State<ShowTransactionPage> createState() => _ShowTransactionPageState();
}

class _ShowTransactionPageState extends State<ShowTransactionPage> {
  _Filter _activeFilter = _Filter.all;
  bool _isFiltering  = false;
  DateTime? _customStart;
  DateTime? _customEnd;

  bool  get _isExpense => widget.type == TransactionType.expense;
  Color get _accent    => _isExpense ? WidgetColors.red   : WidgetColors.green;
  Color get _accentBg  => _isExpense ? WidgetColors.redBg : WidgetColors.greenBg;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WidgetColors.page,
      appBar: context.customAppBar(
        title: _isExpense ? 'Expenses' : 'Income'
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
          child: SpinKitThreeBounce(
            color: _accent, 
            size: context.getPercentWidth(12)
          )
        );
      },
    );
  }

  Widget _buildExpenseContent() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded) return _buildContent(state.expenses);
        return Center(
          child: SpinKitThreeBounce(
            color: _accent, 
            size: context.getPercentWidth(12)
          )
        );
      },
    );
  }

  // ── Main content ──────────────────────────────────────────
  Widget _buildContent(List<TransactionModel> data) {
    final filtered = _applyFilter(data);

    return Stack(
      children: [
        Column(
          children: [
            _buildFilterBar(),
            if (_activeFilter == _Filter.custom && _customStart != null && _customEnd != null)
              _buildCustomDateLabel(),
            _buildSummaryRow(data, filtered),
            SizedBox(height: context.getPercentHeight(0.5)),
            Expanded(child: _buildTransactionList(filtered)),
          ],
        ),
        if (_isFiltering)
          Container(
            color: Colors.black.withOpacity(0.15),
            child: Center(
              child: SpinKitThreeBounce(
                color: _accent, 
                size: context.getPercentWidth(12)
              )
            ),
          ),
      ],
    );
  }

  // ── Filter chips ──────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      color: WidgetColors.surface,
      padding: EdgeInsets.symmetric(
        vertical: context.getPercentHeight(1),
        horizontal: context.getPercentWidth(4)
      ),
      child: Row(
        children: [
          _buildFilterChip(_Filter.all, 'All'),
          SizedBox(width: context.getPercentWidth(2)),
          _buildFilterChip(_Filter.thisWeek, 'This week'),
          SizedBox(width: context.getPercentWidth(2)),
          _buildFilterChip(_Filter.thisMonth, 'This month'),
          SizedBox(width: context.getPercentWidth(2)),
          _buildFilterChip(_Filter.custom, 'Custom'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(_Filter filter, String label) {
    final isActive = _activeFilter == filter;
    return GestureDetector(
      onTap: () async {
        if (filter == _Filter.custom) {
          await _showCustomDateDialog(); 
          return; 
        }
        setState(() {
          _isFiltering = true; 
          _activeFilter = filter;
        });
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() => _isFiltering = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.getPercentWidth(3),
          vertical:   context.getPercentHeight(0.7),
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

  // ── Custom date dialog ────────────────────────────────────
  Future<void> _showCustomDateDialog() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.getPercentWidth(5))
          ),
          title: Row(
            children: [
              Icon(
                Icons.date_range_rounded, 
                color: _accent, 
                size: 24
              ),
              SizedBox(width: context.getPercentWidth(3)),
              Expanded(
                child: Text(
                  'Select Date Range',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700, 
                    fontSize: 18
                  )
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogDatePicker(
                label: _customStart != null
                    ? DateFormat('dd MMM yyyy').format(_customStart!)
                    : 'Select Start Date',
                hasValue: _customStart != null,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _customStart ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: _datePickerTheme,
                  );
                  if (picked != null) setDialogState(() => _customStart = picked);
                },
              ),
              SizedBox(height: context.getPercentHeight(1.6)),
              _buildDialogDatePicker(
                label: _customEnd != null
                  ? DateFormat('dd MMM yyyy').format(_customEnd!)
                  : 'Select End Date',
                hasValue: _customEnd != null,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _customEnd ?? DateTime.now(),
                    firstDate: _customStart?.add(const Duration(days: 1)) ?? DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: _datePickerTheme,
                  );
                  if (picked != null) setDialogState(() => _customEnd = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _activeFilter = _Filter.all; 
                  _customStart = null; 
                  _customEnd = null; 
                });
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                  fontSize: 14, 
                  color: WidgetColors.ink3
                )
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_customStart == null || _customEnd == null) {
                  this.context.showCustomDialog(description: 'Please select both start and end dates');
                  return;
                }
                setState(() {
                  _isFiltering = true; 
                  _activeFilter = _Filter.custom;
                });
                Future.delayed(
                  const Duration(milliseconds: 600),
                  () => setState(() => _isFiltering = false)
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.getPercentWidth(4),
                  vertical:   context.getPercentHeight(1.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.getPercentWidth(12))
                ),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.dmSans(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogDatePicker({
    required String label,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: context.getPercentHeight(1.6),
          horizontal: context.getPercentWidth(3),
        ),
        decoration: BoxDecoration(
          color: WidgetColors.surface,
          borderRadius: BorderRadius.circular(context.getPercentWidth(12)),
          border: Border.all(color: _accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded, 
              color: _accent, 
              size: 20
            ),
            SizedBox(width: context.getPercentWidth(3)),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: hasValue ? WidgetColors.ink : WidgetColors.ink3,
              ),
            ),
          ],
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

  // ── Custom date label below filter bar ────────────────────
  Widget _buildCustomDateLabel() {
    final fmt = DateFormat('dd MMM yyyy');
    return Container(
      color: WidgetColors.surface,
      padding: EdgeInsets.symmetric( 
        vertical: context.getPercentHeight(1),
        horizontal: context.getPercentWidth(4)
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range_rounded, 
            size: context.getPercentWidth(4), 
            color: _accent
          ),
          SizedBox(width: context.getPercentWidth(1.5)),
          Expanded(
            child: Text(
              '${fmt.format(_customStart!)} → ${fmt.format(_customEnd!)}',
              style: GoogleFonts.dmSans(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: _accent
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _activeFilter = _Filter.all; 
              _customStart = null; 
              _customEnd = null;
            }),
            child: Icon(
              Icons.close_rounded, 
              size: context.getPercentWidth(4), 
              color: WidgetColors.ink3
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary row ───────────────────────────────────────────
  Widget _buildSummaryRow(
    List<TransactionModel> all, 
    List<TransactionModel> filtered
  ) {
    final grandTotal = all.fold<double>(0, (s, e) => s + e.amount);

    final String rightLabel;
    final double rightAmount;
    final int    rightCount;

    if (_activeFilter == _Filter.all) {
      final month = _applyFilter(all, forceFilter: _Filter.thisMonth);
      rightLabel  = 'This month';
      rightAmount = month.fold<double>(0, (s, e) => s + e.amount);
      rightCount  = month.length;
    } else {
      rightLabel  = _activeFilter == _Filter.thisWeek  
                  ? 'This week'
                  : _activeFilter == _Filter.thisMonth 
                      ? 'This month' 
                      : 'Selected range';
      rightAmount = filtered.fold<double>(0, (s, e) => s + e.amount);
      rightCount  = filtered.length;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.getPercentWidth(4),
        context.getPercentHeight(1.5),
        context.getPercentWidth(4),
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              label: 'Total (All time)', 
              amount: grandTotal,
              count: all.length, 
              isPrimary: false,
            )
          ),
          SizedBox(width: context.getPercentWidth(3)),
          Expanded(
            child: _buildSummaryCard(
              label: rightLabel, 
              amount: rightAmount,
              count: rightCount, 
              isPrimary: true,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label, 
    required double amount,
    required int count, 
    required bool isPrimary
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getPercentWidth(4),
        vertical: context.getPercentHeight(1.5)
      ),
      decoration: BoxDecoration(
        color: isPrimary ? _accentBg : WidgetColors.surface,
        borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
        border: Border.all(
          color: isPrimary ? _accent.withOpacity(0.2) : WidgetColors.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: GoogleFonts.dmSans(
              fontSize: 11, 
              fontWeight: FontWeight.w600,
              color: isPrimary ? _accent.withOpacity(0.7) : WidgetColors.ink3,
            )
          ),
          SizedBox(height: context.getPercentHeight(0.4)),
          Text(
            '₹ ${amount.toStringAsFixed(0)}', 
            style: GoogleFonts.sora(
              fontSize: 18, 
              fontWeight: FontWeight.w800,
              color: isPrimary ? _accent : WidgetColors.ink,
            )
          ),
          SizedBox(height: context.getPercentHeight(0.2)),
          Text(
            '$count ${count == 1 ? 'transaction' : 'transactions'}',
            style: GoogleFonts.dmSans(
              fontSize: 11, 
              color: WidgetColors.ink3
            )
          ),
        ],
      ),
    );
  }

  // ── Transaction list ──────────────────────────────────────
  Widget _buildTransactionList(List<TransactionModel> list) {
    if (list.isEmpty) return _buildEmptyState();

    final Map<String, List<TransactionModel>> grouped = {};
    for (final e in list) {
      grouped.putIfAbsent(DateFormat('dd MMM yyyy').format(e.date), () => []).add(e);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(  
        vertical: context.getPercentHeight(2),
        horizontal: context.getPercentWidth(4)
      ),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final dateKey  = grouped.keys.elementAt(i);
        final items    = grouped[dateKey]!;
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
                      letterSpacing: 0.3
                    )
                  ),
                  Text(
                    '₹ ${dayTotal.toStringAsFixed(0)}', 
                    style: GoogleFonts.sora(
                      fontSize: 12, 
                      fontWeight: FontWeight.w700, 
                      color: _accent
                    )
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
    return GestureDetector(
      onTap: () => ShowBottomModel.open(context, e),
      child: Container(
        margin: EdgeInsets.only(bottom: context.getPercentHeight(1)),
        padding: EdgeInsets.symmetric(
          horizontal: context.getPercentWidth(4),
          vertical:   context.getPercentHeight(1.6),
        ),
        decoration: BoxDecoration(
          color: WidgetColors.surface,
          borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
          border: Border.all(color: WidgetColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width:  context.getPercentWidth(11),
              height: context.getPercentHeight(5),
              decoration: BoxDecoration(
                color: TransactionConstants.iconBgFor(e.category),
                borderRadius: BorderRadius.circular(context.getPercentWidth(3)),
              ),
              child: Center(
                child: Text(
                  TransactionConstants.emojiFor(e.category),
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
                      e.title.length <= 25
                          ? e.title
                          : '${e.title.substring(0, 20)}...',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: WidgetColors.ink3,
                      ),
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
                  )
                ),
                Text(
                  DateFormat('hh:mm a').format(e.date),
                  style: GoogleFonts.dmSans(
                    fontSize: 11, 
                    color: WidgetColors.ink3
                  )
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
            decoration: BoxDecoration(
              color: _accentBg, 
              shape: BoxShape.circle
            ),
            child: Icon(
              Icons.inbox_rounded, 
              color: _accent, 
              size: context.getPercentWidth(7.5)
            ),
          ),
          SizedBox(height: context.getPercentHeight(2)),
          Text(
            'No transactions found', 
            style: GoogleFonts.sora(
              fontSize: 16, 
              fontWeight: FontWeight.w700, 
              color: WidgetColors.ink,
            )
          ),
          SizedBox(height: context.getPercentHeight(0.8)),
          Text(
            'Select different dates',
            style: GoogleFonts.dmSans(
              fontSize: 13, 
              color: WidgetColors.ink3
            )
          ),
        ],
      ),
    );
  }


  List<TransactionModel> _applyFilter(List<TransactionModel> list, {_Filter? forceFilter}) {
    final filter = forceFilter ?? _activeFilter;
    final now    = DateTime.now();

    DateTime? start;
    DateTime? end;

    if (filter == _Filter.thisWeek) {
      start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    } else if (filter == _Filter.thisMonth) {
      start = DateTime(now.year, now.month, 1);
    } else if (filter == _Filter.custom) {
      start = _customStart;
      end   = _customEnd?.add(const Duration(days: 1));
    }

    return list.where((e) {
      if (start != null && e.date.isBefore(start)) return false;
      if (end   != null && e.date.isAfter(end))    return false;
      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
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