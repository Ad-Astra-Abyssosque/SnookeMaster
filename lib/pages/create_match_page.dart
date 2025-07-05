import 'package:flutter/material.dart';

class CreateMatchPage extends StatelessWidget {
  final VoidCallback onCreateSuccess;
  final VoidCallback onCancel;

  const CreateMatchPage({
    super.key,
    required this.onCreateSuccess,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建新赛事'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onCancel,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 简化的创建表单
            TextField(decoration: const InputDecoration(labelText: '赛事名称')),
            const SizedBox(height: 20),
            TextField(decoration: const InputDecoration(labelText: '赛事地点')),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 这里应该是实际的创建逻辑
                // 创建成功后回调
                onCreateSuccess();
              },
              child: const Text('创建赛事'),
            ),
          ],
        ),
      ),
    );
  }
}