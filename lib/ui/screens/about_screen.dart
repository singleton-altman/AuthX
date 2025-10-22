import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('关于'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 应用图标和名称
            Container(
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/icon.png', width: 100, height: 100),
            ),
            const SizedBox(height: 16),
            const Text(
              'AuthX TOTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              '版本 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // 应用介绍
            _buildSection(
              context,
              title: '应用介绍',
              child: const Text(
                'AuthX TOTP 是一个开源的双因素认证（2FA）应用程序，'
                '支持基于时间的一次性密码（TOTP）标准 RFC 6238，'
                '帮助您安全地保护您的在线账户。所有数据都安全地存储在您的设备上，'
                '不会上传到任何服务器。',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),

            const SizedBox(height: 24),

            // 功能特性
            _buildSection(
              context,
              title: '功能特性',
              child: Column(
                children: [
                  _buildFeatureItem(
                    context,
                    icon: Icons.qr_code_outlined,
                    title: '二维码扫描',
                    description: '通过扫描二维码快速添加账户',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.edit_outlined,
                    title: '手动添加',
                    description: '手动输入账户信息和密钥添加验证器',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.content_paste_outlined,
                    title: '剪贴板导入',
                    description: '自动检测并导入剪贴板中的 TOTP 链接',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.link_outlined,
                    title: 'URI 导入',
                    description: '通过 otpauth:// URI 格式导入账户',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.image_outlined,
                    title: '自定义图标',
                    description: '支持网络图片链接或 Base64 编码图片作为账户图标',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.color_lens_outlined,
                    title: '主题设置',
                    description: '支持浅色、深色和系统主题模式',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 技术规格
            _buildSection(
              context,
              title: '技术规格',
              child: Column(
                children: [
                  _buildSpecItem(
                    context,
                    title: '算法支持',
                    description: 'SHA1、SHA256、SHA512',
                  ),
                  _buildSpecItem(
                    context,
                    title: '验证码位数',
                    description: '6 位或 8 位',
                  ),
                  _buildSpecItem(
                    context,
                    title: '更新周期',
                    description: '默认 30 秒',
                  ),
                  _buildSpecItem(
                    context,
                    title: '安全存储',
                    description: '设备级加密存储',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 开源信息
            _buildSection(
              context,
              title: '开源信息',
              child: const Text(
                '本应用是开源软件，使用 MIT 许可证发布。\n'
                '源代码可在 GitHub 上获取。',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                '© ${DateTime.now().year} AuthX TOTP',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
