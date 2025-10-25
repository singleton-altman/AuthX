import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/ui/screens/about_screen.dart';
import 'package:authx/ui/screens/debug_screen.dart';
import 'package:authx/ui/screens/appearance_settings_screen.dart';
import 'package:authx/utils/app_theme.dart'; // 添加对 app_theme.dart 的导入

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 外观设置
              _buildSettingsSection(
                context,
                title: '外观设置',
                icon: Icons.palette_outlined,
                children: _buildAppearanceSettings(context),
              ),
              const SizedBox(height: 20),
              
              // 应用设置
              _buildSettingsSection(
                context,
                title: '应用设置',
                icon: Icons.settings_outlined,
                children: _buildAppSettings(context),
              ),
              const SizedBox(height: 20),
              
              // 其他
              _buildSettingsSection(
                context,
                title: '其他',
                icon: Icons.more_horiz_outlined,
                children: _buildOtherSettings(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
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

  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppearanceSettings(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return [
      _buildSettingsOption(
        context,
        icon: Icons.brightness_medium_outlined,
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
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildAppSettings(BuildContext context) {
    return [
      _buildSettingsOption(
        context,
        icon: Icons.security_outlined,
        title: '安全设置',
        subtitle: '密码、生物识别等',
        onTap: () {
          // 导航到安全设置
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('此功能将在后续版本中实现')),
          );
        },
      ),
      _buildSettingsOption(
        context,
        icon: Icons.backup_outlined,
        title: '备份与恢复',
        subtitle: '导出或导入数据',
        onTap: () {
          // 导航到备份页面
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('此功能将在后续版本中实现')),
          );
        },
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildOtherSettings(BuildContext context) {
    return [
      _buildSettingsOption(
        context,
        icon: Icons.info_outline,
        title: '关于应用',
        subtitle: '版本信息和介绍',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutScreen()),
        ),
      ),
      _buildSettingsOption(
        context,
        icon: Icons.bug_report_outlined,
        title: '调试工具',
        subtitle: '开发者选项',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DebugScreen()),
        ),
        isLast: true,
      ),
    ];
  }

  // 获取主题模式文本
  String _getThemeModeText(ThemeMode mode) {
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