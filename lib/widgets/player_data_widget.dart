import 'package:flutter/material.dart';
import '../models/player.dart';
import 'package:snooke_master/models/data/match_data.dart';
import 'package:snooke_master/models/data/frame_data.dart';

/// Widget to display a player's current frame statistics in a scrollable list.
class PlayerStatsWidget extends StatelessWidget {
  /// The player whose stats to display.
  final Player player;

  /// Optional width of the widget. Defaults to screen width minus margins.
  final double? width;

  /// Optional height of the widget. Defaults to width (square).
  final double? height;

  const PlayerStatsWidget({
    Key? key,
    required this.player,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve the current frame data
    final MatchData? matchData = player.currentMatchData;
    final FrameData? frame = matchData?.currentFrameData;

    // Set up default dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalMargin = 10.0;
    final cardWidth = width ?? (screenWidth - horizontalMargin * 2);
    final cardHeight = height ?? cardWidth;
    const borderRadius = 12.0;

    // Build the list of stats strings
    final List<String> items = [];
    if (frame != null) {
      items.add('出杆数：${frame.shotsCount}');
      items.add('进球数：${frame.potsCount}');
      items.add('进球率：${(frame.potSuccessRate * 100).toStringAsFixed(1)}%');
      items.add('总得分：${frame.totalScore}');
      items.add('犯规送分：${frame.faultCount}');
      items.add('单杆得分：${frame.break_}');
      items.add('单杆最高分：${frame.highestBreak}');
      items.add('平均出杆时长：${frame.averageShotTime.toStringAsFixed(1)}秒');
      items.add('破百数：${frame.centuries}');
      items.add('单杆10+：${frame.plus10}');
      items.add('单杆20+：${frame.plus20}');
      items.add('单杆30+：${frame.plus30}');
      items.add('单杆50+：${frame.plus50}');
    } else {
      items.add('暂无有效数据');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                items[index],
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
