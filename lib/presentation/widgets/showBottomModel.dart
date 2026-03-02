import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/txn_model.dart';

class ShowBottomModel {
  static void open(BuildContext context, TransactionModel txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContent(transaction: txn),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final TransactionModel transaction;

  const _BottomSheetContent({required this.transaction});

  String _formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy | hh:mm a").format(date);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_type_check
    final isIncome = transaction is! dynamic ||
        (transaction.runtimeType.toString().contains("Income"));

    final amountColor = isIncome ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// DRAG HANDLE
          Container(
            width: 60,
            height: 6,
            margin: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(50),
            ),
          ),

          /// CATEGORY TITLE
          Text(
            transaction.category,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          /// AMOUNT
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "₹ ${transaction.amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// DATE CARD
          _infoCard(
            icon: Icons.calendar_today,
            title: "Date and Time",
            value: _formatDate(transaction.date),
          ),

          const SizedBox(height: 16),

          /// NOTE CARD
          _infoCard(
            icon: Icons.notes_rounded,
            title: "Note",
            value: transaction.title,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}