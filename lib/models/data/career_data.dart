import 'package:snooke_master/models/data/frame_data.dart';
import 'match_data.dart';


class CareerData {

  int totalMatch = 0;
  int totalFrame = 0;
  int winMatches = 0;
  int winFrames = 0;
  double frameWinRate = 0.0;
  double matchWinRate = 0.0;
  FrameData frameDataSummary = FrameData();

  CareerData({
    this.totalFrame = 0,
    this.totalMatch = 0,
    this.frameWinRate = 0.0,
    this.matchWinRate = 0.0,
  });

  void update(MatchData matchData) {
    // update CareerData from matchData
    totalMatch++;
    totalFrame += matchData.frameCount;
    winMatches += matchData.win ? 1 : 0;
    winFrames += matchData.winFrame;
    frameWinRate = winFrames / totalFrame;
    matchWinRate = winMatches / totalMatch;
    frameDataSummary.update(matchData.matchData);
  }


}