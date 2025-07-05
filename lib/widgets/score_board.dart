import 'package:flutter/material.dart';
import 'dart:async';
import 'package:snooke_master/models/match_model.dart';
import 'package:snooke_master/utils.dart';

class ScoreBoard extends StatefulWidget {
  final MatchModel match; // 接收外部传入的MatchModel

  const ScoreBoard({
    super.key,
    required this.match, // 必传参数
  });

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {

  late MatchModel matchModel; // 状态类内部保存的引用

  @override
  void initState() {
    super.initState();
    matchModel = widget.match; // 从widget属性初始化
  }

  // 格式化时间显示 (秒 -> mm:ss)
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }


  void _onScoreBtnClicked(Side side) async {
    // 弹出确认对话框
    final bool? confirm = await showConfirmDialog(
      context: context,
      title: '确认开始下一局？',
      content: '当前比分将被保存，确定继续吗？',
    );

    // 只有用户点击确认才执行
    if (confirm == true) {
      // _saveFrameData(); // 保存当前对局数据
      // _nextFrame(player);
      matchModel.nextFrame(side);
    }
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取计分板的可用高度
        final boardHeight = constraints.maxHeight;
        final boardWidth = constraints.maxWidth;

        // 根据高度计算各部分比例
        final frameScoreHeight = boardHeight * 0.15;    // 15% 高度给帧比分
        final scoreButtonsHeight = boardHeight * 0.30;   // 35% 高度给比分按钮
        final timeDisplayHeight = boardHeight * 0.20;    // 15% 高度给时间显示
        final controlButtonsHeight = boardHeight * 0.25; // 25% 高度给控制按钮

        // 计算字体大小
        final frameScoreFontSize = boardHeight * 0.1;   // 帧比分字体大小
        final scoreFontSize = boardHeight * 0.2;        // 比分字体大小
        final timeFontSize = boardHeight * 0.06;        // 时间字体大小
        final iconSize = boardHeight * 0.15;             // 图标大小

        // 计算间距
        final verticalSpacing = boardHeight * 0.02;



        return Container(
          padding: EdgeInsets.symmetric(
              vertical: boardHeight * 0.02,
              horizontal: boardWidth * 0.03,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!, width: 2),
          ),
          child: ListenableBuilder(listenable: matchModel, builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. 大比分显示（帧比分）
                SizedBox(
                  height: frameScoreHeight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${matchModel.frameScorePlayer1} : ${matchModel.frameScorePlayer2}',
                      style: TextStyle(
                        fontSize: frameScoreFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // 2. 单局比分按钮
                SizedBox(
                  height: scoreButtonsHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 选手1按钮
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onScoreBtnClicked(Side.alpha),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${matchModel.currentScorePlayer1}',
                                  style: TextStyle(
                                    fontSize: scoreFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 中间的冒号分隔符
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: boardHeight * 0.03,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: scoreFontSize * 1.2,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // 选手2按钮
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onScoreBtnClicked(Side.beta),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${matchModel.currentScorePlayer2}',
                                  style: TextStyle(
                                    fontSize: scoreFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. 时间显示区域
                SizedBox(
                  height: timeDisplayHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 单局时长
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '单局时长: ${_formatTime(matchModel.currentGameSeconds)}',
                          style: TextStyle(
                            fontSize: timeFontSize,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      // 总时长
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '比赛总时长: ${_formatTime(matchModel.totalGameSeconds)}',
                          style: TextStyle(
                            fontSize: timeFontSize,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. 控制按钮
                SizedBox(
                  height: controlButtonsHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 开始/暂停按钮
                      IconButton(
                        iconSize: iconSize,
                        icon: Icon(
                          matchModel.isRunning ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: matchModel.toggleTimer,
                        tooltip: matchModel.isRunning ? '暂停比赛' : '开始比赛',
                      ),

                      // 重置按钮
                      IconButton(
                        iconSize: iconSize,
                        icon: const Icon(
                          Icons.restart_alt,
                          color: Colors.white,
                        ),
                        onPressed: matchModel.resetAll,
                        tooltip: '重置比赛',
                      ),

                      // 撤销按钮
                      IconButton(
                        iconSize: iconSize,
                        icon: const Icon(
                          Icons.undo,
                          color: Colors.white,
                        ),
                        onPressed: matchModel.undo,
                        tooltip: '撤销操作',
                      ),
                    ],
                  ),
                ),
              ],
            );
          })
        );
      },
    );
  }
}


