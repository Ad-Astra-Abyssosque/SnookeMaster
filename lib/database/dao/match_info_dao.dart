import 'dart:convert';

import 'package:snooke_master/models/data/frame_data.dart';
import '../../models/data/career_data.dart';
import '../../models/match_info.dart';
import '../../models/match_model.dart';
import '../../models/player.dart';
import 'base_dao.dart';


class MatchInfoDao extends BaseDao<MatchInfo> {
  

  @override
  String get tableName => 'matches';
  
  

  @override
  Map<String, dynamic> toMap(MatchInfo match) {
    final tmp = {
      'uuid': match.uuid,
      'name': match.name,
      'location': match.location,
      'create_time': match.createTime,
      'players': jsonEncode(match.players.map((player) => player.uuid).toList()),
      'alpha_players': jsonEncode([
        for (var player in match.players)
          if (player.currentSide == Side.alpha) player.uuid
      ]),
      'beta_players': jsonEncode([
        for (var player in match.players)
          if (player.currentSide == Side.beta) player.uuid
      ]),
      'alpha_score': match.alphaScore,
      'beta_score': match.betaScore,
      'frame_count': match.frameCount,
      'win_record': jsonEncode(match.winRecord.map((side) => side.index).toList())
    };
    print('MatchInfo toMap $tmp');
    return tmp;
  }

  @override
  MatchInfo fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }
  
}

