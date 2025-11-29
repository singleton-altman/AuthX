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
    final totpProvider = Provider.of<TotpProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07C160),
        elevation: 0,
        title: const Text(
          '备份与恢复',
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
          // 备份概览
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07C160).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.cloud_upload,
                        color: Color(0xFF07C160),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '数据概览',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '共 ${totpProvider.entries.length} 个验证器',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 手动操作
          _buildWeChatSettingsGroup(
            context,
            title: '手动操作',
            children: [
              _buildWeChatSettingsItem(
                context,
                icon: Icons.download,
                title: '导出数据',
                subtitle: '将所有验证器导出为文件',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExportScreen()),
                  );
                },
              ),
              _buildWeChatSettingsItem(
                context,
                icon: Icons.upload,
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
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 自动备份
          _buildWeChatSettingsGroup(
            context,
            title: '自动备份',
            children: [
              _buildWeChatSettingsItem(
                context,
                icon: Icons.schedule,
                title: '定期备份',
                subtitle: '每周自动备份到本地存储',
                onTap: () {
                  // TODO: 实现定期备份设置
                },
              ),
              _buildWeChatSettingsItem(
                context,
                icon: Icons.folder,
                title: '备份位置',
                subtitle: '查看和管理备份文件',
                onTap: () {
                  // TODO: 实现备份位置管理
                },
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 高级选项
          _buildWeChatSettingsGroup(
            context,
            title: '高级选项',
            children: [
              _buildWeChatSettingsItem(
                context,
                icon: Icons.qr_code,
                title: '生成备份二维码',
                subtitle: '将备份信息生成二维码',
                onTap: () {
                  // TODO: 实现二维码备份
                },
              ),
              _buildWeChatSettingsItem(
                context,
                icon: Icons.security,
                title: '加密备份',
                subtitle: '使用密码保护备份文件',
                onTap: () {
                  // TODO: 实现加密备份
                },
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

  Widget _buildWeChatSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
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
}