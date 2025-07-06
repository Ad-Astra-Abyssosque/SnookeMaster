// players_repository.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snooke_master/database/dao/career_data_dao.dart';
import 'package:snooke_master/models/player.dart';
import 'package:snooke_master/models/match_model.dart';
import 'package:snooke_master/database/dao/player_dao.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';


class PlayersManager with ChangeNotifier {

  PlayersManager();

  List<Player> _players = [];

  final PlayerDao _playerDao = PlayerDao();

  // 从本地存储加载
  Future<List<Player>> loadPlayers() async {
    if (_players.isEmpty) {
      _players = await _playerDao.queryAll();
      // debug
      if (_players.isEmpty) {
        debugPrint('Database is empty, create players manually');
        await addPlayer(
            Player(uuid: Uuid().v4(), name: '玛厄斯船长', currentSide: Side.alpha));
        await addPlayer(
            Player(uuid: Uuid().v4(), name: '刚刚', currentSide: Side.alpha));
        await addPlayer(
            Player(uuid: Uuid().v4(), name: 'Lemony', currentSide: Side.beta));
      }
      else {
        debugPrint('Load ${_players.length} players from database!');
        for (var player in _players) {
          await player.loadCareerData();
          debugPrint('${player.name}(${player.uuid}) load career data done');
        }
      }
    }
    else {
      debugPrint('Return existed ${_players.length} players!');
    }

    return List.from(_players);
  }

  // 保存到本地存储
  Future<void> _initPlayerInDatabase(Player player) async {
    final id = await _playerDao.insert(player);
    debugPrint('Add player (${player.name}) to database at $id');
    final CareerDataDao careerDataDao = CareerDataDao(playerUuid: player.uuid);
    final id2 = await careerDataDao.insert(player.careerData);
    debugPrint('Init player (${player.name})\'s career data to database at $id2');
  }

  // 添加玩家
  Future<void> addPlayer(Player player) async {
    _players.add(player);
    await _initPlayerInDatabase(player);
    notifyListeners(); // 通知监听者
  }

  // 删除玩家
  Future<void> removePlayer(String uuid) async {

    _players.removeWhere((p) => p.uuid == uuid);
    _playerDao.delete(uuid);
    //await _savePlayers();
    notifyListeners();
  }



  // 获取所有玩家
  Future<List<Player>> get players => loadPlayers();
}

