import 'package:snooke_master/models/data/frame_data.dart';
import 'package:snooke_master/models/data/shot_data.dart';

class MatchData {

  FrameData? matchData;
  FrameData? currentFrameData;
  List<FrameData> frameDataList = [];

  void addShotData(ShotData shotData) {
    currentFrameData?.addShotData(shotData);
    matchData?.addShotData(shotData);
  }



}

