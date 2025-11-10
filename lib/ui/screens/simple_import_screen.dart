import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:authx/utils/totp_parser.dart';

class SimpleImportScreen extends StatefulWidget {
  const SimpleImportScreen({super.key});

  @override
  State<SimpleImportScreen> createState() => _SimpleImportScreenState();
}

class _SimpleImportScreenState extends State<SimpleImportScreen> {
  final _uriController = TextEditingController();
  
  bool _isProcessing = false;
  String? _errorMessage;
  bool _showEmptyFieldError = false; // 用于控制空字段错误提示

  @override
  void initState() {
    super.initState();
    // 添加监听器以实时调整输入框大小
    _uriController.addListener(_updateInputFieldSize);
  }

  @override
  void dispose() {
    _uriController.removeListener(_updateInputFieldSize);
    _uriController.dispose();
    super.dispose();
  }

  void _updateInputFieldSize() {
    // 状态更新会触发重建，从而调整输入框大小
    setState(() {});
  }

  void _submitForm() async {
    // 检查输入框是否为空
    if (_uriController.text.trim().isEmpty) {
      setState(() {
        _showEmptyFieldError = true;
      });
      return;
    }
    
    // 如果输入框不为空，则清除错误提示
    setState(() {
      _showEmptyFieldError = false;
    });

    // 移除对_formKey.currentState的依赖，直接进行验证
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // 分割输入内容为多行
      final lines = _uriController.text.trim().split('\n');
      final validUris = lines.where((line) => line.trim().isNotEmpty).toList();
      
      if (validUris.isEmpty) {
        throw Exception('没有找到有效的URI');
      }

      int successCount = 0;
      int failCount = 0;
      final failedUris = <String>[];

      // 逐个解析和导入URI
      for (int i = 0; i < validUris.length; i++) {
        try {
          final uri = validUris[i].trim();
          if (!uri.startsWith('otpauth://totp/')) {
            throw Exception('不支持的导入格式');
          }
          
          // 解析URI
          final parsed = TotpParser.parseUri(uri);
          
          // 创建TOTP条目
          final entry = TotpEntry(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            name: parsed.name,
            issuer: parsed.issuer,
            secret: parsed.secret,
            digits: parsed.digits,
            algorithm: parsed.algorithm,
            period: parsed.period,
            icon: parsed.icon,
          );
          
          // 保存到存储
          final provider = Provider.of<TotpProvider>(context, listen: false);
          await provider.addEntry(entry);
          successCount++;
        } catch (e) {
          failCount++;
          failedUris.add('第${i + 1}行: ${e.toString()}');
        }
      }

      if (mounted) {
        // 显示导入结果
        String message;
        if (failCount == 0) {
          message = '成功导入 $successCount 个验证器';
        } else if (successCount == 0) {
          message = '导入失败: 所有条目都无法解析';
        } else {
          message = '成功导入 $successCount 个验证器，$failCount 个失败';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        
        // 如果有失败的URI，显示详细信息
        if (failedUris.isNotEmpty) {
          setState(() {
            _errorMessage = '部分导入失败:\n${failedUris.join('\n')}';
          });
        }
        
        // 如果至少有一个成功，返回成功结果
        if (successCount > 0) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '导入失败: ${e.toString()}';
      });
      
      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 计算输入框的行数，基于内容动态调整
    int lines = _uriController.text.isEmpty ? 1 : _uriController.text.split('\n').length;
    // 限制最小和最大行数
    int displayLines = lines < 5 ? 5 : (lines > 20 ? 20 : lines);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入验证器'),
        centerTitle: true,
        actions: [
          // 将导入按钮放置在右上角
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Transform.rotate(
                      angle: -1.5708, // -90度 (逆时针)
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView( // 添加滚动视图
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _uriController,
              decoration: InputDecoration(
                labelText: '粘贴导入内容',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                // 当_showEmptyFieldError为true时显示红色边框
                enabledBorder: _showEmptyFieldError 
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    )
                  : null,
                focusedBorder: _showEmptyFieldError 
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    )
                  : null,
              ),
              maxLines: null, // 允许自动扩展行数
              minLines: displayLines, // 最小显示行数
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
            
            // 显示空字段错误提示
            if (_showEmptyFieldError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  '请输入导入内容',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            
            const SizedBox(height: 24),
            
            const Text(
              '支持的导入格式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• TOTP URI (otpauth://totp/...)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              '• 包含密钥、发行方和账户名的标准URI',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              '• 支持自定义位数、算法和周期参数',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              '• 支持图标参数',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              '• 支持批量导入，每行一个URI',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}