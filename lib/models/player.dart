

import 'dart:ffi';
import 'dart:ui';
import 'package:snooke_master/models/career_data.dart';
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
  final String id;
  String name;
  int age;  // 注意：Dart 中是 int 不是 Int
  Sex sex;
  String brief;       // 可空字段
  String organization; // 可空字段
  String? avatar;

  CareerData careerData = CareerData();
  MatchData? currentMatchData;
  Side? currentSide;

  // 支持查看详细的赛事和对局数据？


  Player({
    required this.id,
    required this.name,  // 必需参数
    this.age = 0,        // 默认值为0
    this.sex = Sex.male, // 默认值为 male
    this.brief = '',          // 可空，无默认值
    this.organization = '',   // 可空，无默认值
    this.avatar,
    this.currentSide,
  });

  void updateCareerData(List<FrameData> matchData) {
    careerData.update(matchData);
  }

  void addShotData(ShotData shotData) {
    currentMatchData?.addShotData(shotData);
  }

  void onFrameEnd() {
    currentMatchData?.onFrameEnd();
  }

  void onMatchEnd() {
    currentMatchData?.onFrameEnd();

  }

}