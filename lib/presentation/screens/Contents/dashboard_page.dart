import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import 'package:kharchasutra/router/route_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/app_constants.dart';
import '../../../logic/expense/expense_cubit.dart';
import '../../../logic/expense/expense_state.dart';
import '../../../logic/income/income_cubit.dart';
import '../../../logic/income/income_state.dart';
import '../../../services/services.dart';
import '../../../util/colors.dart';
import 'show_txn_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {

  Map<String, dynamic>? userData;
  late final AnimationController _balanceAnim;
  late final Animation<double> _balanceFade;

  User?  get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _balanceAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _balanceFade = CurvedAnimation(parent: _balanceAnim, curve: Curves.easeOut);
    _loadUser();
    context.read<ExpenseCubit>().loadExpenses();
    context.read<IncomeCubit>().loadIncomes();
    sessionService.resetTimer();
  }

  Future<void> _loadUser() async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted) {
      setState(() => userData = doc.data());
      _balanceAnim.forward();
    }
  }

  @override
  void dispose() {
    _balanceAnim.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (ctx, state) {
        if (state is ExpenseLoading) ctx.showLoader(text: 'Loading expenses...');
        if (state is ExpenseLoaded) { ctx.hideLoader(ctx); _balanceAnim..reset()..forward(); }
        if (state is ExpenseError)  { ctx.hideLoader(ctx); ctx.showCustomDialog(description: state.message); }
      },
      child: Scaffold(
        backgroundColor: WidgetColors.page,
        appBar: context.customAppBar(
          title: AppConstants.appName,
          showBackButton: false,
          rightWidget: _buildAvatar(context),
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────
  Widget _buildAvatar(BuildContext context) {
    final size = context.getPercentWidth(10);
    return GestureDetector(
      onTap: () => context.pushTo(RouteName.profile),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              WidgetColors.indigo600, 
              WidgetColors.indigo400
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: WidgetColors.indigo500.withOpacity(0.28), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: const Icon(
          Icons.account_circle_outlined, 
          color: Colors.white, 
          size: 22
        ),
      ),
    );
  }


  Widget _buildBody() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (ctx, expenseState) {
        final totalExpense = expenseState is ExpenseLoaded ? expenseState.totalExpense : 0.0;
        final expenseCount = expenseState is ExpenseLoaded ? expenseState.expenses.length : 0;

        return BlocBuilder<IncomeCubit, IncomeState>(
          builder: (ctx2, incomeState) {
            final totalIncome = incomeState is IncomeLoaded ? incomeState.totalIncome : 0.0;
            final incomeCount = incomeState is IncomeLoaded ? incomeState.incomes.length : 0;
            final balance = totalIncome - totalExpense;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.getPercentHeight(3),
                    horizontal: context.getPercentWidth(4.5)
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        FadeTransition(
                          opacity: _balanceFade,
                          child: _buildBalanceCard(
                            balance: balance, 
                            totalIncome: totalIncome, 
                            totalExpense: totalExpense
                          ),
                        ),
                        SizedBox(height: context.getPercentHeight(3)),
                        _buildSectionTitle('Quick Actions'),
                        SizedBox(height: context.getPercentHeight(1.5)),
                        _buildQuickActions(),
                        SizedBox(height: context.getPercentHeight(3)),
                        _buildSectionTitle('Transactions'),
                        SizedBox(height: context.getPercentHeight(1.5)),
                        _buildTransactionNavCard(
                          label: 'Expense Transactions',
                          subtitle: '$expenseCount entries · ₹ ${totalExpense.toStringAsFixed(0)} total',
                          icon: Icons.trending_down_rounded,
                          iconColor: WidgetColors.red,
                          iconBg: WidgetColors.redBg,
                          onTap: () => context.pushTo(RouteName.showTransactions, extra: TransactionType.expense),
                        ),
                        SizedBox(height: context.getPercentHeight(1.2)),
                        _buildTransactionNavCard(
                          label: 'Income Transactions',
                          subtitle: '$incomeCount entries · ₹ ${totalIncome.toStringAsFixed(0)} total',
                          icon: Icons.trending_up_rounded,
                          iconColor: WidgetColors.green,
                          iconBg: WidgetColors.greenBg,
                          onTap: () => context.pushTo(RouteName.showTransactions, extra: TransactionType.income),
                        ),
                      ]
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Section title ─────────────────────────────────────────
  Widget _buildSectionTitle(String title) => Text(
    title,
    style: GoogleFonts.sora(
      fontSize: 15, 
      fontWeight: FontWeight.w700, 
      color: WidgetColors.ink, 
      letterSpacing: 0.1
    ),
  );


  Widget _buildBalanceCard({
    required double balance, 
    required double totalIncome, 
    required double totalExpense
  }) {
    final isSurplus = balance >= 0;
    final accent    = isSurplus ? WidgetColors.balanceGreen : WidgetColors.balanceRed;

    return Container(
      decoration: BoxDecoration(
        color: WidgetColors.darkCard,
        borderRadius: BorderRadius.circular(context.getPercentWidth(7)),
        boxShadow: [
          BoxShadow(
            color: WidgetColors.darkCard.withOpacity(0.30), 
            blurRadius: 32, 
            offset: const Offset(0, 14)
          )
        ],
      ),
      child: Stack(
        children: [
          // Decorative rings
          _buildRing(
            top: -55, 
            right: -45, 
            size: 190, 
            borderWidth: 38
          ),
          _buildRing(
            bottom: -35, 
            left: -28, 
            size: 140, 
            borderWidth: 28
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.getPercentWidth(6),
              vertical: context.getPercentHeight(3)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glowing dot + label
                Row(children: [
                  _buildGlowDot(accent),
                  SizedBox(width: context.getPercentWidth(2)),
                  Text(
                    'NET BALANCE',
                    style: GoogleFonts.dmSans(
                      fontSize: 11, 
                      fontWeight: FontWeight.w600, 
                      color: WidgetColors.opacWhite, 
                      letterSpacing: 2.0
                    )
                  ),
                ]),
                SizedBox(height: context.getPercentHeight(1.8)),
                // Amount
                Text(
                  '₹ ${balance.toStringAsFixed(2)}',
                  style: GoogleFonts.sora(
                    fontSize: 38, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.white, 
                    letterSpacing: -1.2
                  )
                ),
                SizedBox(height: context.getPercentHeight(1.5)),
                // Surplus / Deficit chip
                _buildStatusChip(isSurplus, accent),
                SizedBox(height: context.getPercentHeight(2.5)),
                // Stat tiles
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        label: 'Income',  
                        amount: totalIncome,  
                        accentColor: WidgetColors.balanceGreen, 
                        icon: Icons.arrow_downward_rounded
                      )
                    ),
                    SizedBox(width: context.getPercentWidth(3)),
                    Expanded(
                      child: _buildStatTile(
                        label: 'Expense', 
                        amount: totalExpense, 
                        accentColor: WidgetColors.balanceRed, 
                        icon: Icons.arrow_upward_rounded
                      )
                    ),
                  ]
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Decorative ring ───────────────────────────────────────
  Widget _buildRing({
    double? top, 
    double? bottom, 
    double? left, 
    double? right, 
    required double size, 
    required double borderWidth
  }) {
    return Positioned(
      top: top, 
      bottom: bottom, 
      left: left, 
      right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.05), 
            width: borderWidth
          ),
        ),
      ),
    );
  }

  // ── Glowing dot ───────────────────────────────────────────
  Widget _buildGlowDot(Color color) => Container(
    width: context.getPercentWidth(1.8),
    height: context.getPercentHeight(1.8),
    decoration: BoxDecoration(
      color: color, shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.7), 
          blurRadius: 7
        )
      ],
    ),
  );

  // ── Status chip ───────────────────────────────────────────
  Widget _buildStatusChip(bool isSurplus, Color accent) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getPercentWidth(2.8), 
        vertical: context.getPercentHeight(0.6)
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Icon(
            isSurplus ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, 
            color: accent, 
            size: 12
          ),
          SizedBox(width: context.getPercentWidth(1)),
          Text(
            isSurplus ? 'Surplus' : 'Deficit',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700, 
              color: accent
            )
          ),
        ]
      ),
    );
  }

  // ── Stat tile ─────────────────────────────────────────────
  Widget _buildStatTile({
    required String label, 
    required double amount, 
    required Color accentColor, 
    required IconData icon
  }) {
    final iconSize = context.getPercentWidth(7.5);
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.getPercentWidth(3.5), 
          vertical: context.getPercentHeight(1.5)
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(context.getPercentWidth(3.5)),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: iconSize, height: iconSize,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15), 
                shape: BoxShape.circle
              ),
              child: Icon(
                icon, 
                color: accentColor, 
                size: 14
              ),
            ),
            SizedBox(width: context.getPercentWidth(2.5)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                Text(
                  label, 
                  style: GoogleFonts.dmSans(
                    fontSize: 11, 
                    fontWeight: FontWeight.w500, 
                    color: WidgetColors.opacWhite
                  )
                ),
                const SizedBox(height: 2),
                Text(
                  '₹ ${amount.toStringAsFixed(0)}', 
                  style: GoogleFonts.sora(
                    fontSize: 14, 
                    fontWeight: FontWeight.w700, 
                    color: Colors.white
                  ), 
                  overflow: TextOverflow.ellipsis
                ),
              ]
            )
          ),
        ]
      ),
    );
  }


  Widget _buildQuickActions() => Row(
    children: [
      Expanded(
        child: _buildActionCard(
          icon: Icons.remove_circle_outline_rounded, 
          label: 'Add Expense', 
          iconColor: WidgetColors.red,
          iconBg: WidgetColors.redBg,
          onTap: () => context.pushTo(RouteName.addTransactions, extra: TransactionType.expense)
        )
      ),
      SizedBox(width: context.getPercentWidth(3)),
      Expanded(
        child: _buildActionCard(
          icon: Icons.add_circle_outline_rounded,
          label: 'Add Income',
          iconColor: WidgetColors.green,
          iconBg: WidgetColors.greenBg, 
          onTap: () => context.pushTo(RouteName.addTransactions, extra: TransactionType.income)
        )
      ),
    ]
  );

  Widget _buildActionCard({
    required IconData icon, 
    required String label, 
    required Color iconColor, 
    required Color iconBg, 
    required VoidCallback onTap
  }) {
    final iconContainerSize = context.getPercentWidth(13);
    return Material(
      color: WidgetColors.surface,
      borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.getPercentHeight(2.5)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
            color: WidgetColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06), 
                blurRadius: 16, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                width: iconContainerSize, 
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: iconBg, 
                  borderRadius: BorderRadius.circular(context.getPercentWidth(3.8))
                ),
                child: Icon(
                  icon, 
                  color: iconColor, 
                  size: 26
                ),
              ),
              SizedBox(height: context.getPercentHeight(1.5)),
              Text(
                label, 
                style: GoogleFonts.dmSans(
                  fontSize: 13, 
                  fontWeight: FontWeight.w700, 
                  color: WidgetColors.ink
                )
              ),
            ]
          ),
        ),
      ),
    );
  }


  Widget _buildTransactionNavCard({
    required String label, 
    required String subtitle, 
    required IconData icon, 
    required Color iconColor, 
    required Color iconBg, 
    required VoidCallback onTap
  }) {
    final iconSize   = context.getPercentWidth(11.5);
    final chevronSize = context.getPercentWidth(7.5);
    return Material(
      color: WidgetColors.surface,
      borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.getPercentWidth(4.5), 
            vertical: context.getPercentHeight(2)
          ),
          decoration: BoxDecoration(
            color: WidgetColors.surface,
            borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06), 
                blurRadius: 16, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: iconSize, 
                height: iconSize,
                decoration: BoxDecoration(
                  color: iconBg, 
                  borderRadius: BorderRadius.circular(context.getPercentWidth(3.3))
                ),
                child: Icon(
                  icon, 
                  color: iconColor, 
                  size: 22
                ),
              ),
              SizedBox(width: context.getPercentWidth(3.5)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 15, 
                        fontWeight: FontWeight.w700, 
                        color: WidgetColors.ink
                      )
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle, 
                      style: GoogleFonts.dmSans(
                        fontSize: 12, 
                        color: WidgetColors.ink3, 
                        fontWeight: FontWeight.w500
                      )
                    ),
                  ]
                )
              ),
              Container(
                width: chevronSize, 
                height: chevronSize,
                decoration: BoxDecoration(
                  color: WidgetColors.page, 
                  borderRadius: BorderRadius.circular(context.getPercentWidth(2.3))
                ),
                child: const Icon(
                  Icons.chevron_right_rounded, 
                  color: WidgetColors.ink3, 
                  size: 18
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }

}