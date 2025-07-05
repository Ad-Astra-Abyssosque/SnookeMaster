import 'package:snooke_master/models/data/frame_data.dart';
import 'package:snooke_master/models/data/shot_data.dart';

class MatchData {

  FrameData matchData = FrameData();
  FrameData currentFrameData = FrameData();
  List<FrameData> frameDataList = [];

  MatchData();

  // 深拷贝构造函数
  MatchData.copy(MatchData other)
      : matchData = FrameData.copy(other.matchData),
        currentFrameData = FrameData.copy(other.currentFrameData),
        frameDataList = [for (var frame in other.frameDataList) FrameData.copy(frame)];

  // 或者使用拷贝方法（二选一）
  MatchData copy() {
    return MatchData.copy(this);
  }

  void addShotData(ShotData shotData) {
    currentFrameData.addShotData(shotData);
    matchData.addShotData(shotData);
  }

  void onFrameEnd() {
    frameDataList.add(currentFrameData);
    currentFrameData = FrameData();
  }


}

