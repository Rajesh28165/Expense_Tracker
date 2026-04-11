import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../util/colors.dart';

class CustomPieChart extends StatefulWidget {
  final Map<String, double> categoryData;

  const CustomPieChart({
    super.key,
    required this.categoryData,
  });

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryData.isEmpty) {
      return const Text("");
    }

    final total = widget.categoryData.values.fold(0.0, (a, b) => a + b);
    final entries = widget.categoryData.entries.toList();

    // Get tapped category info
    final tapped = _touchedIndex >= 0 && _touchedIndex < entries.length
        ? entries[_touchedIndex]
        : null;
    final tappedPercent = tapped != null
        ? (tapped.value / total * 100).toStringAsFixed(1)
        : null;

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 60,
              sectionsSpace: 4,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                  setState(() {
                    if (event is FlTapUpEvent &&
                        response != null &&
                        response.touchedSection != null) {
                      final tappedIdx = response.touchedSection!.touchedSectionIndex;
                      // Tap same sector again to dismiss
                      _touchedIndex = _touchedIndex == tappedIdx ? -1 : tappedIdx;
                    } else if (event is FlPointerExitEvent) {
                      // Don't dismiss on pointer exit — only on tap
                    }
                  });
                },
              ),
              sections: entries.map((entry) {
                final index = entries.indexOf(entry);
                final isTouched = index == _touchedIndex;
                final percent = (entry.value / total) * 100;
                final color = CategoryColorHelper.getColor(entry.key);

                return PieChartSectionData(
                  value: entry.value,
                  color: color,
                  // Hide title when tapped — tooltip takes over
                  title: isTouched ? '' : '${percent.toStringAsFixed(1)}%',
                  radius: isTouched ? 80 : 70, // slight pop on tap
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),

          // Centered tooltip shown when a sector is tapped
          if (tapped != null)
            GestureDetector(
              onTap: () => setState(() => _touchedIndex = -1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tapped.key,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CategoryColorHelper.getColor(tapped.key),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹ ${tapped.value.toStringAsFixed(0)}',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$tappedPercent% of total',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}