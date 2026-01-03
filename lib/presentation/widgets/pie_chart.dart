import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../util/colors.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const ExpensePieChart({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const Text(
        "No data available",
        style: TextStyle(color: Colors.white70),
      );
    }

    final total = categoryData.values.fold(0.0, (a, b) => a + b);

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 50,
          sectionsSpace: 4,
          sections: categoryData.entries.map((entry) {
            final percent = (entry.value / total) * 100;
            final color = CategoryColorHelper.getColor(entry.key);

            return PieChartSectionData(
              value: entry.value,
              color: color,
              title: "${percent.toStringAsFixed(1)}%",
              radius: 70,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
