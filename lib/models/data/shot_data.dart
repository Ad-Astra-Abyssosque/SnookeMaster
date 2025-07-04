import '';

// 球颜色枚举
enum BallColor { red, yellow, green, brown, blue, pink, black }

enum ShotResult { pot, miss, fault}

class ShotData {
  // 本次击球时长
  int shotTime;
  // 击球结果
  ShotResult shotResult;
  // 得分
  int score;

  ShotData({
    required this.shotTime,
    required this.score,
    required this.shotResult,
  });
}