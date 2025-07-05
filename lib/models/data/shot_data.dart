import '';

// 球颜色枚举
enum BallColor { red, yellow, green, brown, blue, pink, black }

enum ShotResult { pot, miss, fault}

class ShotData {
  // 本次击球时长
  final int shotTime;

  final BallColor ball;

  // 击球结果
  final ShotResult shotResult;
  // 得分
  final int score;

  ShotData({
    required this.shotTime,
    required this.ball,
    required this.score,
    required this.shotResult,
  });
}