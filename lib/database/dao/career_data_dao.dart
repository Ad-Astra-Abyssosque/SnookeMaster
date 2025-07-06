
import 'dart:ui';
import 'package:snooke_master/models/data/frame_data.dart';
import '../../models/data/career_data.dart';
import '../../models/player.dart';
import 'base_dao.dart';

class CareerDataDao extends BaseDao<CareerData> {
  @override
  String get tableName => 'career_data';

  @override
  String get primaryKey => 'player_uuid';

  String playerUuid;

  CareerDataDao({
    required this.playerUuid,
  });

  @override
  CareerData fromMap(Map<String, dynamic> map) {
    FrameData frameDataSummary = FrameData.fromDb(map);
    return CareerData.fromDb(
      totalMatch: map['total_match'] as int,
      totalFrame: map['total_frame'] as int,
      winMatches: map['win_matches'] as int,
      winFrames: map['win_frames'] as int,
      frameWinRate: map['frame_win_rate'] as double,
      matchWinRate: map['match_win_rate'] as double,
      frameDataSummary: frameDataSummary,
    );
  }

  @override
  Map<String, dynamic> toMap(CareerData data) {
    final Map<String, dynamic> tmp = {
      'player_uuid': playerUuid,
      'total_match': data.totalMatch,
      'total_frame': data.totalFrame,
      'win_matches': data.winMatches,
      'win_frames': data.winFrames,
      'frame_win_rate': data.frameWinRate,
      'match_win_rate': data.matchWinRate,
    };
    tmp.addAll(data.frameDataSummary.toDbMap());
    print('CareerData toMap $tmp');
    return tmp;
  }

  // Sex枚举转换辅助方法
  Sex _parseSex(String value) {
    switch (value) {
      case 'male':
        return Sex.male;
      case 'female':
        return Sex.female;
      case 'others':
        return Sex.others;
      default:
        throw ArgumentError('Invalid sex value: $value');
    }
  }

  String _sexToString(Sex sex) {
    return sex.toString().split('.').last;
  }


// 自定义复杂操作
// Future<void> savePlayerWithCareer(Player player) async {
//   final db = await dbHelper.database;
//   await db.transaction((txn) async {
//     // 保存基础信息
//     final playerId = await txn.insert(tableName, toMap(player));
//
//     // 保存关联数据
//     final careerDao = CareerDataDao(txn);
//     await careerDao.insert(player.careerData.copyWith(playerId: playerId));
//   });
// }
}