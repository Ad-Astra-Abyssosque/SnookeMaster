

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:snooke_master/models/player.dart';
import 'package:snooke_master/models/data/shot_data.dart';

import 'data/match_data.dart';



enum Side {alpha, beta}

class MatchModel extends ChangeNotifier {

  int get frameScorePlayer1 => _frameScorePlayer1;
  int get frameScorePlayer2 => _frameScorePlayer2;
  int get currentScorePlayer1 => _currentScorePlayer1;
  int get currentScorePlayer2 => _currentScorePlayer2;
  int get currentGameSeconds => _currentGameSeconds;
  int get totalGameSeconds => _totalGameSeconds;
  bool get isRunning => _isRunning;
  int get currentIndex => _currentIndex;

  Player? get currentShootingPlayer {
    if (_currentIndex >= 0 && _currentIndex < players.length) {
      return players[_currentIndex];
    }
    return null;
  }

  // 大比分（帧比分）
  bool _firstStart = true;
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

  final List<_ScoreBoardStateSnapshot> _undoStack = [];

  // 选手相关
  List<Player> players;
  Side _currentSide = Side.alpha;
  int _currentIndex = 0;

  // 构造函数传入players
  MatchModel({
    required this.players
  });

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentGameSeconds++;
      _totalGameSeconds++;
      notifyListeners();
    });
  }

  Map<String, MatchData> _createPlayerDataBackup() {
    return {
      for (final p in players)
        if (p.currentMatchData != null) // 显式检查
          p.id: MatchData.copy(p.currentMatchData!)
    };
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
      playerDataBackup: _createPlayerDataBackup(),
      players: List.from(players),  // 注意：需要创建一个新的列表，否则快照会持有对原列表的引用！在updatePlayers时先clear原列表就会导致问题！
      currentIndex: _currentIndex,
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

    updatePlayers(snapshot.players, snapshot.currentIndex, false);

    // restore every player's currentMatchData
    for (final player in players) {
      final backupData = snapshot.playerDataBackup[player.id];
      if (backupData != null) {
        player.currentMatchData = backupData;
      } else {
        // 如果没有备份数据，则初始化为新对象（根据业务需求决定）
        player.currentMatchData = MatchData();
      }
    }
    debugPrint('after restore snapshot');
  }

  void _saveFrameData(Side winSide) {
    for (int i = 0; i < players.length; i++) {
      if (players[i].currentSide == winSide) {
        players[i].onFrameEnd(true);
      }
      else {
        players[i].onFrameEnd(false);
      }
    }
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
    _recordShot(ball, score, ShotResult.pot);
  }

  void onBallMiss(BallColor ball) {
    _recordShot(ball, 0, ShotResult.miss);
    _switchToNextPlayer();
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
    _recordShot(ball, score, ShotResult.fault);
    _switchToNextPlayer();
  }

  //////////////////////////////////////////////////////////////////////////////
  // Player
  //////////////////////////////////////////////////////////////////////////////

  // 程序控制切换Tab
  void switchToPlayer(int index) {
    debugPrint('MatchModel switchToPlayer: index $index, _currentIndex: $_currentIndex');
    if (index == _currentIndex) return;
    if (index >= 0 && index < players.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // 程序控制切换到下一个球员
  void _switchToNextPlayer() {
    _currentIndex = (_currentIndex + 1) % players.length;
    _currentSide = currentShootingPlayer!.currentSide!;
    notifyListeners();
  }

  // 更新球员列表（拖动排序时使用）
  void updatePlayers(List<Player> newPlayers, int newIndex, [bool notify = true]) {
    players
      ..clear()
      ..addAll(newPlayers);
    _currentIndex = newIndex;
    debugPrint('MatchModel updatePlayers: _currentIndex: $_currentIndex');
    if (notify) {
      notifyListeners();
    }
  }

  Side getOppositeSide() {
    return _currentSide == Side.alpha ? Side.beta : Side.alpha;
  }

  void _recordShot(BallColor ball, int score, ShotResult shotResult) {
    switch (shotResult) {
      case ShotResult.pot: {
        increaseScore(_currentSide, score);
        break;
      }
      case ShotResult.miss: {
        increaseScore(_currentSide, score);
        break;
      }
      case ShotResult.fault: {
        increaseScore(getOppositeSide(), score);
        break;
      }
    }
    currentShootingPlayer?.addShotData(ShotData(shotTime: 10, ball: ball, score: score, shotResult: shotResult));
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
    _saveFrameData(side);
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
    if (_firstStart) {
      _firstStart = false;
      for (int i = 0; i < players.length; i++) {
        players[i].onMatchStart();
      }
    }
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
    for (int i = 0; i < players.length; i++) {
      players[i].onMatchReset();
    }
    notifyListeners();
  }

  void resetFrame() {
    _saveSnapshot();
    _timer?.cancel();
    _currentScorePlayer1 = 0;
    _currentScorePlayer2 = 0;
    _currentGameSeconds = 0;
    _isRunning = false;
    for (int i = 0; i < players.length; i++) {
      players[i].onFrameReset();
    }
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    var snapshot = _undoStack.removeLast();
    _restoreSnapshot(snapshot);
    notifyListeners();
  }

  void stopMatch(bool save) {

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
  final Map<String, MatchData> playerDataBackup;
  final List<Player> players;
  final int currentIndex;
  // ... 其他需要保存的状态
  _ScoreBoardStateSnapshot({
    required this.currentScorePlayer1,
    required this.currentScorePlayer2,
    required this.frameScorePlayer1,
    required this.frameScorePlayer2,
    required this.currentGameSeconds,
    required this.totalGameSeconds,
    required this.playerDataBackup,
    required this.players,
    required this.currentIndex,
  });
}
