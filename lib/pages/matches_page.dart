// matches_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:snooke_master/models/match_info.dart';
import 'package:snooke_master/widgets/balls_panel.dart';
import 'package:snooke_master/widgets/score_board.dart';
import 'package:snooke_master/models/match_model.dart';
import 'package:snooke_master/widgets/player_name_card.dart';
import 'package:snooke_master/widgets/player_data_widget.dart';


import '../models/player.dart';
import 'package:snooke_master/utils.dart';

class MatchesPage extends StatefulWidget {
  final VoidCallback onEndMatch;
  final MatchInfo matchInfo;

  const MatchesPage({
    super.key,
    required this.onEndMatch,
    required this.matchInfo,
  });

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage>
    with SingleTickerProviderStateMixin {

  //final List<String> players = ['ayaka', 'eula', 'yoimiya']; // 从数据源获取球员数据
  late TabController _tabController;
  // final matchModel = MatchModel(players: [
  //   Player(id: '1', name: 'ayaka', currentSide: Side.alpha),
  //   Player(id: '2', name: 'eula', currentSide: Side.alpha),
  //   Player(id: '3', name: 'yoimiya', currentSide: Side.beta)
  // ]);

  late String _matchName;
  late MatchModel matchModel;

  @override
  void initState() {
    super.initState();

    matchModel = MatchModel(
        matchInfo: widget.matchInfo,
        // players: List.from(widget.matchInfo.players),
        // matchUuid: widget.matchInfo.uuid,
    );
    _matchName = widget.matchInfo.name;

    _tabController = TabController(
      length: matchModel.players.length,
      vsync: this,
    );

    // 监听TabController的变化
    _tabController.addListener(() {
      if (_tabController.index != matchModel.currentIndex) {
        debugPrint('_tabController.indexIsChanging');
        matchModel.switchToPlayer(_tabController.index);
      }
    });

    // 监听MatchModel的变化
    matchModel.addListener(() {
      if (_tabController.index != matchModel.currentIndex) {
        _tabController.animateTo(matchModel.currentIndex);
        debugPrint('_tab controller current index: ${_tabController.index}');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    matchModel.dispose();
    super.dispose();
  }

  // 处理拖动排序
  void _handleReorder(int oldIndex, int newIndex) {
    debugPrint('old: $oldIndex, new: $newIndex');
    if (oldIndex == newIndex) return;

    final players = List<Player>.from(matchModel.players);
    final selectedPlayer = players.removeAt(oldIndex);
    final insertIndex = newIndex >= matchModel.players.length ? matchModel.players.length - 1 : newIndex;
    debugPrint('insert at $insertIndex');
    players.insert(insertIndex, selectedPlayer);

    // 更新当前选中索引
    // 其他情况如拖动的tab以及最终位置均在选中tab的前或后，则不影响选中tab
    int newSelectedIndex = matchModel.currentIndex;
    // 拖动的是选中的tab
    if (oldIndex == matchModel.currentIndex) {
      newSelectedIndex = insertIndex;
    }
    // 拖动的tab位于选中tab之前，并拖动到了选中的tab后面
    else if (oldIndex < matchModel.currentIndex && insertIndex >= matchModel.currentIndex) {
      newSelectedIndex--;
    }
    // 拖动的tab位于选中tab后面，并拖动到了选中tab的前面
    else if (oldIndex > matchModel.currentIndex && insertIndex <= matchModel.currentIndex) {
      newSelectedIndex++;
    }

    matchModel.updatePlayers(players, newSelectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft, // 标题靠左
          child: Text(_matchName),
        ),
        actions: [
          // 取消按钮 (X)
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: '取消赛事', // 辅助提示
            onPressed: () async {
              final bool? confirm = await showConfirmDialog(
                context: context,
                title: '确认取消赛事？',
                content: '取消后将丢失当前赛事数据',
              );
              if (confirm == true) {
                matchModel.stopMatch(false); // 不保存数据
                widget.onEndMatch(); // 触发父组件的回调
              }
            },
          ),

          // 确认按钮 (√)
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: '结束赛事', // 辅助提示
            onPressed: () async {
              if (matchModel.frameScorePlayer1 == matchModel.frameScorePlayer2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('当前处于平局！')),
                );
                return;
              }
              final bool? confirm = await showConfirmDialog(
                context: context,
                title: '确认结束赛事并保存？',
                content: '当前小局不会计入数据，请确保当前小局已结算',
              );
              if (confirm == true) {
                matchModel.stopMatch(true); // 保存数据
                widget.onEndMatch(); // 触发父组件的回调
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 添加共享计分板（高度约为屏幕1/4）
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
            child: SizedBox(
              height: screenSize.height * 0.25,
              child: ScoreBoard(match: matchModel),
            ),
          ),

          // 2. 添加TabBar（放在计分板下方）
          // Container(
          //   color: Theme.of(context).appBarTheme.backgroundColor,
          //   child: TabBar(
          //     controller: _tabController,
          //     isScrollable: true,
          //     tabs: players.map((player) => Tab(text: player)).toList(),
          //   ),
          // ),
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02, vertical: screenSize.height * 0.01),
            height: 52, // 固定高度确保拖动区域
            child: ListenableBuilder(listenable: matchModel, builder: (context, child) {
              return ReorderableListView(
                //padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                scrollDirection: Axis.horizontal,
                onReorder: _handleReorder,
                children: [
                  for (int i = 0; i < matchModel.players.length; i++)
                    ReorderableDelayedDragStartListener(
                      key: ValueKey(matchModel.players[i].uuid),
                      index: i,
                      // child: Card(
                      //   color: Colors.red[300],
                      //   child: SizedBox(child: Center(child: Text('Card ${matchModel.players[i].name}'))),
                      // ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            matchModel.players[i].name,
                            style: TextStyle(
                              color: i == matchModel.currentIndex
                                  ? Colors.white
                                  : matchModel.players[i].currentSide == Side.alpha
                                  ? Colors.red[300]
                                  : Colors.blue[300],
                            ),
                          ),
                          selected: i == matchModel.currentIndex,
                          onSelected: (_) => _tabController.animateTo(i),
                          backgroundColor: Colors.grey[200],
                          selectedColor: matchModel.players[i].currentSide == Side.alpha
                              ? Colors.red[300]
                              : Colors.blue[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          // padding: const EdgeInsets.symmetric(horizontal: 16),
                          labelPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      )
                    ),
                ],
              );
            })
          ),

          // 3. 添加TabBarView（使用Expanded填充剩余空间）
          Expanded(
            child: ListenableBuilder(listenable: matchModel, builder: (context, child) {
              return TabBarView(
                controller: _tabController,
                children: [
                  //for (int i = 0; i < matchModel.players.length; i++)
                    // 这里用 PlayerCardWidget 替代 Text
                    // Column(
                    //   children: [
                    //     Center(
                    //     child: PlayerCardWidget(
                    //       name: matchModel.players[i].name,
                    //       brief: matchModel.players[i].brief,
                    //       avatar: matchModel.players[i].avatar != null
                    //           ? NetworkImage(matchModel.players[i].avatar!)
                    //           : null,
                    //     ),
                    //   ),
                    //   Container()
                    //   ],
                    //
                    // ),
                      for (int i = 0; i < matchModel.players.length; i++)
                            // 每页先显示球员名片，然后用 Expanded 显示可滚动的统计数据
                          Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                // 顶部名片
                                PlayerCardWidget(
                                  name: matchModel.players[i].name,
                                  brief: matchModel.players[i].brief,
                                  avatar: matchModel.players[i].avatar != null
                                      ? NetworkImage(matchModel.players[i].avatar!)
                                      : null,
                                ),
                                SizedBox(height: 5,),
                                // 占用剩余空间的统计列表
                                Expanded(
                                  child: PlayerStatsWidget(
                                      player: matchModel.players[i],
                                  ),
                                ),
                              ],
                            ),



                ],
              );
            })
          ),

          // 4. 击球数据控制面板
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
            child: SizedBox(
              child: BallsPanel(matchModel: matchModel),
            ),
          ),
        ],
      ),
    );
  } // build

  // Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
  //   return AnimatedBuilder(
  //     animation: animation,
  //     builder: (BuildContext context, Widget? child) {
  //       final double animValue = Curves.easeInOut.transform(animation.value);
  //       final double elevation = lerpDouble(1, 6, animValue)!;
  //       final double scale = lerpDouble(1, 1.02, animValue)!;
  //       return Transform.scale(
  //         scale: scale,
  //         // Create a Card based on the color and the content of the dragged one
  //         // and set its elevation to the animated value.
  //         child: Card(elevation: elevation, color: Colors.red[200], child: cards[index].child),
  //       );
  //     },
  //     child: child,
  //   );
  // }
}

