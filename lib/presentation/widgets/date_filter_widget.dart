import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateFilterType { all, today, month, custom }

class DateFilterWidget extends StatefulWidget {
  final Function(DateTime? start, DateTime? end) onFilter;

  const DateFilterWidget({super.key, required this.onFilter});

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  DateFilterType selected = DateFilterType.all;

  DateTime? tempStart;
  DateTime? tempEnd;

  DateTime? appliedStart;
  DateTime? appliedEnd;

  // ================= APPLY PRESET FILTER =================

  void _applyPreset(DateFilterType type) {
    setState(() {
      selected = type;
      tempStart = null;
      tempEnd = null;
    });

    final now = DateTime.now();

    switch (type) {
      case DateFilterType.all:
        widget.onFilter(null, null);
        break;

      case DateFilterType.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        widget.onFilter(start, end);
        break;

      case DateFilterType.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        widget.onFilter(start, end);
        break;

      case DateFilterType.custom:
        // Do nothing until user presses fetch
        break;
    }
  }

  // ================= APPLY CUSTOM RANGE =================

  void _applyCustom() {
    if (tempStart == null || tempEnd == null) {
      context.showCustomDialog(description: "Please select both dates");
      return;
    }

    if (tempStart!.isAfter(tempEnd!)) {
      context.showCustomDialog(description: "Start date cannot be after End date");
      return;
    }

    setState(() {
      appliedStart = tempStart;
      appliedEnd = tempEnd;
    });

    widget.onFilter(appliedStart, appliedEnd);
  }

  // ================= DATE PICKER =================

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        tempStart = picked;
      } else {
        tempEnd = picked;
      }
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// ✅ FIXED DROPDOWN (USES YOUR COMPONENT)
        context.customDropdown<DateFilterType>(
          menuItems: DateFilterType.values,
          value: selected,
          hintText: "Select Date Filter",

          itemLabelBuilder: (type) {
            switch (type) {
              case DateFilterType.all:
                return "All";
              case DateFilterType.today:
                return "Today";
              case DateFilterType.month:
                return "This Month";
              case DateFilterType.custom:
                return "Custom Range";
            }
          },

          onChanged: (val) {
            if (val != null) _applyPreset(val);
          },
        ),

        /// CUSTOM RANGE UI
        if (selected == DateFilterType.custom) ...[
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: _dateBox("Start Date", tempStart, true)),
              const SizedBox(width: 10),
              Expanded(child: _dateBox("End Date", tempEnd, false)),
            ],
          ),

          const SizedBox(height: 15),

          context.navigationButton(
            text: "Fetch Data",
            canNavigate: true,
            height: 6,
            width: 100,
            onBtnPress: _applyCustom,
          ),
        ],
      ],
    );
  }

  // ================= DATE FIELD =================

  Widget _dateBox(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () => _pickDate(isStart),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          date == null ? label : DateFormat("dd MMM yyyy").format(date),
        ),
      ),
    );
  }
}
