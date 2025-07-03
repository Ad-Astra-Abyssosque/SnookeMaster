import 'package:snooke_master/models/frame_data.dart';


class CareerData {

  int totalMatch;
  int totalFrame;
  double frameWinRate;
  double matchWinRate;

  FrameData? frameDataSummary;



  CareerData({
    this.totalFrame = 0,
    this.totalMatch = 0,
    this.frameWinRate = 0.0,
    this.matchWinRate = 0.0,
    this.frameDataSummary
  });

  void update(List<FrameData> matchData) {
    // TODO: update CareerData from matchData
  }


}