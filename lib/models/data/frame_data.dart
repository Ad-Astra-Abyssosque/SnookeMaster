

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

      break_ += shotData.score;
      highestBreak = break_ > highestBreak ? break_ : highestBreak;
      if (break_ >= 100) centuries++;
      if (break_ >= 50) plus50++;
      if (break_ >= 30) plus30++;
      if (break_ >= 20) plus20++;
      if (break_ >= 10) plus10++;
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
    averageShotTime = frameTime / shotsCount;

    potsCount += data.potsCount;
    potSuccessRate = potsCount / shotsCount;

    for (int i = 0; i < ballsPotCounts.length; i++) {
      ballsPotCounts[i] += data.ballsPotCounts[i];
      potSuccessCounts[i] = ballsPotCounts[i] / ballsShotCounts[i];
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