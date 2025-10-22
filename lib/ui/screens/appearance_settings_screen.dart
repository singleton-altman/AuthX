import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/services/totp_service.dart';
import 'package:authx/ui/widgets/circular_progress_avatar.dart';
import 'package:authx/ui/widgets/color_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class AppearanceSettingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textSize = themeProvider.codeFontSize;
    final avatarSize = themeProvider.avatarSize;

    return Scaffold(
      appBar: AppBar(title: Text('外观设置')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题设置
              _buildThemeSettings(context),

              // 显示设置（包含预览效果与大小调节）
              SizedBox(height: 24),
              Text('显示设置', style: Theme.of(context).textTheme.titleMedium),

              // 主题颜色
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                ),
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('主题颜色', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ColorPicker(
                            selectedColor: themeProvider.primaryColor,
                            onColorChanged: (color) {
                              themeProvider.setPrimaryColor(color);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 预览效果 + 头像大小调节
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                ),
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 预览效果
                    _buildPreviewWidget(context, avatarSize, textSize),

                    // 头像大小滑块
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('小', style: Theme.of(context).textTheme.bodyMedium),
                              Text('当前大小: ${avatarSize.toInt()}', style: Theme.of(context).textTheme.bodyMedium),
                              Text('大', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildSlider(avatarSize, (value) {
                      themeProvider.setAvatarSize(value);
                    }, 10, 40),

                    // 文字大小滑块
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.text_fields, size: 20),
                        SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('小', style: Theme.of(context).textTheme.bodyMedium),
                              Text('当前大小: ${textSize.toInt()}', style: Theme.of(context).textTheme.bodyMedium),
                              Text('大', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildSlider(textSize, (value) {
                      themeProvider.setCodeFontSize(value);
                    }, 12, 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('主题设置', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              child: Column(
                children: [
                  Icon(Icons.wb_sunny, color: themeProvider.themeMode == ThemeMode.light ? Colors.blue : Colors.grey),
                  Text('亮色'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              child: Column(
                children: [
                  Icon(Icons.nightlight, color: themeProvider.themeMode == ThemeMode.dark ? Colors.blue : Colors.grey),
                  Text('暗色'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              child: Column(
                children: [
                  Icon(Icons.sync, color: themeProvider.themeMode == ThemeMode.system ? Colors.blue : Colors.grey),
                  Text('系统'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

      ],
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('主题颜色', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        ColorPicker(
          selectedColor: themeProvider.primaryColor,
          onColorChanged: (color) {
            themeProvider.setPrimaryColor(color);
          },
        ),
      ],
    );
  }

  Widget _buildPreviewWidget(BuildContext context, double avatarSize, double textSize) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircularProgressAvatar(
            issuer: 'G',
            size: avatarSize / 2,
            remainingTime: remainingSeconds,
            period: 30,
            progressColor: themeProvider.primaryColor,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Google', style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w500)),
                Text('example@gmail.com', style: TextStyle(fontSize: textSize - 2, color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            children: [
              Text(code, style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold)),
              Text('${remainingSeconds}s', style: TextStyle(fontSize: textSize - 2, color: Theme.of(context).hintColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(double value, Function(double) onChanged, double min, double max) {
    return Slider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: (max - min).toInt(),
      label: value.toInt().toString(),
    );
  }
}