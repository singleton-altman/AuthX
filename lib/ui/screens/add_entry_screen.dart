
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:flutter/services.dart';
import 'package:authx/utils/totp_parser.dart';
import 'package:authx/utils/base32.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _secretController = TextEditingController();
  final _iconController = TextEditingController(); // 图标输入控制器
  final _tagController = TextEditingController(); // 标签输入控制器
  final List<String> _tags = []; // 标签列表
  


  // 添加标签
  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  // 删除标签
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _secretController.dispose();
    _iconController.dispose(); // 释放图标控制器
    _tagController.dispose(); // 释放标签控制器
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String id = _generateId();
      final String name = _nameController.text.trim();
      final String issuer = _issuerController.text.trim();
      final String secret = _secretController.text.trim().replaceAll(' ', '');
      final String icon = _iconController.text.trim(); // 获取图标链接
      final List<String> tags = _tags; // 获取标签列表
      
      final TotpEntry entry = TotpEntry(
        id: id,
        name: name,
        issuer: issuer,
        secret: secret,
        icon: icon, // 添加图标字段
        tags: tags, // 添加标签列表
      );
      
      final TotpProvider provider = Provider.of<TotpProvider>(context, listen: false);
      provider.addEntry(entry).then((_) {
        if (mounted) {
          Navigator.of(context).pop(true); // 返回true表示添加成功
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加失败: $error')),
          );
        }
      });
    }
  }

  String _generateId() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           random.nextInt(10000).toString();
  }



  void _checkClipboardForTotpUri() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? uri = data?.text;
    
    if (uri != null && uri.startsWith('otpauth://') && mounted) {
      try {
        final parsed = TotpParser.parseUri(uri);
        _nameController.text = parsed.name;
        _issuerController.text = parsed.issuer;
        _secretController.text = parsed.secret;
        

        
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('剪贴板中的内容无法解析: $e')),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('剪贴板中未找到有效的TOTP URI')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加验证器'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: _checkClipboardForTotpUri,
            tooltip: '从剪贴板导入',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // 图标输入框
              TextFormField(
                controller: _iconController,
                decoration: InputDecoration(
                  labelText: '图标',
                  hintText: '支持图床链接或base64编码图片',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 多标签输入区域
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '标签',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 标签输入和添加按钮
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            hintText: '输入标签后按回车添加',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            _addTag(value.trim());
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final tag = _tagController.text.trim();
                          if (tag.isNotEmpty) {
                            _addTag(tag);
                          }
                        },
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 标签显示区域
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                      )).toList(),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 发行方输入框
              TextFormField(
                controller: _issuerController,
                decoration: InputDecoration(
                  labelText: '发行方',
                  hintText: '例如：Google',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入发行方';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '账户',
                  hintText: '例如：user@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入账户名';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _secretController,
                decoration: InputDecoration(
                  labelText: '密钥',
                  hintText: '例如：JBSWY3DPEHPK3PXP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入密钥';
                  }
                  // 简单验证Base32格式
                  if (!RegExp(r'^[A-Z2-7]+=*$').hasMatch(value.trim().toUpperCase())) {
                    return '密钥格式不正确';
                  }
                  
                  // 尝试解码以验证密钥有效性
                  try {
                    Base32.decode(value.trim().toUpperCase());
                  } catch (e) {
                    return '密钥格式无效: $e';
                  }
                  
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '添加验证器',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}