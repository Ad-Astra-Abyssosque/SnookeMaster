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

  CareerData();

  CareerData.fromDb({
    required this.totalMatch,
    required this.totalFrame,
    required this.winMatches,
    required this.winFrames,
    required this.frameWinRate,
    required this.matchWinRate,
    required this.frameDataSummary,
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