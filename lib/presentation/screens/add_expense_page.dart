import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/logic/expense/expense_cubit.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_constants.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    "Food",
    "Transport",
    "Shopping",
    "Entertainment",
    "Bills",
    "Health",
    "Other",
  ];

  bool get canSave =>
      amountController.text.isNotEmpty &&
      double.tryParse(amountController.text) != null;

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

  void _saveExpense(BuildContext context) {
    context.read<ExpenseCubit>().addExpense(
      ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: selectedCategory,
        amount: double.parse(amountController.text),
        category: selectedCategory,
        type: ExpenseType.expense,
        date: selectedDate,
      ),
    );

    context.showCustomDialog(
      description: "Expense added successfully",
    );

    // Navigator.pop(context);
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

  // ================= HEADER =================
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

  // ================= AMOUNT =================
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

  // ================= CATEGORY =================
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
          dropdownColor: Colors.black,
          value: selectedCategory,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          items: categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => selectedCategory = value!);
          },
        ),
      ),
    );
  }

  // ================= DATE =================
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
            const Text(
              "Date",
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ================= NOTE =================
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

  // ================= SAVE =================
  Widget _saveButton(BuildContext context) {
    return Center(
      child: context.navigationButton(
        text: "Save Expense",
        height: 6,
        width: 100,
        canNavigate: canSave,
        onBtnPress: () => _saveExpense(context),
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
