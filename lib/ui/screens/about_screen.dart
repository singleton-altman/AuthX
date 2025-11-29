import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07C160),
        elevation: 0,
        title: const Text(
          '关于',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // 应用图标和名称
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07C160).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 40,
                      color: Color(0xFF07C160),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AuthX TOTP',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '版本 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 应用介绍
            _buildWeChatSection(
              title: '应用介绍',
              child: const Text(
                'AuthX TOTP 是一个开源的双因素认证（2FA）应用程序，'
                '支持基于时间的一次性密码（TOTP）标准 RFC 6238，'
                '帮助您安全地保护您的在线账户。所有数据都安全地存储在您的设备上，'
                '不会上传到任何服务器。',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 功能特性
            _buildWeChatSection(
              title: '功能特性',
              child: Column(
                children: [
                  _buildWeChatFeatureItem(
                    icon: Icons.qr_code_scanner,
                    title: '二维码扫描',
                    description: '通过扫描二维码快速添加账户',
                  ),
                  _buildWeChatFeatureItem(
                    icon: Icons.edit,
                    title: '手动添加',
                    description: '手动输入账户信息和密钥添加验证器',
                  ),
                  _buildWeChatFeatureItem(
                    icon: Icons.content_paste,
                    title: '剪贴板导入',
                    description: '自动检测并导入剪贴板中的 TOTP 链接',
                  ),
                  _buildWeChatFeatureItem(
                    icon: Icons.link,
                    title: 'URI 导入',
                    description: '通过 otpauth:// URI 格式导入账户',
                  ),
                  _buildWeChatFeatureItem(
                    icon: Icons.image,
                    title: '自定义图标',
                    description: '支持网络图片链接或 Base64 编码图片作为账户图标',
                  ),
                  _buildWeChatFeatureItem(
                    icon: Icons.palette,
                    title: '主题设置',
                    description: '支持浅色、深色和系统主题模式',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 技术规格
            _buildWeChatSection(
              title: '技术规格',
              child: Column(
                children: [
                  _buildWeChatSpecItem(
                    title: '算法支持',
                    description: 'SHA1、SHA256、SHA512',
                  ),
                  _buildWeChatSpecItem(
                    title: '验证码位数',
                    description: '6 位或 8 位',
                  ),
                  _buildWeChatSpecItem(
                    title: '更新周期',
                    description: '默认 30 秒',
                  ),
                  _buildWeChatSpecItem(
                    title: '安全存储',
                    description: '设备级加密存储',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 开源信息
            _buildWeChatSection(
              title: '开源信息',
              child: const Text(
                '本应用是开源软件，使用 MIT 许可证发布。\n'
                '源代码可在 GitHub 上获取。',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 版权信息
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '© ${DateTime.now().year} AuthX TOTP',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWeChatSection({
    required String title,
    required Widget child,
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
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildWeChatFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF07C160).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF07C160),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
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

  Widget _buildWeChatSpecItem({
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF07C160),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}