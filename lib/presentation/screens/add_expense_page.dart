import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/logic/expense/expense_cubit.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:expense_tracker/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_constants.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final log = logger(AddExpensePage);

  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();

  final List<String> monthName = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  final List<String> categories = [
    "Food",
    "Transport",
    "Shopping",
    "Entertainment",
    "Bills",
    "Health",
    "Other",
  ];

  bool get canSave {
    final amount = double.tryParse(amountController.text.trim());
    return amount != null && amount > 0;
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

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

  Future<void> _saveExpense(BuildContext context) async {
    log.d("started");
    if (!canSave) return;

    final title = noteController.text.trim().isEmpty
        ? selectedCategory
        : noteController.text.trim();

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: title,
      category: selectedCategory,
      amount: double.parse(amountController.text.trim()),
      date: selectedDate,
    );

    log.d('Expense amount is ${expense.amount}');

    // ✅ CALL ONLY ONCE
    await context.read<ExpenseCubit>().addExpense(expense);

    log.d('Expense saved successfully');

    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          context.imageContainer(
            imagePath: ImagePathConstants.space,
            height: context.getPercentHeight(100),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.getPercentWidth(6),
                vertical: context.getPercentHeight(3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  SizedBox(height: context.getPercentHeight(4)),
                  _amountField(),
                  SizedBox(height: context.getPercentHeight(3)),
                  _categoryDropdown(),
                  SizedBox(height: context.getPercentHeight(3)),
                  _datePicker(context),
                  SizedBox(height: context.getPercentHeight(3)),
                  _noteField(),
                  SizedBox(height: context.getPercentHeight(5)),
                  _saveButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        context.header(title: "Add Expense", color: Colors.cyan),
      ],
    );
  }

  Widget _amountField() {
    return TextField(
      controller: amountController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(
        label: "Amount",
        prefixIcon: Icons.currency_rupee,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _categoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          dropdownColor: Colors.black,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedCategory = value);
            }
          },
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return InkWell(
      onTap: () => _pickDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Select Date", style: TextStyle(color: Colors.white70)),
            Text(
              "${selectedDate.day}-${monthName[selectedDate.month - 1]}-${selectedDate.year}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteField() {
    return TextField(
      controller: noteController,
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(
        label: "Note (Optional)",
        prefixIcon: Icons.note,
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return Center(
      child: context.navigationButton(
        text: "Save Expense",
        height: 6,
        width: 100,
        canNavigate: canSave,
        onBtnPress: () async {
          await _saveExpense(context);
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(prefixIcon, color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan),
      ),
    );
  }
}
