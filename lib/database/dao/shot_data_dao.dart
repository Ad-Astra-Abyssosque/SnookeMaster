
import '../../models/data/shot_data.dart';
import '../../models/player.dart';
import 'base_dao.dart';

// 数据库操作类
class ShotDataDao extends BaseDao<ShotData> {

  @override
  String get tableName => 'shot_data_match_${matchUuid.replaceAll('-', '_')}';

  String matchUuid;
  String playerUuid;
  bool _tableCreated = false;

  ShotDataDao({
    required this.matchUuid,
    required this.playerUuid,
  });

  Future<void> _ensureTableExists() async {
    if (!_tableCreated) {
      final db = await dbHelper.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          match_uuid TEXT NOT NULL CHECK(match_uuid = '$matchUuid'),
          player_uuid TEXT NOT NULL,
          record_time TEXT NOT NULL,
          shot_time INTEGER NOT NULL,
          ball TEXT NOT NULL CHECK(ball IN ('red', 'yellow', 'green', 'brown', 'blue', 'pink', 'black')),
          shot_result TEXT NOT NULL CHECK(shot_result IN ('pot', 'miss', 'fault')),
          score INTEGER NOT NULL,
          frame_index INTEGER NOT NULL,
          FOREIGN KEY (match_uuid) REFERENCES matches(uuid),
          FOREIGN KEY (player_uuid) REFERENCES players(uuid)
        );
      ''');
      print('Create new table for match($matchUuid) shots data');
      _tableCreated = true;
    }
  }

  // 插入数据到指定赛事表
  @override
  Future<int> insert(ShotData data) async {
    await _ensureTableExists();
    return super.insert(data);
  }

  @override
  Future<List<ShotData>> queryAll() async {
    await _ensureTableExists();
    return super.queryAll();
  }

  @override
  Future<int> delete(id) async {
    await _ensureTableExists();
    return super.delete(id);
  }

  @override
  Future<int> update(ShotData entity) async {
    await _ensureTableExists();
    return super.update(entity);
  }

  // 创建联合视图
  Future<void> createGlobalView() async {
    final db = await dbHelper.database;
    await db.execute('''
      CREATE VIEW IF NOT EXISTS v_all_shot_data AS
      SELECT * FROM shot_data_template
      UNION ALL
      SELECT * FROM shot_data_match_*
    ''');
  }

  @override
  ShotData fromMap(Map<String, dynamic> map) {
    return ShotData.fromDb(map);
  }

  @override
  Map<String, dynamic> toMap(ShotData data) {
    final tmp = data.toDbMap(matchUuid, playerUuid);
    print('ShotData toMap $tmp');
    return tmp;
  }
}