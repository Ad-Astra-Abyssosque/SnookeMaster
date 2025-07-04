import 'package:snooke_master/models/match_model.dart';
import 'package:snooke_master/models/data/shot_data.dart';
import 'package:flutter/material.dart';

class BallsPanel extends StatelessWidget {
  final MatchModel matchModel;

  const BallsPanel({Key? key, required this.matchModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double outerPadding = screenSize.width * 0.02; // 屏幕边缘padding
    return LayoutBuilder(
        builder: (context, constraints) {

          final int ballsNum = BallColor.values.length;
          final double maxHeight = screenSize.height * 0.2;
          // 根据屏幕高度计算球的半径 r = max_height / 纵向单位数
          // 纵向单位数 = 8
          final double unitDefinedByHeight = maxHeight / 8;

          // 根据屏幕宽度计算球的半径 r = width / 横向单位数
          // 横向单位数 = 2 * n + (n + 1) => 3n + 1;   (n = 7)
          final double unitDefinedByWidth = constraints.maxWidth / (ballsNum * 3 + 1);
          double unit = unitDefinedByWidth;
          debugPrint('unit: $unit, actual height: ${unit * 8}');
          debugPrint('max height: $maxHeight');
          debugPrint('test: ${unit * 8 / screenSize.height}');

          // 如果屏幕很宽，导致球的大小过大，进而导致panel的高度超过屏幕的1/4，则使用unitDefinedByHeight
          if (unit * 8 > maxHeight) {
            debugPrint('Screen is too wide, using unit determined by height');
            unit = unitDefinedByHeight;
          }

          return Container(
            // padding: EdgeInsets.all(innerPadding),
            // decoration: BoxDecoration(
            //   color: Colors.grey[900],
            //   borderRadius: BorderRadius.circular(12),
            //   border: Border.all(color: Colors.grey[700]!, width: 2),
            // ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第一行：实心球按钮
                _buildBallRow(
                  context: context,
                  unit: unit,
                  isSolid: true,
                  onTap: (color) => matchModel.onBallPotted(color),
                ),
                // SizedBox(height: innerPadding),
                // 第二行：虚线球按钮
                _buildBallRow(
                  context: context,
                  unit: unit,
                  isSolid: false,
                  onTap: (color) => matchModel.onBallMiss(color),
                  onLongPress: (color) => matchModel.onFault(color),
                ),
              ],
            ),
          );
        }
    );
  }

  // 构建球按钮行
  Widget _buildBallRow({
    required BuildContext context,
    required double unit,
    required bool isSolid,
    required Function(BallColor) onTap,
    Function(BallColor)? onLongPress,
  }) {
    final ballColors = BallColor.values;
    final ballCount = BallColor.values.length;
    final buttonSize = unit * 2;

    return SizedBox(
      height: unit * 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ballColors.map((color) {
          return _BallButton(
            size: buttonSize,
            color: _getBallColor(color),
            isSolid: isSolid,
            onTap: () => onTap(color),
            onLongPress: onLongPress != null ? () => onLongPress(color) : null,
          );
        }).toList(),
      ),
    );
  }

  // 获取球的实际颜色
  Color _getBallColor(BallColor color) {
    switch (color) {
      case BallColor.red: return Colors.red;
      case BallColor.yellow: return Colors.yellow;
      case BallColor.green: return Colors.green;
      case BallColor.brown: return Colors.brown;
      case BallColor.blue: return Colors.blue;
      case BallColor.pink: return Colors.pink;
      case BallColor.black: return Colors.black;
    }
  }
}

// 球按钮组件
class _BallButton extends StatelessWidget {
  final double size;
  final Color color;
  final bool isSolid;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _BallButton({
    required this.size,
    required this.color,
    required this.isSolid,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSolid ? color : color.withOpacity(0.3),
          shape: BoxShape.circle,
          border: isSolid
              ? null
              : Border.all(
            color: color,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}