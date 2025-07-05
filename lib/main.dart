import 'package:flutter/material.dart';
import 'package:snooke_master/pages/create_match_page.dart';
import 'package:snooke_master/pages/initial_page.dart';
import 'package:snooke_master/pages/matches_page.dart';
import 'package:snooke_master/pages/players_page.dart';
import 'package:snooke_master/pages/statistics_page.dart';
import 'package:snooke_master/pages/about_page.dart';
import 'package:snooke_master/widgets/player_name_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainLayout(),//MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}



class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _matchCreated = false; // 标记赛事是否已创建
  bool _showCreatePage = false; // 是否显示创建页面

  // 修改为不可变的基础页面列表
  final List<Widget> _basePages = const [
    SizedBox.shrink(), // 占位，实际不使用
    PlayersPage(),
    StatisticsPage(),
    AboutPage(),
  ];

  // 动态生成当前页面列表
  List<Widget> get _pages => [
    _buildFirstPage(), // 第一个页面动态生成
    ..._basePages.sublist(1), // 其他页面保持不变
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // 超过3个item需要此设置
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: '对局',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '球员',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '关于',
          ),
        ],
      ),
    );
  }

  Widget _buildFirstPage() {
    // 根据状态显示不同内容
    if (_showCreatePage) {
      return CreateMatchPage(
        onCreateSuccess: () {
          setState(() {
            _matchCreated = true;
            _showCreatePage = false;
          });
        },
        onCancel: () {
          setState(() => _showCreatePage = false);
        },
      );
    }
    else if (_matchCreated) {
      return MatchesPage(
        onEndMatch: () {
          setState(() => _matchCreated = false);
        },
      );
    }
    else {
      return InitialPage(
        onCreateMatch: () {
          setState(() => _showCreatePage = true);
        },
      );
    }
  }
}

