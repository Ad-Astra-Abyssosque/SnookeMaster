import 'package:flutter/material.dart';
import 'dart:async';

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({super.key});

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  // 大比分（帧比分）
  int _frameScorePlayer1 = 0;
  int _frameScorePlayer2 = 0;

  // 单局比分
  int _currentScorePlayer1 = 0;
  int _currentScorePlayer2 = 0;

  // 计时相关
  Timer? _timer;
  int _currentGameSeconds = 0; // 单局时长（秒）
  int _totalGameSeconds = 0;   // 总时长（秒）
  bool _isRunning = false;     // 计时器是否运行中

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 格式化时间显示 (秒 -> mm:ss)
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  // 开始/暂停计时
  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _timer?.cancel();
      } else {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _currentGameSeconds++;
            _totalGameSeconds++;
          });
        });
      }
      _isRunning = !_isRunning;
    });
  }

  // 重置所有数据
  void _resetAll() {
    setState(() {
      _timer?.cancel();
      _frameScorePlayer1 = 0;
      _frameScorePlayer2 = 0;
      _currentScorePlayer1 = 0;
      _currentScorePlayer2 = 0;
      _currentGameSeconds = 0;
      _totalGameSeconds = 0;
      _isRunning = false;
    });
  }

  // 增加玩家得分（并处理帧结束逻辑）
  void _incrementScore(int player) {
    setState(() {
      if (player == 1) {
        _currentScorePlayer1++;
      } else {
        _currentScorePlayer2++;
      }

      // 当一局结束时（单局得分达到7分）
      if (_currentScorePlayer1 >= 7 || _currentScorePlayer2 >= 7) {
        if (_currentScorePlayer1 > _currentScorePlayer2) {
          _frameScorePlayer1++;
        } else {
          _frameScorePlayer2++;
        }

        // 重置单局数据
        _currentScorePlayer1 = 0;
        _currentScorePlayer2 = 0;
        _currentGameSeconds = 0;

        // 如果计时器在运行，继续计时（总时长继续增加）
        if (_isRunning) {
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _currentGameSeconds++;
              _totalGameSeconds++;
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 计算屏幕高度（用于设置计分板高度）
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // height: screenHeight * 0.25, // 占屏幕高度的四分之一
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 大比分显示（帧比分）
          Text(
            '$_frameScorePlayer1 : $_frameScorePlayer2',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // 单局比分按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 选手1按钮
              Expanded(
                child: GestureDetector(
                  onTap: () => _incrementScore(1),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$_currentScorePlayer1',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 中间的冒号分隔符
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // 选手2按钮
              Expanded(
                child: GestureDetector(
                  onTap: () => _incrementScore(2),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$_currentScorePlayer2',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 单局时长
          Text(
            '单局时长: ${_formatTime(_currentGameSeconds)}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),

          // 总时长
          Text(
            '比赛总时长: ${_formatTime(_totalGameSeconds)}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),

          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 开始/暂停按钮
              IconButton(
                icon: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: _toggleTimer,
                tooltip: _isRunning ? '暂停比赛' : '开始比赛',
              ),

              // 重置按钮
              IconButton(
                icon: const Icon(
                  Icons.restart_alt,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: _resetAll,
                tooltip: '重置比赛',
              ),

              // 撤销按钮
              IconButton(
                icon: const Icon(
                  Icons.undo,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  // 撤销功能预留
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('撤销功能将在后续版本实现')),
                  );
                },
                tooltip: '撤销操作',
              ),
            ],
          ),
        ],
      ),
    );
  }
}