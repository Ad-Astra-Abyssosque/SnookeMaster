// lib/pages/about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '关于应用页面内容',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}