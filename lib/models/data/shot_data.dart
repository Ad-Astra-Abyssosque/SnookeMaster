

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

  final String recordTime ;

  final int frameIndex;

  ShotData({
    required this.shotTime,
    required this.ball,
    required this.score,
    required this.shotResult,
    required this.frameIndex,
    String? recordTime,
  }) : recordTime = recordTime ?? DateTime.now().toIso8601String();

  factory ShotData.fromDb(Map<String, dynamic> map) {
    return ShotData(
      shotTime: map['shot_time'] as int,
      ball: _parseBallColor(map['ball'] as String),
      shotResult: _parseShotResult(map['shot_result'] as String),
      score: map['score'] as int,
      recordTime: map['record_time'] as String,
      frameIndex: map['frame_index'] as int,
    );
  }

  Map<String, dynamic> toDbMap(String matchUuid, String playerUuid) {
    return {
      'match_uuid': matchUuid,
      'player_uuid': playerUuid,
      'record_time': recordTime,
      'shot_time': shotTime,
      'ball': _ballColorToString(ball),
      'shot_result': _shotResultToString(shotResult),
      'score': score,
      'frame_index': frameIndex,
    };
  }

  // 枚举转换辅助方法
  static BallColor _parseBallColor(String value) {
    switch (value) {
      case 'red': return BallColor.red;
      case 'yellow': return BallColor.yellow;
      case 'green': return BallColor.green;
      case 'brown': return BallColor.brown;
      case 'blue': return BallColor.blue;
      case 'pink': return BallColor.pink;
      case 'black': return BallColor.black;
      default: throw ArgumentError('Invalid ball color: $value');
    }
  }

  static String _ballColorToString(BallColor color) {
    return color.toString().split('.').last;
  }

  static ShotResult _parseShotResult(String value) {
    switch (value) {
      case 'pot': return ShotResult.pot;
      case 'miss': return ShotResult.miss;
      case 'fault': return ShotResult.fault;
      default: throw ArgumentError('Invalid shot result: $value');
    }
  }

  static String _shotResultToString(ShotResult result) {
    return result.toString().split('.').last;
  }
}