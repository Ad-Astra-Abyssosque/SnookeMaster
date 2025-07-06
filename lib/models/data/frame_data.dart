

import 'dart:convert';
import 'dart:math';

import 'package:snooke_master/models/data/shot_data.dart';

class FrameData {

  int shotsCount = 0;
  int potsCount = 0;
  double potSuccessRate = 0.0;
  int totalScore = 0;
  int frameTime = 0;

  int faultCount = 0;
  List<int> faultCounts = [ for(int i = 0; i < BallColor.values.length; i++) 0];


  int break_ = 0;
  int highestBreak = 0;


  List<int> ballsShotCounts = [ for(int i = 0; i < BallColor.values.length; i++) 0];
  List<int> ballsPotCounts = [ for(int i = 0; i < BallColor.values.length; i++) 0];
  List<double> potSuccessCounts = [ for(int i = 0; i < BallColor.values.length; i++) 0];

  int centuries = 0;
  int plus50 = 0;
  int plus30 = 0;
  int plus20 = 0;
  int plus10 = 0;

  double averageShotTime = 0.0;
  double maxShotTime = 0.0;

  List<ShotData> shots = [];

  FrameData();

  FrameData.fromDb(Map<String, dynamic> map) {
    // 基本类型直接映射
    shotsCount = map['shots_count'] as int;
    potsCount = map['pots_count'] as int;
    potSuccessRate = map['pot_success_rate'] as double;
    totalScore = map['total_score'] as int;
    frameTime = map['frame_time'] as int;
    faultCount = map['fault_count'] as int;
    break_ = map['break_'] as int;
    highestBreak = map['highest_break'] as int;
    centuries = map['centuries'] as int;
    plus50 = map['plus50'] as int;
    plus30 = map['plus30'] as int;
    plus20 = map['plus20'] as int;
    plus10 = map['plus10'] as int;
    averageShotTime = map['average_shot_time'] as double;
    maxShotTime = map['max_shot_time'] as double;

    // 列表类型处理 - JSON反序列化
    faultCounts = _parseJsonList(map['fault_counts']);
    ballsShotCounts = _parseJsonList(map['balls_shot_counts']);
    ballsPotCounts = _parseJsonList(map['balls_pot_counts']);
    potSuccessCounts = _parseJsonList(map['pot_success_counts'], isDouble: true);
  }

  // JSON字符串转List<int/double>
  List<T> _parseJsonList<T>(String jsonString, {bool isDouble = false}) {
    final list = jsonDecode(jsonString) as List;
    return list.map((e) => isDouble ? e.toDouble() : e as int).cast<T>().toList();
  }

  // 转换为Map用于数据库存储
  Map<String, dynamic> toDbMap() {
    return {
      'shots_count': shotsCount,
      'pots_count': potsCount,
      'pot_success_rate': potSuccessRate,
      'total_score': totalScore,
      'frame_time': frameTime,
      'fault_count': faultCount,
      'break_': break_,
      'highest_break': highestBreak,
      'centuries': centuries,
      'plus50': plus50,
      'plus30': plus30,
      'plus20': plus20,
      'plus10': plus10,
      'average_shot_time': averageShotTime,
      'max_shot_time': maxShotTime,

      // 列表类型序列化为JSON
      'fault_counts': jsonEncode(faultCounts),
      'balls_shot_counts': jsonEncode(ballsShotCounts),
      'balls_pot_counts': jsonEncode(ballsPotCounts),
      'pot_success_counts': jsonEncode(potSuccessCounts),
    };

  }

  // 拷贝构造函数
  FrameData.copy(FrameData other)
      : shotsCount = other.shotsCount,
        potsCount = other.potsCount,
        potSuccessRate = other.potSuccessRate,
        totalScore = other.totalScore,
        frameTime = other.frameTime,
        faultCount = other.faultCount,
        faultCounts = List<int>.from(other.faultCounts),
        break_ = other.break_,
        highestBreak = other.highestBreak,
        ballsShotCounts = List<int>.from(other.ballsShotCounts),
        ballsPotCounts = List<int>.from(other.ballsPotCounts),
        potSuccessCounts = List<double>.from(other.potSuccessCounts),
        centuries = other.centuries,
        plus50 = other.plus50,
        plus30 = other.plus30,
        plus20 = other.plus20,
        plus10 = other.plus10,
        averageShotTime = other.averageShotTime,
        maxShotTime = other.maxShotTime,
        shots = List.from(other.shots);
        //shots = other.shots.map((shot) => ShotData.copy(shot)).toList(); // 深拷贝每个ShotData对象

  // 或者使用拷贝方法（二选一）
  FrameData copy() {
    return FrameData.copy(this);
  }

  void addShotData(ShotData shotData) {
    shots.add(shotData);

    int ball = shotData.ball.index;


    shotsCount++;
    ballsShotCounts[ball]++;

    frameTime += shotData.shotTime;
    averageShotTime = frameTime / shotsCount;

    if (shotData.shotResult == ShotResult.pot) {
      potsCount++;
      potSuccessRate = potsCount / shotsCount;
      ballsPotCounts[ball]++;
      potSuccessCounts[ball] = ballsPotCounts[ball] / ballsShotCounts[ball];
      totalScore += shotData.score;
      // 记录上一次的break，用于记录单杆10+、20+...
      int preBreak = break_;
      break_ += shotData.score;
      highestBreak = break_ > highestBreak ? break_ : highestBreak;
      if (break_ >= 100 && preBreak < 100) centuries++;
      if (break_ >= 50 && preBreak < 50) plus50++;
      if (break_ >= 30 && preBreak < 30) plus30++;
      if (break_ >= 20 && preBreak < 20) plus20++;
      if (break_ >= 10 && preBreak < 10) plus10++;
    }
    else if (shotData.shotResult == ShotResult.fault) {
      faultCount++;
      faultCounts[ball]++;
      break_ = 0;
    }
    else {
      break_ = 0;
    }
  }

  void update(FrameData data) {
    shotsCount += data.shotsCount;
    for (int i = 0; i < ballsShotCounts.length; i++) {
      ballsShotCounts[i] += data.ballsShotCounts[i];
    }

    frameTime += data.frameTime;
    averageShotTime = shotsCount > 0 ? frameTime / shotsCount : 0.0;

    potsCount += data.potsCount;
    potSuccessRate = shotsCount > 0 ? potsCount / shotsCount : 0.0;

    for (int i = 0; i < ballsPotCounts.length; i++) {
      ballsPotCounts[i] += data.ballsPotCounts[i];
      potSuccessCounts[i] = ballsShotCounts[i] > 0 ? ballsPotCounts[i] / ballsShotCounts[i] : 0.0;
    }

    totalScore += data.totalScore;

    highestBreak = max(highestBreak, data.highestBreak);
    centuries += data.centuries;
    plus50 += data.plus50;
    plus30 += data.plus30;
    plus20 += data.plus20;
    plus10 += data.plus10;

    faultCount += data.faultCount;
    for (int i = 0; i < faultCounts.length; i++) {
      faultCounts[i] += data.faultCounts[i];
    }

  }
}