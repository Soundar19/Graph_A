
import 'package:flutter/material.dart';
import 'package:grap_view/views/graph_view.dart';
import 'package:grap_view/widgets/line_chart_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Graph'),
        ),
        body: GraphView(),
      ),
    );
  }
}
