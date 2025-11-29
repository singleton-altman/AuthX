import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/totp_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totpProvider = Provider.of<TotpProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07C160),
        elevation: 0,
        title: const Text(
          '安全设置',
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // 应用锁定
          _buildWeChatSettingsGroup(
            context,
            title: '应用锁定',
            children: [
              _buildWeChatSettingsItem(
                context,
                icon: Icons.lock,
                title: '应用锁定密码',
                subtitle: '设置应用启动密码',
                onTap: () {
                  // TODO: 实现应用锁定密码设置
                },
              ),
              _buildWeChatSettingsItem(
                context,
                icon: Icons.fingerprint,
                title: '生物识别',
                subtitle: '使用指纹或面部识别',
                onTap: () {
                  // TODO: 实现生物识别设置
                },
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 数据保护
          _buildWeChatSettingsGroup(
            context,
            title: '数据保护',
            children: [
              _buildWeChatSettingsItem(
                context,
                icon: Icons.enhanced_encryption,
                title: '数据加密',
                subtitle: '使用设备级加密存储',
                onTap: () {
                  // TODO: 实现数据加密设置
                },
              ),
              _buildWeChatSettingsItem(
                context,
                icon: Icons.timer,
                title: '自动锁定',
                subtitle: '应用在后台时自动锁定',
                onTap: () {
                  // TODO: 实现自动锁定设置
                },
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 导出与备份
          _buildWeChatSettingsGroup(
            context,
            title: '导出与备份',
            children: [
              _buildWeChatSettingsItem(
                context,
                icon: Icons.download,
                title: '导出数据',
                subtitle: '导出所有验证器数据',
                onTap: () {
                  // TODO: 实现数据导出
                },
              ),
              _buildWeChatSettingsItem(
                context,
                icon: Icons.upload,
                title: '导入数据',
                subtitle: '从备份文件导入数据',
                onTap: () {
                  // TODO: 实现数据导入
                },
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 隐私设置
          _buildWeChatSettingsGroup(
            context,
            title: '隐私设置',
            children: [
              _buildWeChatSettingsItem(
                context,
                icon: Icons.visibility_off,
                title: '隐藏验证码',
                subtitle: '默认隐藏验证码数字',
                onTap: () {
                  // TODO: 实现隐藏验证码设置
                },
              ),
              _buildWeChatSettingsItem(
                context,
                icon: Icons.screenshot,
                title: '防止截图',
                subtitle: '禁止在此页面截图',
                onTap: () {
                  // TODO: 实现防截图设置
                },
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 危险操作
          _buildWeChatSettingsGroup(
            context,
            title: '危险操作',
            children: [
              _buildWeChatSettingsItem(
                context,
                icon: Icons.delete_forever,
                title: '清除所有数据',
                subtitle: '删除所有验证器和设置',
                onTap: () => _showClearDataDialog(context, totpProvider),
                showDivider: false,
                isDanger: true,
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

  Widget _buildWeChatSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
    bool isDanger = false,
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
                color: isDanger ? Colors.red : const Color(0xFF07C160),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDanger ? Colors.red : Colors.black87,
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