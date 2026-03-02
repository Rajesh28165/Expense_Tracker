import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/util/logger.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/data/models/income_model.dart';
import 'package:expense_tracker/logic/income/income_cubit.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/logic/expense/expense_cubit.dart';
import 'package:expense_tracker/presentation/screens/show_txn_page.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';



class AddTransactionPage extends StatefulWidget {
  final TransactionType type;

  const AddTransactionPage({
    super.key,
    required this.type,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final log = logger(AddTransactionPage);

  late String selectedCategory;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final List<String> monthName = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  /// Expense Categories
  final List<String> expenseCategories = [
    "Food",
    "Transport",
    "Shopping",
    "Entertainment",
    "Bills",
    "Health",
    "Other"
  ];

  /// Income Categories
  final List<String> incomeCategories = [
    "Salary",
    "Freelance",
    "Business",
    "Investment",
    "Gift",
    "Bonus",
    "Other"
  ];

  bool get isExpense => widget.type == TransactionType.expense;

  List<String> get categories => isExpense ? expenseCategories : incomeCategories;

  bool get canSave {
    final amount = double.tryParse(amountController.text.trim());
    return amount != null && amount > 0;
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = categories.first;
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  /// ================= DATE PICKER =================
  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  /// ================= TIME PICKER =================
  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  /// ================= SAVE TRANSACTION =================
  Future<void> _saveTransaction(BuildContext context) async {
    if (!canSave) return;

    final title = noteController.text.trim().isEmpty
      ? "No description"
      : noteController.text.trim();

    // Combine selectedDate + selectedTime into one DateTime
    final fullDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,   // ← UPDATED
      selectedTime.minute, // ← UPDATED
      0,
    );

    if (isExpense) {
      final expense = ExpenseModel(
        id: const Uuid().v4(),
        title: title,
        category: selectedCategory,
        amount: double.parse(amountController.text.trim()),
        date: fullDateTime,
      );

      await context.read<ExpenseCubit>().addExpense(expense);
    } else {
      final income = IncomeModel(
        id: const Uuid().v4(),
        title: title,
        category: selectedCategory,
        amount: double.parse(amountController.text.trim()),
        date: fullDateTime,
      );

      await context.read<IncomeCubit>().addIncome(income);
    }

    if (context.mounted) Navigator.pop(context, true);
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(
        title: isExpense ? 'Add Expense' : 'Add Income',
      ),
      body: context.gradientScreen(
        colors: const [
          Color(0xFFF5F7FA),
          Color(0xFFB8D8FF),
          Color(0xFF4A90E2),
        ],
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: context.getPercentHeight(1),
                  horizontal: context.getPercentWidth(1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _amountField(),
                    SizedBox(height: context.getPercentHeight(2)),
                    _categoryDropdown(),
                    SizedBox(height: context.getPercentHeight(2)),
                    _datePicker(context),
                    SizedBox(height: context.getPercentHeight(2)),
                    _timePicker(context), // ← NEW
                    SizedBox(height: context.getPercentHeight(2)),
                    _noteField(),
                    SizedBox(height: context.getPercentHeight(2)),
                  ],
                ),
              ),
            ),
            SafeArea(child: _saveButton(context)),
          ],
        ),
      ),
    );
  }

  /// ================= FIELDS =================
  Widget _amountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Amount"),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration(prefixIcon: Icons.currency_rupee),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    return context.customDropdown<String>(
      labelText: "Select category",
      labelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold
      ),
      borderRadius: 10,
      menuItems: categories,
      value: selectedCategory,
      onChanged: (value) {
        if (value != null) setState(() => selectedCategory = value);
      },
    );
  }

  Widget _datePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Date of transaction"),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Selected date",
                  style: TextStyle(color: Colors.black)
                ),
                Text(
                  "${selectedDate.day}-${monthName[selectedDate.month - 1]}-${selectedDate.year}",
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ← NEW WIDGET
  Widget _timePicker(BuildContext context) {
    final formattedTime = selectedTime.format(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Time of transaction"),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickTime(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Selected time",
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _noteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Note (Optional)"),
        const SizedBox(height: 8),
        TextField(
          controller: noteController,
          maxLines: 5,
          maxLength: 200,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration(prefixIcon: Icons.note),
        ),
      ],
    );
  }

  Widget _saveButton(BuildContext context) {
    return Center(
      child: context.navigationButton(
        text: isExpense ? "Save Expense" : "Save Income",
        height: 6,
        width: 100,
        canNavigate: canSave,
        onBtnPress: () => _saveTransaction(context),
      ),
    );
  }

  /// ================= COMMON HELPERS =================
  InputDecoration _inputDecoration({required IconData prefixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: Colors.black),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}