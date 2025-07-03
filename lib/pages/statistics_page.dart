// lib/pages/statistics_page.dart
import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '统计数据页面内容',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}