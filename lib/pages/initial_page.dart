// 空赛事页面
import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  final VoidCallback onCreateMatch;

  const InitialPage({super.key, required this.onCreateMatch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('暂无进行中的赛事', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: onCreateMatch,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

