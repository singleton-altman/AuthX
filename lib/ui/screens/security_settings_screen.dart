import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/totp_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

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
          '安全设置',
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
              // 应用锁定
              _buildSettingsCard(context, title: '应用锁定', children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.lock_outline,
                  title: '应用锁定密码',
                  subtitle: '设置应用启动密码',
                  onTap: () {
                    // TODO: 实现应用锁定密码设置
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.fingerprint_outlined,
                  title: '生物识别',
                  subtitle: '使用指纹或面部识别',
                  onTap: () {
                    // TODO: 实现生物识别设置
                  },
                  showDivider: false,
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // 数据保护
              _buildSettingsCard(context, title: '数据保护', children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.enhanced_encryption_outlined,
                  title: '数据加密',
                  subtitle: '使用设备级加密存储',
                  onTap: () {
                    // TODO: 实现数据加密设置
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.timer_outlined,
                  title: '自动锁定',
                  subtitle: '应用在后台时自动锁定',
                  onTap: () {
                    // TODO: 实现自动锁定设置
                  },
                  showDivider: false,
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // 隐私设置
              _buildSettingsCard(context, title: '隐私设置', children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.visibility_off_outlined,
                  title: '隐藏验证码',
                  subtitle: '默认隐藏验证码数字',
                  onTap: () {
                    // TODO: 实现隐藏验证码设置
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.screenshot_outlined,
                  title: '防止截图',
                  subtitle: '禁止在此页面截图',
                  onTap: () {
                    // TODO: 实现防截图设置
                  },
                  showDivider: false,
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // 危险操作
              _buildSettingsCard(context, title: '危险操作', children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.delete_forever_outlined,
                  title: '清除所有数据',
                  subtitle: '删除所有验证器和设置',
                  onTap: () => _showClearDataDialog(context, totpProvider),
                  showDivider: false,
                  isDanger: true,
                ),
              ]),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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
    bool isDanger = false,
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
                  color: isDanger 
                      ? Colors.red.withValues(alpha: 0.1)
                      : theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDanger ? Colors.red : theme.primaryColor,
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
                        color: isDanger 
                            ? Colors.red
                            : theme.colorScheme.onSurface,
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

  void _showClearDataDialog(BuildContext context, TotpProvider totpProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清除所有数据'),
          content: const Text(
            '此操作将删除所有验证器和设置，且无法撤销。\n\n确定要继续吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await totpProvider.clearAllEntries();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('所有数据已清除'),
                        backgroundColor: Color(0xFF07C160),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('清除失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('确定清除'),
            ),
          ],
        );
      },
    );
  }
}