import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/logic/expense/expense_cubit.dart';
import 'package:kharchasutra/logic/expense/expense_state.dart';
import 'package:kharchasutra/logic/income/income_cubit.dart';
import 'package:kharchasutra/logic/income/income_state.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import 'package:kharchasutra/router/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../util/colors.dart';
import '../../widgets/date_filter_widget.dart';
import '../../widgets/pie_chart.dart';
import 'show_txn_page.dart';


class TransactionReportPage extends StatefulWidget {
  final TransactionType type;
  const TransactionReportPage({super.key, required this.type});

  @override
  State<TransactionReportPage> createState() => _TransactionReportPageState();
}

class _TransactionReportPageState extends State<TransactionReportPage>
    with SingleTickerProviderStateMixin {

  late final AnimationController _fadeAnim;
  late final Animation<double> _fade;

  bool _isFiltering = false;

  bool get _isExpense => widget.type == TransactionType.expense;
  String get _breakdownTitle => _isExpense ? 'Category Breakdown' : 'Income Breakdown';
  String get _totalLabel => _isExpense ? 'Total Expense' : 'Total Income';
  Color get _accent => _isExpense ? WidgetColors.red : WidgetColors.green;
  Color get _accentGlow => _isExpense ? WidgetColors.redGlow : WidgetColors.greenGlow;
  Color get _accentBg => _isExpense ? WidgetColors.redBg : WidgetColors.greenBg;


  @override
  void initState() {
    super.initState();
    _fadeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOut);
    _fadeAnim.forward();
  }

  @override
  void dispose() {
    _fadeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isExpense
      ? BlocListener<ExpenseCubit, ExpenseState>(
          listener: _expenseListener,
          child: _buildScaffold(),
        )
      : BlocListener<IncomeCubit, IncomeState>(
          listener: _incomeListener,
          child: _buildScaffold(),
        );
  }

  Widget _buildScaffold() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        context.go(RouteName.dashboard);
      },
      child: Scaffold(
        backgroundColor: WidgetColors.page,
        appBar: context.customAppBar(
          title: _isExpense ? 'Expense' : 'Income',
          rightWidget: null,
          onBackPressed: () => context.go(RouteName.dashboard),
        ),
        body: SafeArea(
          child: _isExpense ? _buildExpenseContent() : _buildIncomeContent(),
        ),
      ),
    );
  }


  Widget _buildExpenseContent() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded) {
          final data = _calculateTotals(state.filteredExpenses);
          return _buildContent(context, data);
        }
        return _buildLoader();
      },
    );
  }


  Widget _buildIncomeContent() {
    return BlocBuilder<IncomeCubit, IncomeState>(
      builder: (context, state) {
        if (state is IncomeLoaded) {
          final data = _calculateTotals(state.filteredIncomes);
          return _buildContent(context, data);
        }
        return _buildLoader();
      },
    );
  }


  Widget _buildLoader() {
    return Center(
      child: SpinKitThreeBounce(
        color: _accent,
        size: context.getPercentWidth(12),
      ),
    );
  }


  Widget _buildContent(BuildContext context, Map<String, double> categoryData) {
    final total = categoryData.values.fold(0.0, (a, b) => a + b);
    final expenseCubit = context.read<ExpenseCubit>();
    final incomeCubit = context.read<IncomeCubit>();

    return Stack(
      children: [
        FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              context.getPercentWidth(4.5),
              context.getPercentHeight(2.5),
              context.getPercentWidth(4.5),
              context.getPercentHeight(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateFilter(expenseCubit, incomeCubit),
                SizedBox(height: context.getPercentHeight(2)),
                _buildTotalCard(total),
                SizedBox(height: context.getPercentHeight(2.5)),
                _buildPieChartCard(categoryData),
                SizedBox(height: context.getPercentHeight(2.5)),
                _buildCategoryList(categoryData),
              ],
            ),
          ),
        ),
        if (_isFiltering)
          Container(
            color: Colors.black.withOpacity(0.15),
            child: Center(
              child: SpinKitThreeBounce(
                color: _accent,
                size: context.getPercentWidth(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateFilter(expenseCubit, incomeCubit) {
    return DateFilterWidget(
      onFilter: (start, end) async {
        setState(() => _isFiltering = true);
        await Future.delayed(const Duration(seconds: 2));
        if (_isExpense) {
          (start == null || end == null)
            ? expenseCubit.clearFilter()
            : expenseCubit.filterExpenses(start, end);
        } else {
          (start == null || end == null)
            ? incomeCubit.clearFilter()
            : incomeCubit.filterIncomes(start, end);
        }
        setState(() => _isFiltering = false);
      },
    );
  }

  Widget _buildTotalCard(double total) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.getPercentWidth(6),
        vertical: context.getPercentHeight(2.8)
      ),
      decoration: BoxDecoration(
        color: WidgetColors.darkCard,
        borderRadius: BorderRadius.circular(context.getPercentWidth(6)),
        boxShadow: [
          BoxShadow(
            color: WidgetColors.darkCard.withOpacity(0.30),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: context.getPercentWidth(35),
              height: context.getPercentWidth(35),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 30,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: context.getPercentWidth(1.8),
                    height: context.getPercentWidth(1.8),
                    decoration: BoxDecoration(
                      color: _accentGlow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _accentGlow.withOpacity(0.7),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.getPercentWidth(2)),
                  Text(
                    _totalLabel.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: WidgetColors.opacWhite,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.getPercentHeight(1.5)),
              Text(
                '₹ ${total.toStringAsFixed(2)}',
                style: GoogleFonts.sora(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              SizedBox(height: context.getPercentHeight(1.2)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getPercentWidth(2.8),
                  vertical: context.getPercentHeight(0.6),
                ),
                decoration: BoxDecoration(
                  color: _accentGlow.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accentGlow.withOpacity(0.28)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isExpense
                        ? Icons.trending_down_rounded
                        : Icons.trending_up_rounded,
                      color: _accentGlow,
                      size: 13,
                    ),
                    SizedBox(width: context.getPercentWidth(1.2)),
                    Text(
                      _isExpense ? 'Expenses tracked' : 'Income tracked',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _accentGlow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPieChartCard(Map<String, double> categoryData) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.getPercentWidth(5)),
      decoration: BoxDecoration(
        color: WidgetColors.surface,
        borderRadius: BorderRadius.circular(context.getPercentWidth(6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribution',
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: WidgetColors.ink,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getPercentWidth(2.5),
                  vertical: context.getPercentHeight(0.5),
                ),
                decoration: BoxDecoration(
                  color: _accentBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  categoryData.length == 1
                    ? '1 category'
                    : '${categoryData.length} categories',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.getPercentHeight(2)),
          CustomPieChart(categoryData: categoryData),
        ],
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> data) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.getPercentHeight(5)),
          child: Column(
            children: [
              Container(
                width: context.getPercentWidth(16),
                height: context.getPercentWidth(16),
                decoration: BoxDecoration(
                  color: _accentBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  color: _accent,
                  size: context.getPercentWidth(7.5),
                ),
              ),
              SizedBox(height: context.getPercentHeight(1.8)),
              Text(
                'No data found',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: WidgetColors.ink,
                ),
              ),
              SizedBox(height: context.getPercentHeight(0.8)),
              Text(
                'Try adjusting the date filter',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: WidgetColors.ink3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final total = data.values.fold(0.0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _breakdownTitle,
              style: GoogleFonts.sora(
                fontSize: 15,
                color: WidgetColors.ink,
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              '${data.length} ${data.length == 1 ? 'item' : 'items'}',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: WidgetColors.ink3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: context.getPercentHeight(1.5)),

        ...data.entries.map((entry) {
          final color = CategoryColorHelper.getColor(entry.key);
          final percent = total > 0
            ? (entry.value / total * 100).toStringAsFixed(1)
            : '0.0';

          return Container(
            margin: EdgeInsets.only(bottom: context.getPercentHeight(1.2)),
            decoration: BoxDecoration(
              color: WidgetColors.surface,
              borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: context.getPercentWidth(1),
                      color: color,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.getPercentWidth(5),
                      vertical: context.getPercentHeight(1.8)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: context.getPercentWidth(9),
                          height: context.getPercentWidth(9),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: context.getPercentWidth(3),
                              height: context.getPercentWidth(3),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.getPercentWidth(3)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: WidgetColors.ink,
                                    ),
                                  ),
                                  Text(
                                    '₹ ${entry.value.toStringAsFixed(0)}',
                                    style: GoogleFonts.sora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: WidgetColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.getPercentHeight(0.8)),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: total > 0 ? entry.value / total : 0,
                                  minHeight: 5,
                                  backgroundColor: const Color(0xFFF1F1F4),
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                              SizedBox(height: context.getPercentHeight(0.5)),
                              Text(
                                '$percent% of total',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: WidgetColors.ink3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }


  void _expenseListener(BuildContext context, ExpenseState state) {
    if (state is ExpenseLoading) {
      context.showLoader(text: 'Loading...');
    }
    if (state is ExpenseLoaded || state is ExpenseError) {
      context.hideLoader(context);
    }
    if (state is ExpenseError) {
      context.showCustomDialog(description: state.message);
    }
  }

  void _incomeListener(BuildContext context, IncomeState state) {
    if (state is IncomeLoading) {
      context.showLoader(text: 'Loading...');
    }
    if (state is IncomeLoaded || state is IncomeError) {
      context.hideLoader(context);
    }
    if (state is IncomeError) {
      context.showCustomDialog(description: state.message);
    }
  }


  Map<String, double> _calculateTotals(List<dynamic> items) {
    final Map<String, double> data = {};
    for (final e in items) {
      data.update(
        e.category,
        (v) => v + e.amount,
        ifAbsent: () => e.amount,
      );
    }
    return data;
  }
}