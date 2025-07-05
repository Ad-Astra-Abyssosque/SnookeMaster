import 'package:snooke_master/models/data/frame_data.dart';
import 'package:snooke_master/models/data/shot_data.dart';

class MatchData {

  FrameData matchDataSnapshot = FrameData();
  FrameData matchData = FrameData();
  FrameData currentFrameData = FrameData();
  List<FrameData> frameDataList = [];
  int frameCount = 0;
  int winFrame = 0;
  bool win = false;

  MatchData();

  // 深拷贝构造函数
  MatchData.copy(MatchData other)
      : matchData = FrameData.copy(other.matchData),
        currentFrameData = FrameData.copy(other.currentFrameData),
        matchDataSnapshot = FrameData.copy(other.matchDataSnapshot),
        frameCount = other.frameCount,
        winFrame = other.winFrame,
        frameDataList = [for (var frame in other.frameDataList) FrameData.copy(frame)];

  // 或者使用拷贝方法（二选一）
  MatchData copy() {
    return MatchData.copy(this);
  }

  void addShotData(ShotData shotData) {
    currentFrameData.addShotData(shotData);
    matchData.addShotData(shotData);
  }

  void onFrameEnd(bool win) {
    frameDataList.add(currentFrameData);
    matchDataSnapshot = currentFrameData.copy();
    currentFrameData = FrameData();
    frameCount++;
    if (win) winFrame++;
  }

  void resetFrame() {
    currentFrameData = FrameData();
    matchData = matchDataSnapshot.copy();
  }
}

