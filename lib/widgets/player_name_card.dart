import 'package:flutter/material.dart';

class PlayerCardWidget extends StatelessWidget {
  final String name;
  final String brief;
  final ImageProvider? avatar;
  final double? width;
  final double? height;

  const PlayerCardWidget({
    Key? key,
    required this.name,
    required this.brief,
    this.avatar,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 默认两侧留空10
    const horizontalMargin = 10.0;
    // 计算可用宽度
    final availableWidth = screenWidth - horizontalMargin * 2;
    // 使用外部传入宽度或默认可用宽度
    final cardWidth = width ?? availableWidth;
    // 默认高度为屏幕宽度四分之一
    final cardHeight = height ?? (screenWidth / 4);
    // 内容内边距
    const padding = 8.0;
    // 头像直径 = 卡片高度 - 上下内边距*2
    final avatarSize = cardHeight - padding * 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 圆形头像
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundImage: avatar ?? const AssetImage('assets/avatar_placeholder.png'),
                backgroundColor: Colors.grey.shade200,
              ),
              // 头像与信息列之间固定间距
              const SizedBox(width: padding),
              // 信息列，占据剩余空间
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 球员名称，字体较大
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: avatarSize * 0.3,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 球员简介，字体较小
                    Text(
                      brief,
                      style: TextStyle(
                        fontSize: avatarSize * 0.2,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
