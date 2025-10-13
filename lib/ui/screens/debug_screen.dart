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
  bool _rfcTestPassed = false;

  @override
  void initState() {
    super.initState();
    _rfcTestPassed = _runRfcTestCases();
  }

  bool _runRfcTestCases() {
    try {
      final testCases = [
        {
          'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          'counter': 1,
          'algorithm': 'SHA1',
          'expected': '94287082'
        },
        {
          'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          'counter': 1,
          'algorithm': 'SHA256',
          'expected': '46119246'
        },
        {
          'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          'counter': 1,
          'algorithm': 'SHA512',
          'expected': '90693936'
        }
      ];

      for (final test in testCases) {
        // 使用固定时间戳59秒来测试RFC用例
        final entry = TotpEntry(
          id: 'test',
          name: 'Test',
          issuer: 'Test',
          secret: test['secret'] as String,
          algorithm: test['algorithm'] as String,
          digits: 8,
          period: 30,
        );
        
        // 模拟RFC测试时间点(59秒)
        final testTime = DateTime.fromMillisecondsSinceEpoch(1000 * 59);
        final testCode = TotpService.generateTotpAtTime(entry, testTime);
        if (testCode != test['expected']) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void _runRfcTests() {
    setState(() {
      _rfcTestPassed = _runRfcTestCases();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _rfcTestPassed 
              ? 'RFC测试通过!' 
              : 'RFC测试失败，请检查实现',
          ),
          backgroundColor: _rfcTestPassed ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTP 调试'),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        children: [
          Card(
            child: InkWell(
              onTap: () {
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 40),
                    SizedBox(height: 8),
                    Text('演示验证码'),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: _runRfcTests,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, size: 40),
                    SizedBox(height: 8),
                    Text('RFC测试'),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _DebugDetailScreen(),
                  ),
                );
              },
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 40),
                    SizedBox(height: 8),
                    Text('高级调试'),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _TestCasesScreen(),
                  ),
                );
              },
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt, size: 40),
                    SizedBox(height: 8),
                    Text('测试用例'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 测试用例界面
class _TestCasesScreen extends StatelessWidget {
  const _TestCasesScreen();

  @override
  Widget build(BuildContext context) {
    final testCases = [
      {
        'name': 'RFC测试用例1',
        'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
        'counter': 1,
        'algorithm': 'SHA1',
        'digits': 8,
        'expected': '94287082',
        'time': 59,
      },
      {
        'name': 'RFC测试用例2',
        'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
        'counter': 1,
        'algorithm': 'SHA256',
        'digits': 8,
        'expected': '46119246',
        'time': 59,
      },
      {
        'name': 'RFC测试用例3',
        'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
        'counter': 1,
        'algorithm': 'SHA512',
        'digits': 8,
        'expected': '90693936',
        'time': 59,
      },
      {
        'name': '常见测试用例',
        'secret': 'JBSWY3DPEHPK3PXP',
        'counter': 1,
        'algorithm': 'SHA1',
        'digits': 6,
        'expected': '287082',
        'time': 59,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('测试用例'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: testCases.length,
        itemBuilder: (context, index) {
          final testCase = testCases[index];
          final entry = TotpEntry(
            id: 'test-${index}',
            name: testCase['name'] as String,
            issuer: 'Test',
            secret: testCase['secret'] as String,
            algorithm: testCase['algorithm'] as String,
            digits: testCase['digits'] as int,
            period: 30,
          );
          
          final testTime = DateTime.fromMillisecondsSinceEpoch(1000 * (testCase['time'] as int));
          final result = TotpService.generateTotpAtTime(entry, testTime);
          final passed = result == testCase['expected'];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        passed ? Icons.check_circle : Icons.error,
                        color: passed ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        testCase['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('密钥: ${testCase['secret']}'),
                  Text('算法: ${testCase['algorithm']}'),
                  Text('位数: ${testCase['digits']}'),
                  Text('时间: ${testCase['time']}秒'),
                  Text('预期结果: ${testCase['expected']}'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: passed ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Text('实际结果: '),
                        Text(
                          result,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          passed ? '通过' : '失败',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: passed ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 调试详情界面
class _DebugDetailScreen extends StatefulWidget {
  const _DebugDetailScreen();

  @override
  State<_DebugDetailScreen> createState() => _DebugDetailScreenState();
}

class _DebugDetailScreenState extends State<_DebugDetailScreen> {
  final _secretController = TextEditingController();
  final _digitsController = TextEditingController(text: '6');
  final _periodController = TextEditingController(text: '30');
  final _algorithmController = TextEditingController(text: 'SHA1');
  final _issuerController = TextEditingController(text: 'Debug');
  final _nameController = TextEditingController(text: 'Test Account');
  
  String _totpCode = '';
  int _remainingTime = 0;
  String _error = '';
  bool _rfcTestPassed = false;
  String _counterInfo = '';
  String _base32Info = '';

  @override
  void initState() {
    super.initState();
    _rfcTestPassed = _runRfcTestCases();
  }

  @override
  void dispose() {
    _secretController.dispose();
    _digitsController.dispose();
    _periodController.dispose();
    _algorithmController.dispose();
    _issuerController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _runRfcTestCases() {
    try {
      final testCases = [
        {
          'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          'counter': 1,
          'algorithm': 'SHA1',
          'expected': '94287082'
        },
        {
          'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          'counter': 1,
          'algorithm': 'SHA256',
          'expected': '46119246'
        },
        {
          'secret': 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          'counter': 1,
          'algorithm': 'SHA512',
          'expected': '90693936'
        }
      ];

      for (final test in testCases) {
        final entry = TotpEntry(
          id: 'test',
          name: 'Test',
          issuer: 'Test',
          secret: test['secret'] as String,
          algorithm: test['algorithm'] as String,
          digits: 8,
          period: 30,
        );
        
        final testTime = DateTime.fromMillisecondsSinceEpoch(1000 * 59);
        final testCode = TotpService.generateTotpAtTime(entry, testTime);
        if (testCode != test['expected']) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

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

  void _runRfcTests() {
    setState(() {
      _rfcTestPassed = _runRfcTestCases();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _rfcTestPassed 
              ? 'RFC测试通过!' 
              : 'RFC测试失败，请检查实现',
          ),
          backgroundColor: _rfcTestPassed ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTP 调试'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateTotp,
                    child: const Text('生成TOTP'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runRfcTests,
                    child: const Text('运行RFC测试'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _rfcTestPassed ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _rfcTestPassed ? Icons.check_circle : Icons.error,
                    color: _rfcTestPassed ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _rfcTestPassed 
                      ? 'RFC测试已通过' 
                      : 'RFC测试未通过',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _rfcTestPassed ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
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
            
            if (_error.isNotEmpty) ...[
              const Text('错误:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              Text(_error),
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
            
            const Divider(),
            const Text('测试用例:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('密钥: JBSWY3DPEHPK3PXP'),
            const Text('预期结果: 通常以 287082 开头'),
            const SizedBox(height: 8),
            const Text('RFC测试用例:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('密钥: GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'),
            const Text('计数器: 1'),
            const Text('SHA1预期结果: 94287082'),
            const Text('SHA256预期结果: 46119246'),
            const Text('SHA512预期结果: 90693936'),
          ],
        ),
      ),
    );
  }
}