import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/data/models/income_model.dart';
import 'package:kharchasutra/logic/income/income_cubit.dart';
import 'package:kharchasutra/data/models/expense_model.dart';
import 'package:kharchasutra/logic/expense/expense_cubit.dart';
import 'package:kharchasutra/presentation/screens/Contents/show_txn_page.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_constants.dart';
import '../../../util/colors.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionType type;
  const AddTransactionPage({super.key, required this.type});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController   = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();

  late String _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late TransactionType _activeType;

  bool get _isExpense  => _activeType == TransactionType.expense;
  Color get _accent    => _isExpense ? WidgetColors.red   : WidgetColors.green;
  Color get _accentBg  => _isExpense ? WidgetColors.redBg : WidgetColors.greenBg;

  List<Map<String, String>> get _categories =>
      _isExpense
          ? TransactionConstants.expenseCategories
          : TransactionConstants.incomeCategories;

  String get _effectiveCategory {
    if (_selectedCategory == 'Other') {
      final custom = _customCategoryController.text.trim();
      return custom.isEmpty ? 'Other' : custom;
    }
    return _selectedCategory;
  }

  bool get _canSave {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return false;
    // If Other is selected, custom name must be filled
    if (_selectedCategory == 'Other' && _customCategoryController.text.trim().isEmpty) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _activeType = widget.type;
    _selectedCategory = _categories.first['label']!;
    _amountController.addListener(() => setState(() {}));
    _noteController.addListener(() => setState(() {}));
    _customCategoryController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _saveTransaction() async {
    if (!_canSave) return;

    final title = _noteController.text.trim().isEmpty
        ? 'No description'
        : _noteController.text.trim();

    final fullDateTime = DateTime(
      _selectedDate.year, 
      _selectedDate.month, 
      _selectedDate.day,
      _selectedTime.hour, 
      _selectedTime.minute, 
      0
    );

    if (_isExpense) {
      await context.read<ExpenseCubit>().addExpense(ExpenseModel(
        id: const Uuid().v4(),
        title: title,
        category: _effectiveCategory,
        amount: double.parse(_amountController.text.trim()),
        date: fullDateTime,
      ));
    } else {
      await context.read<IncomeCubit>().addIncome(IncomeModel(
        id: const Uuid().v4(),
        title: title,
        category: _effectiveCategory,
        amount: double.parse(_amountController.text.trim()),
        date: fullDateTime,
      ));
    }

    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WidgetColors.page,
      appBar: context.customAppBar(
        title: _isExpense ? 'Add Expense' : 'Add Income'
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: context.getPercentWidth(4),
                  vertical:   context.getPercentHeight(2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Amount'),
                    SizedBox(height: context.getPercentHeight(1)),
                    _buildAmountSection(),

                    SizedBox(height: context.getPercentHeight(2)),

                    _buildSectionLabel('Category'),
                    SizedBox(height: context.getPercentHeight(1)),
                    _buildCategoryChips(),

                    if (_selectedCategory == 'Other') ...[
                      SizedBox(height: context.getPercentHeight(1.5)),
                      _buildCustomCategoryField(),
                    ],

                    SizedBox(height: context.getPercentHeight(2)),

                    _buildSectionLabel('Date and Time'),
                    SizedBox(height: context.getPercentHeight(1)),
                    _buildDateTimeCard(),

                    SizedBox(height: context.getPercentHeight(2)),

                    _buildSectionLabel('Note'),
                    SizedBox(height: context.getPercentHeight(1)),
                    _buildNoteField(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_noteController.text.length}/200',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.dmSans(
                          color: WidgetColors.ink3, 
                          fontSize: 11
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ── Amount section ────────────────────────────────────────
  Widget _buildAmountSection() {
    final hasAmount = _amountController.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.getPercentWidth(5)),
      decoration: BoxDecoration(
        color: WidgetColors.surface,
        borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
        boxShadow: [
          BoxShadow(
            color: WidgetColors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹',
                style: GoogleFonts.sora(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: WidgetColors.ink3,
                  height: 1.4,
                ),
              ),
              SizedBox(width: context.getPercentWidth(2)),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.sora(
                    fontSize: 48, 
                    fontWeight: FontWeight.w800,
                    color: WidgetColors.ink, 
                    letterSpacing: -2, 
                    height: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.sora(
                      fontSize: 48, 
                      fontWeight: FontWeight.w800,
                      color: WidgetColors.dividerColor, 
                      letterSpacing: -2, 
                      height: 1,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),

          // Underline
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          SizedBox(height: context.getPercentHeight(1)),
          Text(
            hasAmount ? 'Amount entered' : 'Enter amount',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: hasAmount ? _accent : WidgetColors.ink3,
              fontWeight: hasAmount ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────
  Widget _buildSectionLabel(String text) => Text(
    text.toUpperCase(),
    style: GoogleFonts.dmSans(
      fontSize: 11, 
      fontWeight: FontWeight.w700,
      color: WidgetColors.ink3, 
      letterSpacing: 1.0,
    ),
  );

  // ── Category chips (grid) ─────────────────────────────────
  Widget _buildCategoryChips() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.5,
      ),
      itemBuilder: (_, i) {
        final label = _categories[i]['label']!;
        final icon = _categories[i]['icon']!;
        final isSelected = _selectedCategory == label;

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: context.getPercentWidth(3.5)),
            decoration: BoxDecoration(
              color: isSelected ? _accentBg : WidgetColors.surface,
              borderRadius: BorderRadius.circular(context.getPercentHeight(2.5)),
              border: Border.all(
                color: isSelected ? _accent.withOpacity(0.4) : WidgetColors.chipInactiveBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  icon, 
                  style: const TextStyle(fontSize: 14)
                ),
                SizedBox(width: context.getPercentWidth(1.5)),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? _accent : WidgetColors.ink2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Custom Category Name'),
        SizedBox(height: context.getPercentHeight(1)),
        Container(
          decoration: BoxDecoration(
            color: WidgetColors.surface,
            borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
            boxShadow: [
              BoxShadow(
                color: WidgetColors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _customCategoryController,
            maxLength: 30,
            style: GoogleFonts.dmSans(fontSize: 14, color: WidgetColors.ink),
            decoration: InputDecoration(
              hintText: 'e.g. Rent, Gym, Pet...',
              hintStyle: GoogleFonts.dmSans(color: WidgetColors.ink3),
              counterText: '',
              filled: true,
              fillColor: WidgetColors.surface,
              contentPadding: EdgeInsets.all(context.getPercentWidth(4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
                borderSide: BorderSide(
                  color: _accent.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Date + time card ──────────────────────────────────────
  Widget _buildDateTimeCard() {
    return Container(
      decoration: BoxDecoration(
        color: WidgetColors.surface,
        borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
        boxShadow: [
          BoxShadow(
            color: WidgetColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFieldRow(
            icon:        Icons.calendar_today_rounded,
            iconBg:      WidgetColors.dateIconBg,
            iconColor:   WidgetColors.dateIconFg,
            label:       'Date',
            value:       '${_selectedDate.day} ${TransactionConstants.monthName(_selectedDate.month)} ${_selectedDate.year}',
            onTap:       _pickDate,
            showDivider: true,
          ),
          _buildFieldRow(
            icon:        Icons.access_time_rounded,
            iconBg:      WidgetColors.timeIconBg,
            iconColor:   WidgetColors.timeIconFg,
            label:       'Time',
            value:       _selectedTime.format(context),
            onTap:       _pickTime,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.getPercentWidth(4),
              vertical: context.getPercentHeight(1.8),
            ),
            child: Row(
              children: [
                Container(
                  width: context.getPercentWidth(9),
                  height: context.getPercentHeight(4),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(context.getPercentWidth(2.5)),
                  ),
                  child: Icon(
                    icon, 
                    color: iconColor, 
                    size: context.getPercentWidth(4.5)
                  ),
                ),
                SizedBox(width: context.getPercentWidth(3)),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 14, 
                      fontWeight: FontWeight.w500, 
                      color: WidgetColors.ink2
                    ),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.sora(
                    fontSize: 14, 
                    fontWeight: FontWeight.w700, 
                    color: WidgetColors.ink
                  ),
                ),
                SizedBox(width: context.getPercentWidth(1.5)),
                Icon(
                  Icons.chevron_right_rounded, 
                  color: WidgetColors.ink3, 
                  size: context.getPercentWidth(5)
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1, 
            indent: context.getPercentWidth(17), 
            color: WidgetColors.page
          ),
      ],
    );
  }

  // ── Note field ────────────────────────────────────────────
  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: WidgetColors.surface,
        borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
        boxShadow: [
          BoxShadow(
            color: WidgetColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 4,
        maxLength: 200,
        style: GoogleFonts.dmSans(fontSize: 14, color: WidgetColors.ink),
        decoration: InputDecoration(
          hintText: 'Add a note (optional)...',
          hintStyle: GoogleFonts.dmSans(color: WidgetColors.ink3),
          counterText: "",
          filled: true,
          fillColor: WidgetColors.surface,
          contentPadding: EdgeInsets.all(context.getPercentWidth(4)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getPercentWidth(4)),
            borderSide: BorderSide(color: _accent.withOpacity(0.4), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return context.navigationButton(
      text: _isExpense ? 'Save Expense' : 'Save Income',
      leftSpace: 5,
      rightSpace: 5,
      aboveSpace: 3.5,
      belowSpace: 3.5,
      canNavigate: _canSave,
      onBtnPress: _saveTransaction,     
    );
  }
}