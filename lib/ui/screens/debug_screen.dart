import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/services/totp_service.dart';
import 'package:authx/ui/screens/totp_display_screen.dart';

import 'package:authx/utils/base32.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _totpCode = '';
  int _remainingTime = 0;
  String _error = '';
  String _base32Info = '';
  String _counterInfo = '';

  final TextEditingController _secretController = TextEditingController(text: 'JBSWY3DPEHPK3PXP');
  final TextEditingController _nameController = TextEditingController(text: '测试账户');
  final TextEditingController _issuerController = TextEditingController(text: 'AuthX');
  final TextEditingController _digitsController = TextEditingController(text: '6');
  final TextEditingController _periodController = TextEditingController(text: '30');
  final TextEditingController _algorithmController = TextEditingController(text: 'SHA1');

  void _generateTotp() {
    setState(() {
      _error = '';
      _totpCode = '';
      _remainingTime = 0;
      _counterInfo = '';
      _base32Info = '';
    });
    
    try {
      final secret = _secretController.text.trim();
      if (secret.isEmpty) {
        setState(() {
          _error = '密钥不能为空';
        });
        return;
      }
      
      // 验证Base32编码
      try {
        final decoded = Base32.decode(secret);
        _base32Info = 'Base32验证通过，解码后长度: ${decoded.length} 字节';
      } catch (e) {
        setState(() {
          _error = 'Base32解码失败: $e';
        });
        return;
      }
      
      final entry = TotpEntry(
        id: 'debug',
        name: _nameController.text.trim(),
        issuer: _issuerController.text.trim(),
        secret: secret,
        digits: int.tryParse(_digitsController.text) ?? 6,
        period: int.tryParse(_periodController.text) ?? 30,
        algorithm: _algorithmController.text.trim(),
      );
      
      // 计算当前计数器
      final counter = (DateTime.now().millisecondsSinceEpoch ~/ 1000) ~/ entry.period;
      _counterInfo = '当前计数器: $counter';
      
      setState(() {
        _totpCode = TotpService.generateTotp(entry);
        _remainingTime = TotpService.getRemainingTime(entry);
      });
    } catch (e) {
      setState(() {
        _error = '生成TOTP失败: $e';
      });
    }
  }

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
          'TOTP 调试',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // TOTP生成器
            _buildDebugCard(
              context,
              title: 'TOTP生成器',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    context,
                    controller: _nameController,
                    labelText: '账户名',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    context,
                    controller: _issuerController,
                    labelText: '发行方',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    context,
                    controller: _secretController,
                    labelText: '密钥 (Base32)',
                    hintText: '例如: JBSWY3DPEHPK3PXP',
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          controller: _digitsController,
                          labelText: '位数',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          context,
                          controller: _periodController,
                          labelText: '周期(秒)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    context,
                    controller: _algorithmController,
                    labelText: '算法',
                    hintText: '例如: SHA1, SHA256, SHA512',
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _generateTotp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('生成TOTP'),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (_error.isNotEmpty) ...[
                    _buildResultSection(
                      context,
                      title: '错误',
                      content: _error,
                      isError: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (_totpCode.isNotEmpty) ...[
                    _buildResultSection(
                      context,
                      title: '生成的TOTP码',
                      content: _totpCode,
                      isCode: true,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildResultSection(
                      context,
                      title: '剩余时间',
                      content: '$_remainingTime 秒',
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (_base32Info.isNotEmpty) ...[
                    _buildResultSection(
                      context,
                      title: 'Base32信息',
                      content: _base32Info,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (_counterInfo.isNotEmpty) ...[
                    _buildResultSection(
                      context,
                      title: '计数器信息',
                      content: _counterInfo,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 测试用例
            _buildDebugCard(
              context,
              title: '测试用例',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem(
                    context,
                    title: '常用测试密钥',
                    items: [
                      'JBSWY3DPEHPK3PXP (标准测试密钥)',
                      'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ (RFC测试密钥)',
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildInfoItem(
                    context,
                    title: 'RFC测试预期结果',
                    items: [
                      'SHA1: 94287082 (8位)',
                      'SHA256: 46119246 (8位)',
                      'SHA512: 90693936 (8位)',
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildInfoItem(
                    context,
                    title: '常见测试结果',
                    items: [
                      'JBSWY3DPEHPK3PXP 通常生成以 287082 开头的6位码',
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 演示账户
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final entry = TotpEntry(
                    id: 'demo',
                    name: '演示账户',
                    issuer: 'AuthX',
                    secret: 'JBSWY3DPEHPK3PXP',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TotpDisplayScreen(entry: entry),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text('查看演示账户'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDebugCard(
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildResultSection(
    BuildContext context, {
    required String title,
    required String content,
    bool isError = false,
    bool isCode = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError 
            ? Colors.red.withValues(alpha: 0.1)
            : theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError 
              ? Colors.red.withValues(alpha: 0.3)
              : theme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isError 
                  ? Colors.red
                  : theme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (isCode)
            Center(
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 4,
                ),
              ),
            )
          else
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '• $item',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        )),
      ],
    );
  }

  @override
  void dispose() {
    _secretController.dispose();
    _nameController.dispose();
    _issuerController.dispose();
    _digitsController.dispose();
    _periodController.dispose();
    _algorithmController.dispose();
    super.dispose();
  }
}
