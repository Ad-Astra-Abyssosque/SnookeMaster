import 'package:snooke_master/models/player.dart';
import 'package:snooke_master/models/player_manager.dart';
import 'package:uuid/uuid.dart';
import 'match_model.dart';

class MatchInfo {
  String uuid;
  String createTime;  // format: 2025-06-21 15:30:33
  String name;
  String location;
  List<Player> players;
  int frameCount = 0;
  List<Side> winRecord = [];
  int alphaScore = 0;
  int betaScore = 0;
  List<Player> alphaPlayers = [];
  List<Player> betaPlayers = [];

  MatchInfo({
    required this.uuid,
    required this.createTime,
    required this.name,
    required this.location,
    required this.players,
  });


}



class MatchBuilder {
  String _name = '';
  String _location = '';
  final List<Player> _playersInMatch = [];
  final _alphaPlayers = <Player>[];
  final _betaPlayers = <Player>[];

  List<Player> get playersInMatch => _playersInMatch;

  MatchBuilder matchName(String name) {
    _name = name;
    return this;
  }

  MatchBuilder matchLocation(String location) {
    _location = location;
    return this;
  }

  MatchBuilder addPlayers(List<Player> players, Side side) {
    for (var player in players) {
      player.currentSide = side;
      _playersInMatch.add(player);

      // 按阵营分组统计
      if (side == Side.alpha) {
        _alphaPlayers.add(player);
      } else {
        _betaPlayers.add(player);
      }
    }
    return this;
  }

  MatchInfo build() {

    // 检查玩家阵营数量
    if (_alphaPlayers.isEmpty || _betaPlayers.isEmpty) {
      throw Exception("每个阵营必须至少有一名玩家");
    }

    // 设置默认值
    final name = _name.isNotEmpty ? _name : "世锦赛";
    final location = _location.isNotEmpty ? _location : "克鲁斯堡";

    // 生成创建时间
    final now = DateTime.now();
    final createTime = DateTime.now().toIso8601String();

    // 生成唯一ID（使用时间戳）
    final uuid = Uuid().v4();

    return MatchInfo(
      uuid: uuid,
      createTime: createTime,
      name: name,
      location: location,
      players: List.from(_playersInMatch),  // 创建副本
    );
  }

  // 辅助方法：确保两位数格式
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

}