import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/services/totp_service.dart';
import 'package:authx/ui/widgets/circular_progress_avatar.dart';
import 'package:authx/ui/widgets/color_picker.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('外观设置')),
      body: const _AppearanceSettingsBody(),
    );
  }
}

class _AppearanceSettingsBody extends StatelessWidget {
  const _AppearanceSettingsBody();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textSize = themeProvider.codeFontSize;
    final avatarSize = themeProvider.avatarSize;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // 主题设置
        _buildSettingsSection(
          context,
          title: '主题设置',
          icon: Icons.brightness_medium_outlined,
          children: const [_ThemeModeSettings()],
        ),
        const SizedBox(height: 16),
        
        // 主题颜色选择器
        _buildSettingsSection(
          context,
          title: '主题颜色',
          icon: Icons.palette_outlined,
          children: const [_ThemeColorSettings()],
        ),
        const SizedBox(height: 16),
        
        // 显示设置
        _buildSettingsSection(
          context,
          title: '显示设置',
          icon: Icons.text_fields_outlined,
          children: [
            _DisplaySettings(
              avatarSize: avatarSize,
              textSize: textSize,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 设置项
          ...children,
        ],
      ),
    );
  }
}

class _ThemeModeSettings extends StatelessWidget {
  const _ThemeModeSettings();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;

    return Column(
      children: [
        _ThemeModeOption(
          icon: Icons.wb_sunny,
          title: '亮色模式',
          subtitle: '使用浅色主题',
          isSelected: themeMode == ThemeMode.light,
          onTap: () => themeProvider.setThemeMode(ThemeMode.light),
        ),
        _ThemeModeOption(
          icon: Icons.nightlight,
          title: '暗色模式',
          subtitle: '使用深色主题',
          isSelected: themeMode == ThemeMode.dark,
          onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
        ),
        _ThemeModeOption(
          icon: Icons.sync,
          title: '跟随系统',
          subtitle: '自动匹配系统主题',
          isSelected: themeMode == ThemeMode.system,
          onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          isLast: true,
        ),
      ],
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLast;

  const _ThemeModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeColorSettings extends StatelessWidget {
  const _ThemeColorSettings();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    // 定义预设颜色列表
    final presetColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '选择主题颜色',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presetColors.map((color) {
              final isSelected = themeProvider.primaryColor.value == color.value;
              return GestureDetector(
                onTap: () => themeProvider.setPrimaryColor(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Theme.of(context).dividerColor.withOpacity(0.3),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.white,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DisplaySettings extends StatelessWidget {
  final double avatarSize;
  final double textSize;

  const _DisplaySettings({
    required this.avatarSize,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 预览区域
          _PreviewWidget(avatarSize: avatarSize, textSize: textSize),
          const SizedBox(height: 20),
          
          // 控制区域
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              
              if (isSmallScreen) {
                // 小屏幕：垂直布局
                return Column(
                  children: [
                    _CompactSizeControl(
                      icon: Icons.person_outline,
                      title: '头像大小',
                      currentValue: avatarSize.toInt(),
                      min: 10,
                      max: 40,
                      onChanged: themeProvider.setAvatarSize,
                    ),
                    const SizedBox(height: 12),
                    _CompactSizeControl(
                      icon: Icons.text_fields_outlined,
                      title: '文字大小',
                      currentValue: textSize.toInt(),
                      min: 12,
                      max: 32,
                      onChanged: themeProvider.setCodeFontSize,
                    ),
                  ],
                );
              } else {
                // 大屏幕：水平布局
                return Row(
                  children: [
                    Expanded(
                      child: _CompactSizeControl(
                        icon: Icons.person_outline,
                        title: '头像',
                        currentValue: avatarSize.toInt(),
                        min: 10,
                        max: 40,
                        onChanged: themeProvider.setAvatarSize,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CompactSizeControl(
                        icon: Icons.text_fields_outlined,
                        title: '文字',
                        currentValue: textSize.toInt(),
                        min: 12,
                        max: 32,
                        onChanged: themeProvider.setCodeFontSize,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PreviewWidget extends StatefulWidget {
  final double avatarSize;
  final double textSize;

  const _PreviewWidget({
    required this.avatarSize,
    required this.textSize,
  });

  @override
  State<_PreviewWidget> createState() => _PreviewWidgetState();
}

class _PreviewWidgetState extends State<_PreviewWidget> {
  late Timer _timer;
  int _remainingSeconds = 30;
  String _currentCode = '';
  
  final entry = TotpEntry(
    id: 'preview',
    name: 'Google',
    issuer: 'example@gmail.com',
    secret: 'JBSWY3DPEHPK3PXP',
    algorithm: 'SHA1',
    period: 30,
    digits: 6,
  );

  @override
  void initState() {
    super.initState();
    _updateTotp();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTotp();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTotp() {
    setState(() {
      _currentCode = TotpService.generateTotpAtTime(entry, DateTime.now());
      _remainingSeconds = TotpService.getRemainingTime(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 预览标题
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: theme.hintColor,
              ),
              const SizedBox(width: 6),
              Text(
                '实时预览',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 预览内容
          Row(
            children: [
              CircularProgressAvatar(
                issuer: 'G',
                size: widget.avatarSize,
                remainingTime: _remainingSeconds,
                period: 30,
                progressColor: themeProvider.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google', 
                      style: TextStyle(
                        fontSize: widget.textSize, 
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'example@gmail.com', 
                      style: TextStyle(
                        fontSize: widget.textSize - 2, 
                        color: theme.hintColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currentCode, 
                    style: TextStyle(
                      fontSize: widget.textSize + 4, 
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_remainingSeconds}s', 
                      style: TextStyle(
                        fontSize: widget.textSize - 4, 
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 进度条
          LinearProgressIndicator(
            value: _remainingSeconds / 30,
            backgroundColor: theme.dividerColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

class _CompactSizeControl extends StatelessWidget {
  final IconData icon;
  final String title;
  final int currentValue;
  final int min;
  final int max;
  final Function(double) onChanged;

  const _CompactSizeControl({
    required this.icon,
    required this.title,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标和标题
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 数值显示和按钮控制
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 减小按钮
              Container(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: currentValue > min ? () => onChanged((currentValue - 1).toDouble()) : null,
                  icon: Icon(
                    Icons.remove,
                    size: 16,
                    color: currentValue > min ? theme.primaryColor : theme.disabledColor,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 数值显示
              Container(
                constraints: const BoxConstraints(minWidth: 40, maxWidth: 60),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                ),
                child: Text(
                  '$currentValue',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 增大按钮
              Container(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: currentValue < max ? () => onChanged((currentValue + 1).toDouble()) : null,
                  icon: Icon(
                    Icons.add,
                    size: 16,
                    color: currentValue < max ? theme.primaryColor : theme.disabledColor,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}