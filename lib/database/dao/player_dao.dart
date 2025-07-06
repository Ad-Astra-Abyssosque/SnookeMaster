
import '../../models/data/career_data.dart';
import '../../models/player.dart';
import 'base_dao.dart';

class PlayerDao extends BaseDao<Player> {
  @override
  String get tableName => 'players';

  @override
  String get primaryKey => 'uuid';

  @override
  Player fromMap(Map<String, dynamic> map) {
    return Player(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      sex: _parseSex(map['sex'] as String),
      brief: map['brief'] as String? ?? '',
      organization: map['organization'] as String? ?? '',
      avatar: map['avatar'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap(Player player) {
    final tmp = {
      'uuid': player.uuid,
      'name': player.name,
      'age': player.age,
      'sex': _sexToString(player.sex),
      'brief': player.brief,
      'organization': player.organization,
      'avatar': player.avatar,
      'updated_at': DateTime.now().toIso8601String(), // 自动更新修改时间
    };
    print('Player toMap $tmp');
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