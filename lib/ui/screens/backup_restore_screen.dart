import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:authx/ui/screens/export_screen.dart';
import 'package:authx/ui/screens/simple_import_screen.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totpProvider = Provider.of<TotpProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '备份与恢复',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 备份概览
              _buildOverviewCard(context, totpProvider),
              
              const SizedBox(height: 24),
              
              // 手动操作
              _buildSettingsCard(context, title: '手动操作', children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.download_outlined,
                  title: '导出数据',
                  subtitle: '将所有验证器导出为文件',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExportScreen()),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.upload_outlined,
                  title: '导入数据',
                  subtitle: '从备份文件恢复验证器',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SimpleImportScreen()),
                    );
                  },
                  showDivider: false,
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // 自动备份
              _buildSettingsCard(context, title: '自动备份', children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.schedule_outlined,
                  title: '定期备份',
                  subtitle: '每周自动备份到本地存储',
                  onTap: () {
                    // TODO: 实现定期备份设置
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.folder_outlined,
                  title: '备份位置',
                  subtitle: '查看和管理备份文件',
                  onTap: () {
                    // TODO: 实现备份位置管理
                  },
                  showDivider: false,
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // 高级选项
              _buildSettingsCard(context, title: '高级选项', children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.qr_code_2_outlined,
                  title: '生成备份二维码',
                  subtitle: '将备份信息生成二维码',
                  onTap: () {
                    // TODO: 实现二维码备份
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.security_outlined,
                  title: '加密备份',
                  subtitle: '使用密码保护备份文件',
                  onTap: () {
                    // TODO: 实现加密备份
                  },
                  showDivider: false,
                ),
              ]),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, TotpProvider totpProvider) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05,
            ),
            blurRadius: theme.brightness == Brightness.dark ? 0 : 10,
            offset: theme.brightness == Brightness.dark
                ? Offset.zero
                : const Offset(0, 2),
          ),
        ],
        border: theme.brightness == Brightness.dark
            ? Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 图标容器
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  color: theme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              
              // 统计信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '数据概览',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatItem(
                          context,
                          count: totpProvider.entries.length.toString(),
                          label: '验证器',
                        ),
                        const SizedBox(width: 24),
                        _buildStatItem(
                          context,
                          count: '${DateTime.now().month}月${DateTime.now().day}日',
                          label: '今日',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String count, required String label}) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05,
            ),
            blurRadius: theme.brightness == Brightness.dark ? 0 : 10,
            offset: theme.brightness == Brightness.dark
                ? Offset.zero
                : const Offset(0, 2),
          ),
        ],
        border: theme.brightness == Brightness.dark
            ? Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // 文字内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 箭头图标
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}