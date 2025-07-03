// matches_page.dart
import 'package:flutter/material.dart';
import 'package:snooke_master/widgets/player_data_single_match.dart';
import 'package:snooke_master/widgets/score_board.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final List<String> players = ['ayaka', 'eula', 'yoimiya']; // 从数据源获取球员数据

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: players.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('当前对局'),
    //     bottom: TabBar(
    //       controller: _tabController,
    //       isScrollable: true, // 支持横向滚动
    //       tabs: players.map((player) => Tab(text: player)).toList(),
    //     ),
    //   ),
    //   body: TabBarView(
    //     controller: _tabController,
    //     children: players.map((player) {
    //       return Text('自定义组件展示对局信息'); // 自定义组件展示对局信息
    //     }).toList(),
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        title: const Text('当前对局'),
        // 移除bottom中的TabBar，因为我们将在body中自定义布局
      ),
      body: Column(
        children: [
          // 1. 添加共享计分板（高度约为屏幕1/4）
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: const ScoreBoard(), // 使用之前创建的计分板Widget
          ),

          // 2. 添加TabBar（放在计分板下方）
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: players.map((player) => Tab(text: player)).toList(),
            ),
          ),

          // 3. 添加TabBarView（使用Expanded填充剩余空间）
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: players.map((player) {
                return Text('player: player'); // 自定义组件展示对局信息
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// 球员对局信息组件
// class PlayerMatchInfo extends StatelessWidget {
//   final Player player;
//
//   const PlayerMatchInfo({super.key, required this.player});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         PlayerCard(player: player),
//         const SizedBox(height: 20),
//         _buildMatchStats(),
//         // 其他对局信息组件...
//       ],
//     );
//   }
//
//   Widget _buildMatchStats() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('最近5场对局', style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 10),
//             // 展示对局数据表格或列表
//           ],
//         ),
//       ),
//     );
//   }
// }