import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:authx/services/storage_service.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totpProvider = Provider.of<TotpProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('安全设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // 应用锁定
          _buildSettingsSection(
            context,
            title: '应用锁定',
            icon: Icons.lock_outline,
            children: _buildAppLockSettings(context),
          ),
          const SizedBox(height: 16),
          
          // 数据保护
          _buildSettingsSection(
            context,
            title: '数据保护',
            icon: Icons.security_outlined,
            children: _buildDataProtectionSettings(context, totpProvider),
          ),
          const SizedBox(height: 16),
          
          // 导出与备份
          _buildSettingsSection(
            context,
            title: '导出与备份',
            icon: Icons.backup_outlined,
            children: _buildBackupSettings(context, totpProvider),
          ),
          const SizedBox(height: 16),
          
          // 隐私设置
          _buildSettingsSection(
            context,
            title: '隐私设置',
            icon: Icons.privacy_tip_outlined,
            children: _buildPrivacySettings(context),
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

  List<Widget> _buildAppLockSettings(BuildContext context) {
    return [
      _buildSettingItem(
        context,
        title: '启用应用锁定',
        subtitle: '需要密码或生物识别才能访问应用',
        trailing: Switch(
          value: false, // 需要实现实际的存储逻辑
          onChanged: (value) {
            // 实现应用锁定逻辑
            _showAppLockSetupDialog(context, value);
          },
        ),
      ),
      _buildSettingItem(
        context,
        title: '锁定超时时间',
        subtitle: '应用在后台运行多久后自动锁定',
        trailing: Text(
          '立即锁定',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        onTap: () => _showLockTimeoutDialog(context),
      ),
    ];
  }

  List<Widget> _buildDataProtectionSettings(BuildContext context, TotpProvider totpProvider) {
    return [
      _buildSettingItem(
        context,
        title: '数据加密',
        subtitle: '使用AES-256加密存储敏感数据',
        trailing: const Icon(Icons.verified_user_outlined, color: Colors.green),
      ),
      _buildSettingItem(
        context,
        title: '自动清除剪贴板',
        subtitle: '复制验证码后30秒自动清除',
        trailing: Switch(
          value: true, // 需要实现实际的存储逻辑
          onChanged: (value) {
            // 实现剪贴板自动清除逻辑
          },
        ),
      ),
      _buildSettingItem(
        context,
        title: '屏幕截图保护',
        subtitle: '防止应用内容被截图',
        trailing: Switch(
          value: false, // 需要实现实际的存储逻辑
          onChanged: (value) {
            // 实现屏幕截图保护逻辑
          },
        ),
      ),
    ];
  }

  List<Widget> _buildBackupSettings(BuildContext context, TotpProvider totpProvider) {
    return [
      _buildSettingItem(
        context,
        title: '自动备份',
        subtitle: '定期自动备份数据到安全位置',
        trailing: Switch(
          value: false, // 需要实现实际的存储逻辑
          onChanged: (value) {
            // 实现自动备份逻辑
          },
        ),
      ),
      _buildSettingItem(
        context,
        title: '导出数据',
        subtitle: '导出所有2FA数据到加密文件',
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // 导航到导出页面
          Navigator.pushNamed(context, '/export');
        },
      ),
      _buildSettingItem(
        context,
        title: '导入数据',
        subtitle: '从备份文件导入2FA数据',
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // 导航到导入页面
          Navigator.pushNamed(context, '/import');
        },
      ),
    ];
  }

  List<Widget> _buildPrivacySettings(BuildContext context) {
    return [
      _buildSettingItem(
        context,
        title: '匿名使用统计',
        subtitle: '帮助改进应用（不包含个人数据）',
        trailing: Switch(
          value: true, // 需要实现实际的存储逻辑
          onChanged: (value) {
            // 实现使用统计逻辑
          },
        ),
      ),
      _buildSettingItem(
        context,
        title: '清除所有数据',
        subtitle: '永久删除所有2FA数据和设置',
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showClearDataDialog(context),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
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
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showAppLockSetupDialog(BuildContext context, bool enable) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(enable ? '设置应用锁定' : '禁用应用锁定'),
          content: Text(
            enable 
              ? '请设置应用锁定密码。您可以使用数字密码或生物识别（如指纹/面容ID）。'
              : '禁用应用锁定后，任何人都可以直接访问您的2FA数据。确定要禁用吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 实现应用锁定设置逻辑
                Navigator.of(context).pop();
              },
              child: Text(enable ? '设置' : '禁用'),
            ),
          ],
        );
      },
    );
  }

  void _showLockTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('锁定超时时间'),
          content: const Text('选择应用在后台运行多久后自动锁定：'),
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

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清除所有数据'),
          content: const Text('此操作将永久删除所有2FA数据和设置，且无法恢复。确定要继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 实现数据清除逻辑
                Navigator.of(context).pop();
              },
              child: const Text('清除'),
            ),
          ],
        );
      },
    );
  }
}