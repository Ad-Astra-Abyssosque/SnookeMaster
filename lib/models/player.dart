
import 'package:flutter/cupertino.dart';
import 'package:snooke_master/database/dao/career_data_dao.dart';
import 'package:snooke_master/database/dao/shot_data_dao.dart';
import 'package:snooke_master/models/data/career_data.dart';
import 'package:snooke_master/models/data/frame_data.dart';
import 'package:snooke_master/models/data/match_data.dart';
import 'package:snooke_master/models/data/shot_data.dart';
import 'package:snooke_master/models/match_model.dart';

enum Sex {
  male,
  female,
  others
}


class Player {
  final String uuid;
  String name;
  int age;  // 注意：Dart 中是 int 不是 Int
  Sex sex;
  String brief;       // 可空字段
  String organization; // 可空字段
  String? avatar;

  CareerData careerData = CareerData();
  late CareerDataDao _careerDataDao;

  MatchData? currentMatchData;
  Side? currentSide;

  // 支持查看详细的赛事和对局数据？
  // 私有主构造函数
  // Player._({
  //   required this.uuid,
  //   required this.name,
  //   required this.age,
  //   required this.sex,
  //   required this.brief,
  //   required this.organization,
  //   required this.avatar,
  //   required this.careerData,
  //   this.currentSide,
  // }) {
  //   _careerDataDao = CareerDataDao(playerUuid: uuid);
  // }
  //
  // // 异步工厂构造函数
  // static Future<Player> create({
  //   required String uuid,
  //   required String name,
  //   int age = 0,
  //   Sex sex = Sex.male,
  //   String brief = '',
  //   String organization = '',
  //   String? avatar,
  //   Side? currentSide,
  // }) async {
  //   final dao = CareerDataDao(playerUuid: uuid);
  //   final List<CareerData> res = await dao.queryWhere(
  //       'player_uuid = ?', [uuid]);
  //   final careerData = res.isNotEmpty ? res[0] : CareerData();
  //
  //   return Player._(
  //     uuid: uuid,
  //     name: name,
  //     age: age,
  //     sex: sex,
  //     brief: brief,
  //     organization: organization,
  //     avatar: avatar,
  //     careerData: careerData,
  //     currentSide: currentSide,
  //   );
  // }

  Player({
    required this.uuid,
    required this.name,  // 必需参数
    this.age = 0,        // 默认值为0
    this.sex = Sex.male, // 默认值为 male
    this.brief = '',          // 可空，无默认值
    this.organization = '',   // 可空，无默认值
    this.avatar,
    this.currentSide,
  }) {
    _careerDataDao = CareerDataDao(playerUuid: uuid);
  }

  // 异步加载数据
  Future<void> loadCareerData() async {
    final res = await _careerDataDao.queryWhere('player_uuid = ?', [uuid]);
    final db = await _careerDataDao.dbHelper.database;
    // 1. 查询 career_data 表中有多少条数据
    final countResult = await db.rawQuery('SELECT COUNT(*) FROM career_data');

    final totalCount = countResult.first['COUNT(*)'];
    print('Debug: career_data 表中总共有 $totalCount 条数据');

    // 2. 查询所有数据的 player_uuid
    final allRecords = await db.query('career_data', columns: ['player_uuid']);
    print('Debug: 所有记录的 player_uuid 列表:');
    for (final record in allRecords) {
      print('  - ${record['player_uuid']}');
    }
    if (res.isNotEmpty) {
      print('$name using career data in database!');
      careerData = res[0];
      print('$name total match ${careerData.totalMatch}');
    }
    else {
      print('$name found no career data in database!');
    }
  }

  void addShotData(ShotData shotData) {
    currentMatchData?.addShotData(shotData);
  }

  void onFrameEnd(bool win) {
    currentMatchData?.onFrameEnd(win);
  }

  void onMatchEnd(bool win, String matchUuid, bool save) async {
    debugPrint('Player $name match end');
    debugPrint('Player $name frameCount ${currentMatchData?.frameCount}');
    currentMatchData?.win = win;
    careerData.update(currentMatchData!);
    if (save) {
      await saveMatchData(matchUuid);
    }
    currentMatchData = null;
    currentSide = null;
  }

  void onFrameReset() {
    currentMatchData?.resetFrame();
  }

  void onMatchReset() {
    currentMatchData = MatchData();
  }

  void onMatchStart() {
    currentMatchData = MatchData();
  }

  Future<void> saveMatchData(String matchUuid) async {
    // 持久化存储，更新本次选手生涯数据
    try {
      final id = await _careerDataDao.update(careerData);
      debugPrint('Update $name\'s career data at $id');
    } catch (e) {
      debugPrint('ERROR when save careerData: $e');
    }

    // 更新所有击球数据到数据库中
    if (currentMatchData != null) {
      final shotDataDao = ShotDataDao(matchUuid: matchUuid, playerUuid: uuid);
      int count = 0;
      for (var frameData in currentMatchData!.frameDataList) {
        for (var shotData in frameData.shots) {
          await shotDataDao.insert(shotData);
          count++;
        }
      }
      debugPrint('Insert $count shot data in match($matchUuid) table');
    }

  }

}