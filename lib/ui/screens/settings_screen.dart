import 'package:flutter/material.dart';
import 'package:authx/ui/screens/about_screen.dart';
import 'package:authx/ui/screens/debug_screen.dart';
import 'package:authx/ui/screens/appearance_settings_screen.dart';
import 'package:authx/ui/screens/security_settings_screen.dart';
import 'package:authx/ui/screens/backup_restore_screen.dart';
 // 添加对 app_theme.dart 的导入

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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // 外观设置
          _buildSettingsSection(
            context,
            title: '外观设置',
            icon: Icons.palette_outlined,
            children: _buildAppearanceSettings(context),
          ),
          const SizedBox(height: 16),
          
          // 应用设置
          _buildSettingsSection(
            context,
            title: '应用设置',
            icon: Icons.settings_outlined,
            children: _buildAppSettings(context),
          ),
          const SizedBox(height: 16),
          
          // 其他
          _buildSettingsSection(
            context,
            title: '其他',
            icon: Icons.more_horiz_outlined,
            children: _buildOtherSettings(context),
          ),
          const SizedBox(height: 16),
        ],
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
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
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
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
                color: Theme.of(context).primaryColor,
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppearanceSettings(BuildContext context) {

    
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
        subtitle: '应用锁定、数据保护等',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
        ),
      ),
      _buildSettingsOption(
        context,
        icon: Icons.backup_outlined,
        title: '备份与恢复',
        subtitle: '自动备份、手动备份和恢复',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
        ),
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


}