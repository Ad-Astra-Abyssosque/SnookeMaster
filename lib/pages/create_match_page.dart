import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snooke_master/models/player_manager.dart';
import 'package:snooke_master/widgets/player_name_card.dart';

import '../models/match_info.dart';
import '../models/match_model.dart';
import '../models/player.dart'; // 确保导入PlayerCardWidget

// 定义回调函数类型（可选但推荐）
typedef MatchInfoCallback = void Function(MatchInfo matchInfo);

class CreateMatchPage extends StatelessWidget {
  final MatchInfoCallback onCreateSuccess;
  final VoidCallback onCancel;

  final _matchNameController = TextEditingController();
  final _matchLocationController = TextEditingController();
  List<Player> _teamAlphaPlayers = [];
  List<Player> _teamBetaPlayers = [];

  CreateMatchPage({
    super.key,
    required this.onCreateSuccess,
    required this.onCancel,
  }) {

  }

  void createMatch(BuildContext context) {
    try {
      MatchBuilder builder = MatchBuilder();
      MatchInfo matchInfo = builder
          .matchName(_matchNameController.text)
          .matchLocation(_matchLocationController.text)
          .addPlayers(_teamAlphaPlayers, Side.alpha)
          .addPlayers(_teamBetaPlayers, Side.beta)
          .build();
      debugPrint('Create match success : ${matchInfo.uuid}');
      onCreateSuccess(matchInfo);
    } catch (e) {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    PlayersManager playersManager = Provider.of<PlayersManager>(context);

    return FutureBuilder<List<Player>>(
      future: playersManager.players,
      builder: (context, snapshot) {
        // 1. 处理错误状态
        if (snapshot.hasError) {
          return Center(child: Text('加载失败: ${snapshot.error}'));
        }

        // 2. 数据加载完成
        if (snapshot.connectionState == ConnectionState.done) {
          final players = snapshot.data!;
          // Team Alpha球员（前两名）
          _teamAlphaPlayers = players.take(2).toList();
          // Team Beta球员（第三名，如果存在）
          _teamBetaPlayers = players.length >= 3 ? [players[2]] : [];

          return Scaffold(
            appBar: AppBar(
              title: const Text('创建新赛事'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onCancel,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 赛事名称输入框
                  TextField(
                    controller: _matchNameController,
                    decoration: const InputDecoration(
                      labelText: '赛事名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 赛事地点输入框
                  TextField(
                    controller: _matchLocationController,
                    decoration: const InputDecoration(
                      labelText: '赛事地点',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Team Alpha标题
                  Text(
                    'Team Alpha:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[300],
                    ),
                  ),
                  //const SizedBox(height: 10),

                  // Team Alpha控制行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('当前球员'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {}, // 暂不实现
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {}, // 暂不实现
                          ),
                        ],
                      ),
                    ],
                  ),
                  // const SizedBox(height: 10),

                  // Team Alpha球员列表
                  SizedBox(
                    height: 100, // 固定高度防止溢出
                    child: _teamAlphaPlayers.isEmpty ? const Center(child: Text("暂无玩家")) :
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _teamAlphaPlayers.length,
                      itemBuilder: (context, index) {
                        final player = _teamAlphaPlayers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: PlayerCardWidget(
                            name: player.name,
                            brief: player.brief,
                            avatar: player.avatar != null
                                ? NetworkImage(player.avatar!)
                                : null,
                            height: 80,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Team Beta标题
                  Text(
                    'Team Beta:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[300],
                    ),
                  ),

                  // Team Beta控制行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('当前球员'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {}, // 暂不实现
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {}, // 暂不实现
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Team Beta球员列表
                  SizedBox(
                    height: 100, // 固定高度防止溢出
                    child: _teamBetaPlayers.isEmpty ? const Center(child: Text("暂无玩家")) :
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _teamBetaPlayers.length,
                      itemBuilder: (context, index) {
                        final player = _teamBetaPlayers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: PlayerCardWidget(
                            name: player.name,
                            brief: player.brief,
                            avatar: player.avatar != null
                                ? NetworkImage(player.avatar!)
                                : null,
                            height: 80,
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),

                  // 创建按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      onPressed: () { createMatch(context);},
                      child: const Text('创建赛事'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // 3. 默认显示加载中
        return Center(child: CircularProgressIndicator());
      },
    );
  } // build

}