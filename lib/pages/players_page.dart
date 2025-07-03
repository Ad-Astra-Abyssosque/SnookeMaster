// lib/pages/players_page.dart
import 'package:flutter/material.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '球员页面内容',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}