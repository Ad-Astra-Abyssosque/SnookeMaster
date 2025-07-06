// players_repository.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snooke_master/models/player.dart';
import 'package:snooke_master/models/match_model.dart';


class PlayersManager with ChangeNotifier {

  PlayersManager();

  List<Player> _players = [];

  // 从本地存储加载
  Future<void> loadPlayers() async {
    // final prefs = await SharedPreferences.getInstance();
    // final jsonString = prefs.getString('players');
    // if (jsonString != null) {
    //   final list = jsonDecode(jsonString) as List;
    //   _players = list.map((e) => Player.fromMap(e)).toList();
    // }
    if (_players.isEmpty) {
      _players
        ..add(Player(id: '1', name: 'ayaka', currentSide: Side.alpha))
        ..add(Player(id: '2', name: 'eula', currentSide: Side.alpha))
        ..add(Player(id: '3', name: 'yoimiya', currentSide: Side.beta));
    }
  }

  // 保存到本地存储
  Future<void> _savePlayers() async {
    // final prefs = await SharedPreferences.getInstance();
    // final jsonString = jsonEncode(_players.map((e) => e.toMap()).toList());
    // await prefs.setString('players', jsonString);
  }

  // 添加玩家
  Future<void> addPlayer(Player player) async {
    _players.add(player);
    await _savePlayers();
    notifyListeners(); // 通知监听者
  }

  // 删除玩家
  Future<void> removePlayer(String id) async {
    _players.removeWhere((p) => p.id == id);
    await _savePlayers();
    notifyListeners();
  }



  // 获取所有玩家
  List<Player> get players => _players;
}

