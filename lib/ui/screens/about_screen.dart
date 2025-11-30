import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '关于',
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
              // 应用图标和名称
              _buildAppInfoCard(context),
              
              const SizedBox(height: 24),
              
              // 应用介绍
              _buildSectionCard(
                context,
                title: '应用介绍',
                child: Text(
                  'AuthX TOTP 是一个开源的双因素认证（2FA）应用程序，'
                  '支持基于时间的一次性密码（TOTP）标准 RFC 6238，'
                  '帮助您安全地保护您的在线账户。所有数据都安全地存储在您的设备上，'
                  '不会上传到任何服务器。',
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 功能特性
              _buildSectionCard(
                context,
                title: '功能特性',
                child: Column(
                  children: [
                    _buildFeatureItem(
                      context,
                      icon: Icons.qr_code_scanner_outlined,
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
                      icon: Icons.palette_outlined,
                      title: '主题设置',
                      description: '支持浅色、深色和系统主题模式',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 技术规格
              _buildSectionCard(
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
              _buildSectionCard(
                context,
                title: '开源信息',
                child: Text(
                  '本应用是开源软件，使用 MIT 许可证发布。\n'
                  '源代码可在 GitHub 上获取。',
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 版权信息
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Center(
                  child: Text(
                    '© ${DateTime.now().year} AuthX TOTP',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.security,
              size: 45,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AuthX TOTP',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '版本 1.0.0',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}