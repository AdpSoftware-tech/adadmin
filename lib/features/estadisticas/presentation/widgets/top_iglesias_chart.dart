import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TopIglesiasChart extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String valueKey; // ej: "cantidadMiembros" o "cantidadBautismos"
  final String emptyText;

  const TopIglesiasChart({
    super.key,
    required this.title,
    required this.items,
    required this.valueKey,
    this.emptyText = "No hay datos para mostrar.",
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(emptyText),
        ),
      );
    }

    // Ordenar desc y tomar top 10
    final top = [...items]..sort((a, b) => _val(b).compareTo(_val(a)));
    final top10 = top.take(10).toList();

    final maxY = top10.map(_val).fold<double>(0, (p, e) => e > p ? e : p);
    final safeMaxY = (maxY <= 0) ? 1.0 : maxY;

    // alto dinámico: evita repetir labels y que se vea aplastado
    final baseHeight = (top10.length * 52).toDouble();
    final chartHeight = baseHeight.clamp(260.0, 720.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: chartHeight,
              child: BarChart(
                BarChartData(
                  maxY:
                      safeMaxY + (safeMaxY * 0.15), // un poquito de aire arriba
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _niceInterval(safeMaxY),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = top10[group.x.toInt()];
                        final name = (item["nombre"] ?? "Iglesia").toString();
                        final v = _val(item).toInt();
                        return BarTooltipItem(
                          "$name\n$v",
                          const TextStyle(fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: _niceInterval(safeMaxY),
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 70,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= top10.length)
                            return const SizedBox.shrink();
                          final name = (top10[i]["nombre"] ?? "Iglesia")
                              .toString();

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 90,
                              child: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(top10.length, (i) {
                    final v = _val(top10[i]);
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: v,
                          width: 16,
                          borderRadius: BorderRadius.circular(6),
                          // si quieres más bonito: rodStackItems, gradient, etc.
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _val(Map<String, dynamic> item) {
    final raw = item[valueKey];
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? "0") ?? 0;
  }

  double _niceInterval(double max) {
    if (max <= 5) return 1;
    if (max <= 20) return 5;
    if (max <= 100) return 10;
    if (max <= 300) return 25;
    if (max <= 1000) return 100;
    return 250;
  }
}
