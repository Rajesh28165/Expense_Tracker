import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/data/models/income_model.dart';
import 'package:expense_tracker/logic/income/income_cubit.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:expense_tracker/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final log = logger(AddIncomePage);

  String selectedCategory = "Salary";
  DateTime selectedDate = DateTime.now();

  final List<String> monthName = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];


  final List<String> categories = [
    "Salary",
    "Freelance",
    "Business",
    "Investment",
    "Gift",
    "Bonus",
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

  Future<void> _saveIncome(BuildContext context) async {
    if (!canSave) return;

    final title = noteController.text.trim().isEmpty
        ? selectedCategory
        : noteController.text.trim();

    final income = IncomeModel(
      id: const Uuid().v4(),
      title: title,
      category: selectedCategory,
      amount: double.parse(amountController.text.trim()),
      date: selectedDate,
    );

    await context.read<IncomeCubit>().addIncome(income);

    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Add Income'),
      body: context.gradientScreen(
        colors: const [
          Color(0xFFF5F7FA),
          Color(0xFFD4F8E8),
          Color(0xFF2ECC71),
        ],
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: context.getPercentWidth(6),
                  right: context.getPercentWidth(6),
                  top: context.getPercentHeight(3),
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _amountField(),
                    SizedBox(height: context.getPercentHeight(4)),
                    _categoryDropdown(),
                    SizedBox(height: context.getPercentHeight(4)),
                    _datePicker(context),
                    SizedBox(height: context.getPercentHeight(4)),
                    _noteField(),
                    SizedBox(height: context.getPercentHeight(4)),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: context.getPercentHeight(2)),
                  _saveButton(context),
                  SizedBox(height: context.getPercentHeight(1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountField() {
    return TextField(
      controller: amountController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black),
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
      style: const TextStyle(color: Colors.black),
      decoration: _inputDecoration(
        label: "Note (Optional)",
        prefixIcon: Icons.note,
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return Center(
      child: context.navigationButton(
        text: "Save Income",
        height: 6,
        width: 100,
        canNavigate: canSave,
        onBtnPress: () async {
          await _saveIncome(context);
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
      labelStyle: const TextStyle(color: Colors.black),
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
}
