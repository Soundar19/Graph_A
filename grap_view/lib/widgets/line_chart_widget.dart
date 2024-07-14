import 'dart:async';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/data_point.dart';
import '../view_models/graph_view_model.dart';


class LineChartSample8 extends HookConsumerWidget {
  const LineChartSample8({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphState = ref.watch(graphStateNotifierProvider);
    final graphStateNotifier = ref.read(graphStateNotifierProvider.notifier);
    final futureSizedPicture = useMemoized(() => loadSvg(), []);
    final snapshot = useFuture(futureSizedPicture);

    return snapshot.connectionState == ConnectionState.done
        ? GestureDetector(
      onTapUp: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset localOffset = box.globalToLocal(details.globalPosition);
        final double x = localOffset.dx / box.size.width * 24; // Assuming max x is 24
        final double y = 300 - (localOffset.dy / box.size.height * 300); // Assuming max y is 300
        graphStateNotifier.addMarker(x, y);
      },
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.70,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
                bottom: 12,
              ),
              child: LineChart(
                mainData(snapshot.data!, graphState.dataPoints, graphState.markers),
              ),
            ),
          ),
          ...graphState.markers.map((marker) {
            return Positioned(
              left: marker.x * 10, // adjust according to your scale
              top: 300 - marker.y, // adjust according to your scale
              child: GestureDetector(
                onTap: () {
                  graphStateNotifier.removeMarker(marker.x, marker.y);
                },
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 24.0,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    )
        : const CircularProgressIndicator();
  }

  Future<SizedPicture> loadSvg() async {
    const rawSvg =
        '<svg height="14" width="14" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd" transform="translate(-.000014)"><circle cx="7" cy="7" fill="#495DFF" r="7"/><path d="m7 10.9999976c1.6562389 0 2.99998569-1.34374678 2.99998569-2.99999283s-1.34374679-4.99998808-2.99998569-4.99998808c-1.6562532 0-3 3.34374203-3 4.99998808s1.3437468 2.99999283 3 2.99999283z" fill="#fff" fill-rule="nonzero"/></g></svg>';

    final pictureInfo = await vg.loadPicture( SvgAssetLoader('icon.svg'), null);
    final sizedPicture = SizedPicture(pictureInfo.picture, 2, 2);
    return sizedPicture;
  }

  LineChartData mainData(SizedPicture sizedPicture, List<DataPoint> dataPoints, List<DataPoint> markers) {
    return LineChartData(
      rangeAnnotations: RangeAnnotations(
        verticalRangeAnnotations: [
          VerticalRangeAnnotation(
            x1: 9,
            x2: 15,
            color: AppColors.contentColorRed.withOpacity(0.2),
          ),
        ],
        horizontalRangeAnnotations: [
          HorizontalRangeAnnotation(
            y1: 70,
            y2: 140,
            color: AppColors.contentColorGreen.withOpacity(0.3),
          ),
        ],
      ),
      extraLinesData: ExtraLinesData(
        verticalLines: markers.map((marker) {
          return VerticalLine(
            x: marker.x,
            color: Colors.transparent,
            sizedPicture: sizedPicture,
          );
        }).toList(),
      ),
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 50,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 6,
            reservedSize: 40,
            // getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50,
            reservedSize: 40,
            // getTitlesWidget: leftTitleWidgets,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          if (touchResponse != null && touchResponse.lineBarSpots != null && event is FlTapUpEvent) {
            // Handle touch events here, e.g., display a marker or a custom tooltip
          }
        },

        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.contentColorBlue.withOpacity(0.8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              return LineTooltipItem(
                'x: ${touchedSpot.x}, y: ${touchedSpot.y}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: AppColors.borderColor,
        ),
      ),
      minX: 0,
      maxX: 24,
      minY: 0,
      maxY: 300,
      lineBarsData: getLineBarsData(sizedPicture, dataPoints),
    );
  }

  List<LineChartBarData> getLineBarsData(SizedPicture sizedPicture, List<DataPoint> dataPoints) {
    final spots = dataPoints.map((point) => FlSpot(point.x, point.y)).toList();

    final lowData = spots.where((spot) => spot.y < 70).toList();
    final midData = spots.where((spot) => spot.y >= 70 && spot.y <= 140).toList();
    final highData = spots.where((spot) => spot.y > 140).toList();

    return [
      LineChartBarData(
        spots: lowData,
        isCurved: true,
        color: AppColors.contentColorBlue,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return true;
          },
          getDotPainter: (spot, percent, barData, index) =>
              FlDotCirclePainter(
                radius: 4,
                color: Colors.blue,
                strokeColor: Colors.blue,
              ),
        ),
      ),
      LineChartBarData(
        spots: midData,
        isCurved: true,
        color: AppColors.contentColorGreen,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return true;
          },
          getDotPainter: (spot, percent, barData, index) =>
              FlDotCirclePainter(
                radius: 4,
                color: Colors.green,
                strokeColor: Colors.green,
              ),
        ),
      ),
      LineChartBarData(
        spots: highData,
        isCurved: true,
        color: AppColors.contentColorRed,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return true;
          },
          getDotPainter: (spot, percent, barData, index) =>
              FlDotCirclePainter(
                radius: 4,
                color: Colors.red,
                strokeColor: Colors.red,
              ),
        ),
      ),
      LineChartBarData(
        spots: [
          FlSpot(3.5, 140),
          FlSpot(8.5, 110),
        ],
        isCurved: false,
        color: Colors.transparent,
        barWidth: 0,
        isStrokeCapRound: false,
        belowBarData: BarAreaData(
          show: false,
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) =>
              CustomDotPainter(sizedPicture),
        ),
      ),
    ];
  }
}

class CustomDotPainter extends FlDotPainter {
  final SizedPicture sizedPicture;

  CustomDotPainter(this.sizedPicture);

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    canvas.save();
    canvas.translate(offsetInCanvas.dx - 7, offsetInCanvas.dy - 7);
    canvas.drawPicture(sizedPicture.picture);
    canvas.restore();
  }

  @override
  Size getSize(FlSpot spot) {
    return const Size(14, 14);
  }

  @override
  Color get mainColor => Colors.transparent;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return this;
  }

  @override
  List<Object?> get props => [sizedPicture];
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}

final gradientColors = [
  Color(0xffEEF3FE),
  Color(0xffEEF3FE),
];
