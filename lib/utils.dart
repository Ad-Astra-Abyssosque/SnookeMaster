
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 显示一个确认弹窗，返回用户点击结果（true: 确认, false: 取消, null: 弹窗被关闭）
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: const Text('确认'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
}
