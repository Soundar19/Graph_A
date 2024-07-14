import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/data_point.dart';

class GraphState {
  final List<DataPoint> dataPoints;
  final List<DataPoint> markers;

  GraphState({
    required this.dataPoints,
    required this.markers,
  });

  GraphState copyWith({
    List<DataPoint>? dataPoints,
    List<DataPoint>? markers,
  }) {
    return GraphState(
      dataPoints: dataPoints ?? this.dataPoints,
      markers: markers ?? this.markers,
    );
  }
}

class GraphStateNotifier extends StateNotifier<GraphState> {
  GraphStateNotifier()
      : super(GraphState(
    dataPoints: [
      DataPoint(x: 0, y: 100),
      DataPoint(x: 1, y: 120),
      DataPoint(x: 2, y: 130),
      DataPoint(x: 3, y: 140),
      DataPoint(x: 4, y: 150),
      DataPoint(x: 5, y: 160),
      DataPoint(x: 6, y: 140),
      DataPoint(x: 7, y: 125),
      DataPoint(x: 8, y: 110),
      DataPoint(x: 9, y: 95),
      DataPoint(x: 10, y: 80),
      DataPoint(x: 11, y: 75),
      DataPoint(x: 12, y: 70),
      DataPoint(x: 13, y: 65),
      DataPoint(x: 14, y: 60),
      DataPoint(x: 15, y: 55),
      DataPoint(x: 16, y: 65),
      DataPoint(x: 17, y: 80),
      DataPoint(x: 18, y: 90),
      DataPoint(x: 19, y: 90),
      DataPoint(x: 20, y: 100),
      DataPoint(x: 21, y: 130),
      DataPoint(x: 22, y: 150),
      DataPoint(x: 23, y: 160),
      DataPoint(x: 24, y: 180),
    ],
    markers: [],
  ));

  void addMarker(double x, double y) {
    state = state.copyWith(
      markers: [...state.markers, DataPoint(x: x, y: y)],
    );
  }

  void removeMarker(double x, double y) {
    state = state.copyWith(
      markers: state.markers.where((marker) => marker.x != x || marker.y != y).toList(),
    );
  }
}

final graphStateNotifierProvider = StateNotifierProvider<GraphStateNotifier, GraphState>((ref) {
  return GraphStateNotifier();
});
