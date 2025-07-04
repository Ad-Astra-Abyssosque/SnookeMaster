

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:snooke_master/models/player.dart';
import 'package:snooke_master/models/data/shot_data.dart';



enum Side {alpha, beta}

class MatchModel extends ChangeNotifier {

  int get frameScorePlayer1 => _frameScorePlayer1;
  int get frameScorePlayer2 => _frameScorePlayer2;
  int get currentScorePlayer1 => _currentScorePlayer1;
  int get currentScorePlayer2 => _currentScorePlayer2;
  int get currentGameSeconds => _currentGameSeconds;
  int get totalGameSeconds => _totalGameSeconds;
  bool get isRunning => _isRunning;



  // 大比分（帧比分）
  int _frameScorePlayer1 = 0;
  int _frameScorePlayer2 = 0;

  // 单局比分
  int _currentScorePlayer1 = 147;
  int _currentScorePlayer2 = 0;

  // 计时相关
  Timer? _timer;
  int _currentGameSeconds = 0; // 单局时长（秒）
  int _totalGameSeconds = 0;   // 总时长（秒）
  bool _isRunning = false;     // 计时器是否运行中

  List<_ScoreBoardStateSnapshot> _undoStack = [];

  // 选手相关
  List<Player> players = [];
  late Player _currentShootingPlayer;
  Side _currentSide = Side.alpha;

  // TODO 构造函数传入players

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentGameSeconds++;
      _totalGameSeconds++;
      notifyListeners();
    });
  }

  // 保存快照的方法
  void _saveSnapshot() {
    _undoStack.add(_ScoreBoardStateSnapshot(
      currentScorePlayer1: _currentScorePlayer1,
      currentScorePlayer2: _currentScorePlayer2,
      frameScorePlayer1: _frameScorePlayer1,
      frameScorePlayer2: _frameScorePlayer2,
      currentGameSeconds: _currentGameSeconds,
      totalGameSeconds: _totalGameSeconds,
    ));
  }

  // 恢复快照
  void _restoreSnapshot(_ScoreBoardStateSnapshot snapshot) {
    _currentScorePlayer1 = snapshot.currentScorePlayer1;
    _currentScorePlayer2 = snapshot.currentScorePlayer2;
    _frameScorePlayer1 = snapshot.frameScorePlayer1;
    _frameScorePlayer2 = snapshot.frameScorePlayer2;
    _currentGameSeconds = snapshot.currentGameSeconds;
    _totalGameSeconds = snapshot.totalGameSeconds;
  }

  void _saveFrameData() {
    // TODO 分别保存每位选手的对局数据
  }

  //////////////////////////////////////////////////////////////////////////////
  // BallsPanel响应
  //////////////////////////////////////////////////////////////////////////////

  void onBallPotted(BallColor ball) {
    int score = 0;
    switch (ball) {
      case BallColor.red:
        score = 1;
        break;
      case BallColor.yellow:
        score = 2;
        break;
      case BallColor.green:
        score = 3;
        break;
      case BallColor.brown:
        score = 4;
        break;
      case BallColor.blue:
        score = 5;
        break;
      case BallColor.pink:
        score = 6;
        break;
      case BallColor.black:
        score = 7;
        break;
    }
    recordShot(ball, score, ShotResult.pot);
    increaseScore(_currentSide, score);
  }

  void onBallMiss(BallColor ball) {
    recordShot(ball, 0, ShotResult.miss);
    switchPlayer();
  }

  void onFault(BallColor ball) {
    int score = 0;
    switch (ball) {
      case BallColor.red:
      case BallColor.yellow:
      case BallColor.green:
      case BallColor.brown:
        score = 4;
        break;
      case BallColor.blue:
        score = 5;
        break;
      case BallColor.pink:
        score = 6;
        break;
      case BallColor.black:
        score = 7;
        break;
    }
    recordShot(ball, score, ShotResult.fault);
    increaseScore(getOppositeSide(), score);
    switchPlayer();
  }

  //////////////////////////////////////////////////////////////////////////////
  // Player
  //////////////////////////////////////////////////////////////////////////////

  Side getOppositeSide() {
    return _currentSide == Side.alpha ? Side.beta : Side.alpha;
  }

  void switchSide() {
    _currentSide = getOppositeSide();
  }

  // Triggered by user clicking tab
  void onSwitchPlayer() {

  }

  void switchPlayer() {

  }

  void recordShot(BallColor ball, int score, ShotResult shotResult) {
    _currentShootingPlayer.addShotData(ShotData(shotTime: 10, score: score, shotResult: shotResult));
  }

  //////////////////////////////////////////////////////////////////////////////
  // 计分板行为
  //////////////////////////////////////////////////////////////////////////////

  void increaseScore(Side side, int score) {
    _saveSnapshot();
    if (side == Side.alpha) {
      _currentScorePlayer1 += score;
    }
    else {
      _currentScorePlayer2 += score;
    }
    notifyListeners();
  }

  void nextFrame(Side side) {
    _saveSnapshot();
    if (side == Side.alpha) {
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
      _startTimer();
    }
    notifyListeners();
  }

  // 开始/暂停计时
  void toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
    _isRunning = !_isRunning;
    notifyListeners();
  }

  // 重置所有数据
  void resetAll() {
    _saveSnapshot();
    _timer?.cancel();
    _frameScorePlayer1 = 0;
    _frameScorePlayer2 = 0;
    _currentScorePlayer1 = 0;
    _currentScorePlayer2 = 0;
    _currentGameSeconds = 0;
    _totalGameSeconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  void resetFrame() {
    _saveSnapshot();
    _timer?.cancel();
    _currentScorePlayer1 = 0;
    _currentScorePlayer2 = 0;
    _currentGameSeconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    var snapshot = _undoStack.removeLast();
    _restoreSnapshot(snapshot);
    notifyListeners();
  }


}


// 状态快照类
class _ScoreBoardStateSnapshot {
  final int currentScorePlayer1;
  final int currentScorePlayer2;
  final int frameScorePlayer1;
  final int frameScorePlayer2;
  final int currentGameSeconds;
  final int totalGameSeconds;
  // ... 其他需要保存的状态
  _ScoreBoardStateSnapshot({
    required this.currentScorePlayer1,
    required this.currentScorePlayer2,
    required this.frameScorePlayer1,
    required this.frameScorePlayer2,
    required this.currentGameSeconds,
    required this.totalGameSeconds,
  });
}
