import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/services/totp_service.dart';
import 'package:authx/ui/widgets/circular_progress_avatar.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  late TotpEntry _exampleEntry;

  @override
  void initState() {
    super.initState();
    _exampleEntry = TotpEntry(
      id: 'example-id',
      name: 'example@gmail.com',
      issuer: 'Google',
      secret: 'JBSWY3DPEHPK3PXP',
      digits: 6,
      algorithm: 'SHA1',
      period: 30,
      icon: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFF44336), // Red
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('外观设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 主题设置部分
          _buildSection(context, '主题设置', [
            _buildThemeModeSettings(context, themeProvider),
            const Divider(height: 1),
            _buildColorSettings(context, themeProvider, colors),
          ]),
          
          // 预览效果
          _buildSectionHeader(context, '预览效果'),
          _buildTotpExample(context, themeProvider, _exampleEntry),
          
          // 显示设置部分
          _buildSection(context, '显示设置', [
            _buildDisplaySettings(context, themeProvider),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, title),
        Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildThemeModeSettings(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildThemeModeOption(
            context,
            title: '亮色',
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (value) => themeProvider.setThemeMode(value!),
          ),
          _buildThemeModeOption(
            context,
            title: '暗色',
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (value) => themeProvider.setThemeMode(value!),
          ),
          _buildThemeModeOption(
            context,
            title: '系统',
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (value) => themeProvider.setThemeMode(value!),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSettings(
    BuildContext context,
    ThemeProvider themeProvider,
    List<Color> colors,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              themeProvider.setPrimaryColor(color);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: themeProvider.primaryColor == color
                      ? Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: themeProvider.primaryColor == color
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisplaySettings(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 头像大小设置
          _buildAvatarSizeSettings(context, themeProvider),
          const SizedBox(height: 16),
          
          // 验证码文字大小设置
          _buildCodeFontSizeSettings(context, themeProvider),
        ],
      ),
    );
  }

  Widget _buildAvatarSizeSettings(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: themeProvider.avatarSize,
                  min: 10,
                  max: 40,
                  divisions: 30,
                  label: themeProvider.avatarSize.round().toString(),
                  onChanged: (double value) {
                    themeProvider.setAvatarSize(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('小'),
              Text('当前大小: ${themeProvider.avatarSize.round()}'),
              const Text('大'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeFontSizeSettings(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: themeProvider.codeFontSize,
                  min: 12,
                  max: 32,
                  divisions: 20,
                  label: themeProvider.codeFontSize.round().toString(),
                  onChanged: (double value) {
                    themeProvider.setCodeFontSize(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('小'),
              Text('当前大小: ${themeProvider.codeFontSize.round()}'),
              const Text('大'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotpExample(
    BuildContext context,
    ThemeProvider themeProvider,
    TotpEntry entry,
  ) {
    final theme = Theme.of(context);
    final double avatarSize = themeProvider.avatarSize;
    final double codeFontSize = themeProvider.codeFontSize;
    final int remainingTime = 15; // 固定显示15秒倒计时

    // 先定义所有需要的函数
    Uint8List decodeBase64Image(String base64String) {
      // 移除base64数据URI前缀
      final String base64Data = base64String.split(',').last;
      // 解码base64字符串
      return base64Decode(base64Data);
    }

    Widget buildDefaultAvatar() {
      return Container(
        width: avatarSize * 2,
        height: avatarSize * 2,
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            entry.issuer.isNotEmpty
                ? entry.issuer.substring(0, 1).toUpperCase()
                : 'A',
            style: TextStyle(
              fontSize: avatarSize * 0.8,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // 添加构建头像的方法
    Widget buildAvatar() {
      // 如果有图标URL，则显示图标；否则显示默认头像
      if (entry.icon.isNotEmpty) {
        try {
          // 判断是base64编码还是网络图片链接
          if (entry.icon.startsWith('data:image')) {
            // base64编码图片
            final Uint8List imageBytes = decodeBase64Image(entry.icon);
            return CircleAvatar(
              radius: avatarSize,
              backgroundColor: theme.primaryColor.withOpacity(0.1), // 添加背景颜色
              backgroundImage: MemoryImage(imageBytes),
            );
          } else {
            // 网络图片链接
            return CircleAvatar(
              radius: avatarSize,
              backgroundColor: theme.primaryColor.withOpacity(0.1), // 添加背景颜色
              backgroundImage: NetworkImage(entry.icon),
            );
          }
        } catch (e) {
          // 如果加载失败，回退到默认头像
          return buildDefaultAvatar();
        }
      } else {
        // 默认头像
        return buildDefaultAvatar();
      }
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 显示发行方或默认图标
            buildAvatar(),
            const SizedBox(width: 12),
            // 中间信息区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.issuer.isNotEmpty ? entry.issuer : '未知服务',
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.name.isNotEmpty ? entry.name : '未知账户',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 验证码和倒计时区域
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  TotpService.generateTotpAtTime(entry, DateTime.now()),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: codeFontSize,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${remainingTime}s',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: remainingTime <= 5 ? Colors.red : theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context, {
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final bool isSelected = value == groupValue;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.primaryColor.withOpacity(0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getThemeModeIcon(value),
              color: isSelected ? theme.primaryColor : theme.iconTheme.color,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                    ? theme.primaryColor 
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.auto_mode;
    }
  }
}
