import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/ui/widgets/color_picker.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('外观设置'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const _AppearanceSettingsBody(),
    );
  }
}

class _AppearanceSettingsBody extends StatefulWidget {
  const _AppearanceSettingsBody();

  @override
  State<_AppearanceSettingsBody> createState() =>
      _AppearanceSettingsBodyState();
}

class _AppearanceSettingsBodyState extends State<_AppearanceSettingsBody> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主题设置部分
          _ThemeSettingsSection(themeProvider: themeProvider),
          
          const SizedBox(height: 30),
          
          // 颜色设置部分
          _ColorSettingsSection(themeProvider: themeProvider),
          
          const SizedBox(height: 30),
          
          // 显示设置部分
          _DisplaySettingsSection(themeProvider: themeProvider),
        ],
      ),
    );
  }
}

// 颜色设置部分
class _ColorSettingsSection extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _ColorSettingsSection({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Icon(Icons.palette, size: 24, color: theme.primaryColor),
              const SizedBox(width: 12),
              Text(
                '主题颜色',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // 使用无极颜色选择器
        ColorPicker(
          selectedColor: themeProvider.primaryColor,
          onColorChanged: (color) => themeProvider.setPrimaryColor(color),
        ),
      ],
    );
  }
}

// 显示设置部分
class _DisplaySettingsSection extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _DisplaySettingsSection({
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Icon(
                Icons.tune,
                size: 24,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                '显示设置',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // 实时预览
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return _PreviewCard(themeProvider: themeProvider);
          }
        ),
        
        const SizedBox(height: 20),
        
        // 头像尺寸设置
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return _SizeControlCard(
              title: '头像尺寸',
              icon: Icons.account_circle,
              currentValue: themeProvider.avatarSize,
              min: 10,
              max: 40,
              onChanged: (value) => themeProvider.setAvatarSize(value),
              themeProvider: themeProvider,
            );
          }
        ),
        
        const SizedBox(height: 20),
        
        // 字体尺寸设置
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return _SizeControlCard(
              title: '代码字体大小',
              icon: Icons.text_fields,
              currentValue: themeProvider.codeFontSize,
              min: 16,
              max: 32,
              onChanged: (value) => themeProvider.setCodeFontSize(value),
              themeProvider: themeProvider,
            );
          }
        ),
      ],
    );
  }
}

// 主题设置部分
class _ThemeSettingsSection extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _ThemeSettingsSection({
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Icon(
                Icons.brightness_medium,
                size: 24,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                '主题模式',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // 主题模式选择
        Column(
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return _ThemeModeOption(
                  mode: ThemeMode.light,
                  title: '浅色模式',
                  description: '明亮舒适的界面',
                  icon: Icons.light_mode,
                  currentMode: themeProvider.themeMode,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                );
              }
            ),
            const SizedBox(height: 12),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return _ThemeModeOption(
                  mode: ThemeMode.dark,
                  title: '深色模式',
                  description: '护眼舒适的界面',
                  icon: Icons.dark_mode,
                  currentMode: themeProvider.themeMode,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                );
              }
            ),
            const SizedBox(height: 12),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return _ThemeModeOption(
                  mode: ThemeMode.system,
                  title: '跟随系统',
                  description: '自动匹配系统主题',
                  icon: Icons.brightness_auto,
                  currentMode: themeProvider.themeMode,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                );
              }
            ),
          ],
        ),
      ],
    );
  }
}

// 尺寸控制卡片
class _SizeControlCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double currentValue;
  final double min;
  final double max;
  final Function(double) onChanged;
  final ThemeProvider themeProvider;

  const _SizeControlCard({
    required this.title,
    required this.icon,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: themeProvider.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${currentValue.round()}px',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: themeProvider.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 滑块控制
            Slider(
              value: currentValue,
              min: min,
              max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
              activeColor: themeProvider.primaryColor,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('小', style: theme.textTheme.bodySmall),
                Text('大', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 主题模式选项
class _ThemeModeOption extends StatelessWidget {
  final ThemeMode mode;
  final String title;
  final String description;
  final IconData icon;
  final ThemeMode currentMode;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = currentMode == mode;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      color: isSelected
          ? theme.primaryColor.withValues(alpha: 0.1)
          : theme.cardColor,
      child: ListTile(
        leading: Icon(
          icon,
          size: 28,
          color: isSelected
              ? theme.primaryColor
              : theme.textTheme.bodyMedium?.color,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? theme.primaryColor : null,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.primaryColor.withValues(alpha: 0.8)
                : null,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.primaryColor)
            : null,
        onTap: onTap,
      ),
    );
  }
}

// 预览卡片
class _PreviewCard extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _PreviewCard({
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewAvatarSize = themeProvider.avatarSize.clamp(10.0, 40.0);
    final remainingTime = 15; // 固定显示15秒倒计时
    
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 20,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  '实时预览',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 预览内容 - 使用与首页相同的验证码卡片样式
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // 显示带倒计时跑道的发行方图标
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 圆形进度条背景
                      SizedBox(
                        width: previewAvatarSize * 2,
                        height: previewAvatarSize * 2,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                        ),
                      ),
                      // 圆形进度条（倒计时）
                      SizedBox(
                        width: previewAvatarSize * 2,
                        height: previewAvatarSize * 2,
                        child: CircularProgressIndicator(
                          value: (30 - remainingTime) / 30,
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            remainingTime <= 5 ? Colors.red : theme.primaryColor
                          ),
                        ),
                      ),
                      // 中间的头像或默认图标
                      SizedBox(
                        width: previewAvatarSize,
                        height: previewAvatarSize,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                fontSize: previewAvatarSize * 0.6,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // 中间信息区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '预览账户',
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'authx@example.com',
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
                        '123456',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: themeProvider.codeFontSize,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (remainingTime <= 5 
                              ? Colors.red 
                              : theme.primaryColor).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${remainingTime}s',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: remainingTime <= 5 ? Colors.red : theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
