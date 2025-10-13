import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/ui/screens/about_screen.dart';
import 'package:authx/ui/screens/debug_screen.dart';
import 'package:authx/ui/screens/appearance_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 外观设置
          _buildSectionHeader(context, '外观设置', Icons.color_lens),
          _buildAppearanceSettings(context),
          
          // 应用设置
          _buildSectionHeader(context, '应用设置', Icons.settings),
          _buildAppSettings(context),
          
          // 其他
          _buildSectionHeader(context, '其他', Icons.more_horiz),
          _buildOtherSettings(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      children: [
        _buildSettingsOption(
          context,
          icon: Icons.brightness_medium,
          title: '主题和显示',
          subtitle: '主题模式、主色调和头像大小',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AppearanceSettingsScreen(),
              ),
            );
          },
        ),
        const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
      ],
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    return Column(
      children: [
        _buildSettingsOption(
          context,
          icon: Icons.security,
          title: '安全设置',
          subtitle: '密码、生物识别等',
          onTap: () {
            // 导航到安全设置
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('此功能将在后续版本中实现')),
            );
          },
        ),
        const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
        _buildSettingsOption(
          context,
          icon: Icons.backup,
          title: '备份与恢复',
          subtitle: '导出或导入数据',
          onTap: () {
            // 导航到备份页面
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('此功能将在后续版本中实现')),
            );
          },
        ),
        const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
      ],
    );
  }

  Widget _buildOtherSettings(BuildContext context) {
    return Column(
      children: [
        _buildSettingsOption(
          context,
          icon: Icons.info,
          title: '关于应用',
          subtitle: '版本信息和介绍',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
        const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
        _buildSettingsOption(
          context,
          icon: Icons.bug_report,
          title: '调试工具',
          subtitle: '开发者选项',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DebugScreen()),
          ),
        ),
        const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
      ],
    );
  }

  // 获取主题模式文本
  static String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }
}