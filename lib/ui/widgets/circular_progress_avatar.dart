import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class CircularProgressAvatar extends StatelessWidget {
  final String? icon;
  final String issuer;
  final double size;
  final int remainingTime;
  final int period;
  final Color progressColor;

  const CircularProgressAvatar({
    super.key,
    this.icon,
    required this.issuer,
    required this.size,
    required this.remainingTime,
    required this.period,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 圆形进度条背景
        SizedBox(
          width: size * 2,
          height: size * 2,
          child: CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 3,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
          ),
        ),
        // 圆形进度条（倒计时）
        SizedBox(
          width: size * 2,
          height: size * 2,
          child: CircularProgressIndicator(
            value: (period - remainingTime) / period,
            strokeWidth: 3,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        // 中间的头像或默认图标
        SizedBox(
          width: size * 2 - 6, // 减去进度条的宽度
          height: size * 2 - 6,
          child: _buildAvatar(context),
        ),
      ],
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    // 移除base64数据URI前缀
    final String base64Data = base64String.split(',').last;
    // 解码base64字符串
    return base64Decode(base64Data);
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    
    // 如果有图标URL，则显示图标；否则显示默认头像
    if (icon != null && icon!.isNotEmpty) {
      try {
        // 判断是base64编码还是网络图片链接
        if (icon!.startsWith('data:image')) {
          // base64编码图片
          final Uint8List imageBytes = _decodeBase64Image(icon!);
          return CircleAvatar(
            radius: size - 3, // 减去进度条的半宽度
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            backgroundImage: MemoryImage(imageBytes),
          );
        } else {
          // 网络图片链接
          return CircleAvatar(
            radius: size - 3, // 减去进度条的半宽度
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            backgroundImage: NetworkImage(icon!),
          );
        }
      } catch (e) {
        // 如果加载失败，回退到默认头像
        return _buildDefaultAvatar(theme);
      }
    } else {
      // 默认头像
      return _buildDefaultAvatar(theme);
    }
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          issuer.isNotEmpty ? issuer.substring(0, 1).toUpperCase() : 'A',
          style: TextStyle(
            fontSize: size * 0.8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}