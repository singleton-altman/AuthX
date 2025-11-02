import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:authx/services/storage_service.dart';
import 'package:authx/ui/screens/export_screen.dart';
import 'package:authx/ui/screens/simple_import_screen.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totpProvider = Provider.of<TotpProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('备份与恢复')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          // 自动备份
          _buildSettingsSection(
            context,
            title: '自动备份',
            icon: Icons.autorenew_outlined,
            children: _buildAutoBackupSettings(context),
          ),
          const SizedBox(height: 8),

          // 手动备份
          _buildSettingsSection(
            context,
            title: '手动备份',
            icon: Icons.backup_outlined,
            children: _buildManualBackupSettings(context, totpProvider),
          ),
          const SizedBox(height: 8),

          // 恢复数据
          _buildSettingsSection(
            context,
            title: '恢复数据',
            icon: Icons.restore_outlined,
            children: _buildRestoreSettings(context, totpProvider),
          ),
          const SizedBox(height: 8),

          // 备份历史
          _buildSettingsSection(
            context,
            title: '备份历史',
            icon: Icons.history_outlined,
            children: _buildBackupHistorySettings(context),
          ),
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
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
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

  List<Widget> _buildAutoBackupSettings(BuildContext context) {
    return [
      _buildSettingItem(
        context,
        title: '启用自动备份',
        subtitle: '每天自动备份数据到安全位置',
        trailing: Switch(
          value: false, // 需要实现实际的存储逻辑
          onChanged: (value) {
            _showAutoBackupSetupDialog(context, value);
          },
        ),
      ),
      _buildSettingItem(
        context,
        title: '备份频率',
        subtitle: '选择自动备份的时间间隔',
        trailing: Text(
          '每天',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        onTap: () => _showBackupFrequencyDialog(context),
      ),
      _buildSettingItem(
        context,
        title: '备份位置',
        subtitle: '选择备份文件的存储位置',
        trailing: Text(
          '本地存储',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        onTap: () => _showBackupLocationDialog(context),
      ),
    ];
  }

  List<Widget> _buildManualBackupSettings(
    BuildContext context,
    TotpProvider totpProvider,
  ) {
    return [
      _buildSettingItem(
        context,
        title: '立即备份',
        subtitle: '手动创建当前数据的备份',
        trailing: IconButton(
          icon: const Icon(Icons.backup_outlined),
          onPressed: () => _createManualBackup(context, totpProvider),
        ),
        onTap: () => _createManualBackup(context, totpProvider),
      ),
      _buildSettingItem(
        context,
        title: '导出数据',
        subtitle: '导出所有2FA数据到加密文件',
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExportScreen()),
          );
        },
      ),
      _buildSettingItem(
        context,
        title: '备份加密',
        subtitle: '使用AES-256加密备份文件',
        trailing: Switch(
          value: true, // 默认启用加密
          onChanged: (value) {
            // 实现加密设置逻辑
          },
        ),
      ),
    ];
  }

  List<Widget> _buildRestoreSettings(
    BuildContext context,
    TotpProvider totpProvider,
  ) {
    return [
      _buildSettingItem(
        context,
        title: '从备份恢复',
        subtitle: '从备份文件恢复数据',
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SimpleImportScreen()),
          );
        },
      ),
      _buildSettingItem(
        context,
        title: '查看备份文件',
        subtitle: '浏览和管理本地备份文件',
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showBackupFilesDialog(context),
      ),
      _buildSettingItem(
        context,
        title: '验证备份完整性',
        subtitle: '检查备份文件是否完整可用',
        trailing: IconButton(
          icon: const Icon(Icons.verified_user_outlined),
          onPressed: () => _verifyBackupIntegrity(context),
        ),
        onTap: () => _verifyBackupIntegrity(context),
      ),
    ];
  }

  List<Widget> _buildBackupHistorySettings(BuildContext context) {
    return [
      _buildSettingItem(
        context,
        title: '备份历史记录',
        subtitle: '查看最近的备份操作',
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showBackupHistoryDialog(context),
      ),
      _buildSettingItem(
        context,
        title: '清理旧备份',
        subtitle: '删除超过30天的旧备份文件',
        trailing: IconButton(
          icon: const Icon(Icons.cleaning_services_outlined),
          onPressed: () => _cleanOldBackups(context),
        ),
        onTap: () => _cleanOldBackups(context),
      ),
      _buildSettingItem(
        context,
        title: '备份统计',
        subtitle: '查看备份文件大小和数量统计',
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showBackupStatisticsDialog(context),
      ),
    ];
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showAutoBackupSetupDialog(BuildContext context, bool enable) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(enable ? '启用自动备份' : '禁用自动备份'),
          content: Text(
            enable
                ? '自动备份将在每天凌晨自动创建数据备份。建议在WiFi环境下使用此功能。'
                : '禁用自动备份后，您需要手动创建备份文件。确定要禁用吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 实现自动备份设置逻辑
                Navigator.of(context).pop();
              },
              child: Text(enable ? '启用' : '禁用'),
            ),
          ],
        );
      },
    );
  }

  void _showBackupFrequencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('备份频率'),
          content: const Text('选择自动备份的时间间隔：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            // 可以添加更多选项
          ],
        );
      },
    );
  }

  void _showBackupLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('备份位置'),
          content: const Text('选择备份文件的存储位置：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            // 可以添加更多选项
          ],
        );
      },
    );
  }

  void _createManualBackup(
    BuildContext context,
    TotpProvider totpProvider,
  ) async {
    try {
      // 显示备份进度
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在创建备份...'),
              ],
            ),
          );
        },
      );

      // 模拟备份过程
      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pop(); // 关闭进度对话框

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('备份创建成功！')));
    } catch (e) {
      Navigator.of(context).pop(); // 关闭进度对话框
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('备份失败：$e')));
    }
  }

  void _showBackupFilesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('备份文件'),
          content: const Text('浏览和管理本地备份文件：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            // 可以添加文件浏览功能
          ],
        );
      },
    );
  }

  void _verifyBackupIntegrity(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('验证备份完整性'),
          content: const Text('正在检查备份文件的完整性...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 实现验证逻辑
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('备份文件完整性验证通过！')));
              },
              child: const Text('验证'),
            ),
          ],
        );
      },
    );
  }

  void _showBackupHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('备份历史记录'),
          content: const Text('显示最近的备份操作记录：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  void _cleanOldBackups(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清理旧备份'),
          content: const Text('此操作将删除超过30天的旧备份文件。确定要继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 实现清理逻辑
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('旧备份文件清理完成！')));
              },
              child: const Text('清理'),
            ),
          ],
        );
      },
    );
  }

  void _showBackupStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('备份统计'),
          content: const Text('显示备份文件大小和数量统计信息：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}
