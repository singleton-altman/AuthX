import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/providers/totp_provider.dart';
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

      final TotpProvider provider = Provider.of<TotpProvider>(
        context,
        listen: false,
      );
      provider
          .addEntry(entry)
          .then((_) {
            if (mounted) {
              Navigator.of(context).pop(true); // 返回true表示添加成功
            }
          })
          .catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('添加失败: $error')));
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('剪贴板中的内容无法解析: $e')));
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('剪贴板中未找到有效的TOTP URI')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          '添加验证器',
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
        actions: [
          IconButton(
            icon: Icon(Icons.content_paste, color: theme.colorScheme.onSurface),
            onPressed: _checkClipboardForTotpUri,
            tooltip: '从剪贴板导入',
          ),
        ],
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 发行方输入框
                _buildInputCard(
                  context: context,
                  controller: _issuerController,
                  labelText: '发行方',
                  hintText: '例如：Google',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入发行方';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // 账户输入框
                _buildInputCard(
                  context: context,
                  controller: _nameController,
                  labelText: '账户',
                  hintText: '例如：user@example.com',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入账户名';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // 密钥输入框
                _buildInputCard(
                  context: context,
                  controller: _secretController,
                  labelText: '密钥',
                  hintText: '例如：JBSWY3DPEHPK3PXP',
                  icon: Icons.vpn_key,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入密钥';
                    }
                    if (!RegExp(
                      r'^[A-Z2-7]+=*$',
                    ).hasMatch(value.trim().toUpperCase())) {
                      return '密钥格式不正确';
                    }
                    try {
                      Base32.decode(value.trim().toUpperCase());
                    } catch (e) {
                      return '密钥格式无效: $e';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 图标输入框和示例按钮
                _buildInputCard(
                  context: context,
                  controller: _iconController,
                  labelText: '图标链接 (可选)',
                  hintText: '支持图床链接或base64编码图片',
                  icon: Icons.image,
                ),

                const SizedBox(height: 12),

                // 示例按钮
                _buildExampleButtons(context),

                const SizedBox(height: 20),

                // 标签输入区域
                _buildTagsSection(context),

                const SizedBox(height: 30),

                // 提交按钮
                _buildSubmitButton(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
                validator: validator,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildOutlineButton(
            context: context,
            icon: Icons.link,
            label: '网络图片',
            onPressed: () {
              _iconController.text =
                  'https://via.placeholder.com/100x100/07C160/FFFFFF?text=APP';
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOutlineButton(
            context: context,
            icon: Icons.image,
            label: 'Base64图片',
            onPressed: () {
              _iconController.text =
                  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOutlineButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: theme.primaryColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: theme.primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  '标签 (可选)',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          hintText: '输入标签后按回车',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        onFieldSubmitted: (value) {
                          _addTag(value.trim());
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final tag = _tagController.text.trim();
                      if (tag.isNotEmpty) {
                        _addTag(tag);
                      }
                    },
                    icon: Icon(
                      Icons.add,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeTag(tag),
                              child: Icon(
                                Icons.close,
                                color: theme.primaryColor,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitForm,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              '添加验证器',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
