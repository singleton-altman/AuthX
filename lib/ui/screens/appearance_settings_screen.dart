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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主题设置
            const _ThemeModeSettings(),
            const SizedBox(height: 24),
            
            // 主题颜色选择器
            const _ThemeColorSettings(),
            const SizedBox(height: 24),
            
            // 显示设置
            Text('显示设置', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _DisplaySettings(
              avatarSize: avatarSize,
              textSize: textSize,
            ),
          ],
        ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('主题设置', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ThemeModeButton(
              icon: Icons.wb_sunny,
              label: '亮色',
              isSelected: themeMode == ThemeMode.light,
              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
            ),
            _ThemeModeButton(
              icon: Icons.nightlight,
              label: '暗色',
              isSelected: themeMode == ThemeMode.dark,
              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
            ),
            _ThemeModeButton(
              icon: Icons.sync,
              label: '系统',
              isSelected: themeMode == ThemeMode.system,
              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected 
        ? Theme.of(context).primaryColor 
        : Theme.of(context).disabledColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color)),
        ],
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

    // 添加边界检查，确保 selectedColor 在有效范围内
    int getValidColorIndex(Color color) {
      // 根据颜色值获取对应的索引
      // 这里假设颜色索引与颜色值有对应关系
      // 实际实现可能需要根据具体颜色映射关系调整
      final colorValue = color.value;
      
      // 简单的映射逻辑：将颜色值映射到 2-7 范围内
      if (colorValue < 0x000000) return 2;
      if (colorValue > 0xFFFFFF) return 7;
      
      // 使用颜色值的高位部分进行映射
      final index = ((colorValue >> 16) & 0xFF) % 6 + 2;
      return index;
    }

    // 获取有效的颜色索引
    final validColorIndex = getValidColorIndex(themeProvider.primaryColor);

    // 根据索引获取对应的颜色值
    Color getSelectedColor(int index) {
      // 定义颜色映射表
      final colors = [
        Colors.blue,
        Colors.green,
        Colors.red,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        Colors.cyan,
      ];
      
      return colors[index - 2]; // 索引从2开始，所以减去2
    }

    final selectedColor = getSelectedColor(validColorIndex);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, size: 20, color: Colors.amber),
              const SizedBox(width: 12),
              Text('主题颜色', style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
              const Spacer(),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ColorPicker(
            selectedColor: selectedColor, // 使用经过验证的颜色值
            onColorChanged: (color) {
              themeProvider.setPrimaryColor(color);
            },
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('显示预览', style: theme.textTheme.titleMedium?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 12),
          _PreviewWidget(avatarSize: avatarSize, textSize: textSize),
          const SizedBox(height: 24),
          
          _SizeControlSection(
            icon: Icons.person,
            title: '头像大小',
            currentValue: avatarSize.toInt(),
            min: 10,
            max: 40,
            onChanged: themeProvider.setAvatarSize,
          ),
          const SizedBox(height: 24),
          
          _SizeControlSection(
            icon: Icons.text_fields,
            title: '文字大小',
            currentValue: textSize.toInt(),
            min: 12,
            max: 32,
            onChanged: themeProvider.setCodeFontSize,
          ),
        ],
      ),
    );
  }
}

class _PreviewWidget extends StatelessWidget {
  final double avatarSize;
  final double textSize;

  const _PreviewWidget({
    required this.avatarSize,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    final entry = TotpEntry(
      id: 'preview',
      name: 'Google',
      issuer: 'example@gmail.com',
      secret: 'JBSWY3DPEHPK3PXP',
      algorithm: 'SHA1',
      period: 30,
      digits: 6,
    );
    final code = TotpService.generateTotpAtTime(entry, DateTime.now());
    final remainingSeconds = TotpService.getRemainingTime(entry);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircularProgressAvatar(
                issuer: 'G',
                size: avatarSize,
                remainingTime: remainingSeconds,
                period: 30,
                progressColor: themeProvider.primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google', 
                      style: TextStyle(
                        fontSize: textSize, 
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'example@gmail.com', 
                      style: TextStyle(
                        fontSize: textSize - 2, 
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    code, 
                    style: TextStyle(
                      fontSize: textSize + 4, 
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${remainingSeconds}s', 
                    style: TextStyle(
                      fontSize: textSize - 2, 
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: remainingSeconds / 30,
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            minHeight: 2,
          ),
        ],
      ),
    );
  }
}

class _SizeControlSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final int currentValue;
  final int min;
  final int max;
  final Function(double) onChanged;

  const _SizeControlSection({
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.primaryColor),
            const SizedBox(width: 12),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: theme.primaryColor,
            inactiveTrackColor: theme.dividerColor,
            thumbColor: theme.primaryColor,
            overlayColor: theme.primaryColor.withOpacity(0.2),
            valueIndicatorColor: theme.primaryColor,
            trackHeight: 6,
            valueIndicatorTextStyle: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: currentValue.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$currentValue px',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}