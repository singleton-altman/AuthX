import 'package:flutter/material.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/services/totp_service.dart';
import 'package:authx/ui/screens/totp_display_screen.dart';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTP 调试'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // TOTP生成器
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTP生成器',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '账户名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _issuerController,
                      decoration: const InputDecoration(
                        labelText: '发行方',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _secretController,
                      decoration: const InputDecoration(
                        labelText: '密钥 (Base32)',
                        hintText: '例如: JBSWY3DPEHPK3PXP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _digitsController,
                            decoration: const InputDecoration(
                              labelText: '位数',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _periodController,
                            decoration: const InputDecoration(
                              labelText: '周期(秒)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _algorithmController,
                      decoration: const InputDecoration(
                        labelText: '算法',
                        hintText: '例如: SHA1, SHA256, SHA512',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: _generateTotp,
                      child: const Text('生成TOTP'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (_error.isNotEmpty) ...[
                      const Text('错误:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text(_error),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_totpCode.isNotEmpty) ...[
                      const Text('生成的TOTP码:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Center(
                        child: Text(
                          _totpCode,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      const Text('剩余时间:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$_remainingTime 秒'),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_base32Info.isNotEmpty) ...[
                      const Text('Base32信息:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_base32Info),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_counterInfo.isNotEmpty) ...[
                      const Text('计数器信息:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_counterInfo),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 测试用例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '测试用例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('常用测试密钥:'),
                    const Text('• JBSWY3DPEHPK3PXP (标准测试密钥)'),
                    const Text('• GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ (RFC测试密钥)'),
                    const SizedBox(height: 16),
                    
                    const Text('RFC测试预期结果:'),
                    const Text('• SHA1: 94287082 (8位)'),
                    const Text('• SHA256: 46119246 (8位)'),
                    const Text('• SHA512: 90693936 (8位)'),
                    const SizedBox(height: 16),
                    
                    const Text('常见测试结果:'),
                    const Text('• JBSWY3DPEHPK3PXP 通常生成以 287082 开头的6位码'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 演示账户
            Center(
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
                icon: const Icon(Icons.qr_code),
                label: const Text('查看演示账户'),
              ),
            ),
          ],
        ),
      ),
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
