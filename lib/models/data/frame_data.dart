

import 'package:snooke_master/models/data/shot_data.dart';

class FrameData {
  // TODO: FrameData
  //int highestBreak;
  // 击球数
  // 进球数
  // 进球成功率
  // 总得分
  // 单局最高得分
  // 红球击球数 红球进球数 红球进球率
  // 黄/绿/咖啡/蓝/粉/黑球击球数 x球进球数 x球进球率
  // 破百数
  // 20+ 30+ 50+
  // 平均击球间隔
  // 最大击球间隔

  // 假设有以下字段（根据你的TODO补充）
  int highestBreak = 0;
  int shotsCount = 0;
  int potsCount = 0;
  List<ShotData> shots = [];

  FrameData();

  // 拷贝构造函数
  FrameData.copy(FrameData other)
      : highestBreak = other.highestBreak,
        shotsCount = other.shotsCount,
        potsCount = other.potsCount,
        shots = List.from(other.shots); // 浅拷贝ShotData列表

  // 或者使用拷贝方法（二选一）
  FrameData copy() {
    return FrameData.copy(this);
  }

  void addShotData(ShotData shotData) {
    shots.add(shotData);
    shotsCount++;
    // 其他逻辑...
  }
}