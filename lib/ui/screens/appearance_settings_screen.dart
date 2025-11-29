import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/ui/widgets/color_picker.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07C160),
        elevation: 0,
        title: const Text(
          '外观设置',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
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
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // 主题设置
          _buildWeChatSettingsGroup(
            context,
            title: '主题模式',
            children: [
              _buildThemeOption(
                context,
                title: '浅色模式',
                icon: Icons.wb_sunny,
                isSelected: themeProvider.themeMode == ThemeMode.light,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),
              _buildThemeOption(
                context,
                title: '深色模式',
                icon: Icons.nightlight,
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),
              _buildThemeOption(
                context,
                title: '跟随系统',
                icon: Icons.settings_system_daydream,
                isSelected: themeProvider.themeMode == ThemeMode.system,
                onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 颜色设置
          _buildWeChatSettingsGroup(
            context,
            title: '主题颜色',
            children: [
              _buildColorOption(
                context,
                title: '主色调',
                subtitle: '选择应用的主色调',
                color: themeProvider.primaryColor,
                onTap: () => _showColorPicker(context, themeProvider),
              ),
              _buildColorOption(
                context,
                title: '重置颜色',
                subtitle: '恢复默认颜色设置',
                color: null,
                onTap: () => _resetColors(themeProvider),
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 显示设置
          _buildWeChatSettingsGroup(
            context,
            title: '显示设置',
            children: [
              _buildSliderOption(
                context,
                title: '头像大小',
                subtitle: '调整验证器列表中的头像大小',
                value: themeProvider.avatarSize,
                min: 32.0,
                max: 64.0,
                onChanged: (value) => themeProvider.setAvatarSize(value),
              ),
              _buildSliderOption(
                context,
                title: '验证码大小',
                subtitle: '调整验证码字体大小',
                value: themeProvider.codeFontSize,
                min: 16.0,
                max: 28.0,
                onChanged: (value) => themeProvider.setCodeFontSize(value),
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWeChatSettingsGroup(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E5E5),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF07C160),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Color(0xFF07C160),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E5E5),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              if (color != null)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.refresh,
                  color: Color(0xFF07C160),
                  size: 24,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    bool showDivider = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E5E5),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value.round().toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF07C160),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: const Color(0xFF07C160),
            inactiveColor: const Color(0xFF07C160).withValues(alpha: 0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择主题颜色'),
          content: SizedBox(
            width: 300,
            height: 200,
            child: ColorPicker(
              selectedColor: themeProvider.primaryColor,
              onColorChanged: (color) {
                themeProvider.setPrimaryColor(color);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('完成'),
            ),
          ],
        );
      },
    );
  }

  void _resetColors(ThemeProvider themeProvider) {
    themeProvider.setPrimaryColor(Colors.green);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('颜色已重置为默认值'),
        backgroundColor: Color(0xFF07C160),
      ),
    );
  }
}