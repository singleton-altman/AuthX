import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:authx/services/totp_service.dart';

class TotpDisplayScreen extends StatefulWidget {
  final TotpEntry entry;

  const TotpDisplayScreen({super.key, required this.entry});

  @override
  State<TotpDisplayScreen> createState() => _TotpDisplayScreenState();
}

class _TotpDisplayScreenState extends State<TotpDisplayScreen> {
  bool _showOverlay = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _editEntry(BuildContext context) {
    if (!mounted) return;

    Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditEntryScreen(entry: widget.entry),
          ),
        )
        .then((result) {
          if (!mounted) return;

          if (result == true) {
            if (mounted) {
              setState(() {
                // 可以在这里触发任何需要的状态更新
              });
            }
          }
        })
        .catchError((error) {
          if (!mounted) return;

          if (mounted) {
            setState(() {
              // 可以在这里更新错误状态
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.entry.issuer.isNotEmpty ? widget.entry.issuer : '验证码',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showOverlay ? Icons.close : Icons.more_horiz,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _showOverlay = !_showOverlay;
              });
            },
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          // 主要内容 - 整合式设计
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 头部区域 - 静态内容，不需要重建
                  _buildHeaderSection(),

                  // 验证码显示区域 - 只有这部分需要动态更新
                  _buildTotpSection(),
                ],
              ),
            ),
          ),

          // 遮罩层和菜单
          if (_showOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showOverlay = !_showOverlay;
                  });
                },
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Stack(
                    children: [
                      // 菜单面板
                      Positioned(
                        top:
                            MediaQuery.of(context).padding.top + kToolbarHeight,
                        right: 16,
                        child: Container(
                          width: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMenuItem(
                                icon: Icons.copy,
                                title: '复制验证码',
                                onTap: () {
                                  final totpCode = TotpService.generateTotp(
                                    widget.entry,
                                  );
                                  Clipboard.setData(
                                    ClipboardData(text: totpCode),
                                  );
                                  setState(() {
                                    _showOverlay = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('验证码已复制到剪贴板'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.edit,
                                title: '编辑账户',
                                onTap: () {
                                  setState(() {
                                    _showOverlay = false;
                                  });
                                  _editEntry(context);
                                },
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.info_outline,
                                title: '账户详情',
                                onTap: () {
                                  setState(() {
                                    _showOverlay = false;
                                  });
                                  _showAccountDetails(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建头部区域 - 静态内容，不需要重建
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // 圆形头像带阴影
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: widget.entry.icon.isEmpty
                  ? const Color(0xFFF0F0F0)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: widget.entry.icon.isEmpty
                  ? Border.all(color: const Color(0xFFE0E0E0), width: 2)
                  : null,
              boxShadow: widget.entry.icon.isEmpty
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _buildEntryIcon(widget.entry),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.entry.name.isNotEmpty
                ? widget.entry.name
                : (widget.entry.issuer.isNotEmpty ? widget.entry.issuer : '账户'),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.entry.issuer.isNotEmpty && widget.entry.name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.entry.issuer,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  // 构建验证码区域 - 只有这部分需要动态更新
  Widget _buildTotpSection() {
    return StreamBuilder<int>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => TotpService.getRemainingTime(widget.entry),
      ),
      initialData: TotpService.getRemainingTime(widget.entry),
      builder: (context, snapshot) {
        final remainingTime = snapshot.data ?? 30;
        final totpCode = TotpService.generateTotp(widget.entry);

        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // 验证码数字 - 更大更突出
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: Text(
                  totpCode,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'monospace',
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 环形进度条
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景圆环
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    // 进度圆环
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: remainingTime / 30,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          remainingTime <= 5 ? Colors.red : Colors.blue,
                        ),
                      ),
                    ),
                    // 中心文字
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$remainingTime',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: remainingTime <= 5
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                        Text(
                          '秒',
                          style: TextStyle(
                            fontSize: 12,
                            color: remainingTime <= 5
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 快捷操作按钮
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.copy,
                      title: '复制',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: totpCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('验证码已复制'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.edit,
                      title: '编辑',
                      onTap: () => _editEntry(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.info_outline,
                      title: '详情',
                      onTap: () => _showAccountDetails(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 0.5, color: const Color(0xFFE5E5E5));
  }

  // 构建条目图标 - 使用缓存避免闪烁
  Widget _buildEntryIcon(TotpEntry entry) {
    return _CachedEntryIcon(entry: entry, getAvatarText: _getAvatarText);
  }

  // 获取头像文字
  String _getAvatarText(String issuer) {
    if (issuer.isEmpty) return '?';

    // 取前两个字符，如果是英文取首字母
    if (RegExp(r'^[a-zA-Z]').hasMatch(issuer)) {
      return issuer.substring(0, 1).toUpperCase();
    } else {
      return issuer.length >= 2 ? issuer.substring(0, 2) : issuer;
    }
  }

  void _showAccountDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('账户详情'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                if (widget.entry.issuer.isNotEmpty)
                  _DetailRow(title: '发行方', content: widget.entry.issuer),
                if (widget.entry.name.isNotEmpty)
                  _DetailRow(title: '账户名', content: widget.entry.name),
                _DetailRow(
                  title: '算法',
                  content: widget.entry.algorithm.toString().split('.').last,
                ),
                _DetailRow(
                  title: '位数',
                  content: widget.entry.digits.toString(),
                ),
                _DetailRow(title: '周期', content: '${widget.entry.period}秒'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}

// 缓存的图标组件，避免每次倒计时重建时重新加载图片
class _CachedEntryIcon extends StatefulWidget {
  final TotpEntry entry;
  final String Function(String) getAvatarText;

  const _CachedEntryIcon({required this.entry, required this.getAvatarText});

  @override
  State<_CachedEntryIcon> createState() => _CachedEntryIconState();
}

class _CachedEntryIconState extends State<_CachedEntryIcon> {
  late Widget _cachedIcon;

  @override
  void initState() {
    super.initState();
    _cachedIcon = _buildIcon();
  }

  @override
  void didUpdateWidget(_CachedEntryIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只有当entry的图标发生变化时才重新构建
    if (oldWidget.entry.icon != widget.entry.icon ||
        oldWidget.entry.issuer != widget.entry.issuer) {
      _cachedIcon = _buildIcon();
    }
  }

  Widget _buildIcon() {
    if (widget.entry.icon.isNotEmpty) {
      // 检查是否是base64图片
      if (widget.entry.icon.startsWith('data:image/')) {
        try {
          // 处理base64图片
          final base64String = widget.entry.icon.split(',').last;
          final imageBytes = const Base64Decoder().convert(base64String);
          return Image.memory(
            imageBytes,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            gaplessPlayback: true, // 避免切换时的闪烁
            errorBuilder: (context, error, stackTrace) {
              // 如果base64解码失败，显示文字头像
              return Center(
                child: Text(
                  widget.getAvatarText(widget.entry.issuer),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        } catch (e) {
          // base64解析失败，显示文字头像
          return Center(
            child: Text(
              widget.getAvatarText(widget.entry.issuer),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      } else {
        // 处理网络图片
        return Image.network(
          widget.entry.icon,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          gaplessPlayback: true, // 避免切换时的闪烁
          errorBuilder: (context, error, stackTrace) {
            // 网络图片加载失败，显示文字头像
            return Center(
              child: Text(
                widget.getAvatarText(widget.entry.issuer),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            // 显示加载指示器
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          },
        );
      }
    } else {
      // 没有图标，显示文字头像
      return Center(
        child: Text(
          widget.getAvatarText(widget.entry.issuer),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cachedIcon;
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String content;

  const _DetailRow({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }
}

class EditEntryScreen extends StatefulWidget {
  final TotpEntry entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _issuerController;
  late final TextEditingController _secretController;
  late final TextEditingController _iconController;
  late final TextEditingController _tagController;
  late final List<String> _tags;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
    _issuerController = TextEditingController(text: widget.entry.issuer);
    _secretController = TextEditingController(text: widget.entry.secret);
    _iconController = TextEditingController(text: widget.entry.icon);
    _tagController = TextEditingController();
    _tags = List<String>.from(widget.entry.tags);
  }

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
    _iconController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final String issuer = _issuerController.text.trim();
      final String secret = _secretController.text.trim().replaceAll(' ', '');
      final String icon = _iconController.text.trim();
      final List<String> tags = _tags;

      final TotpEntry updatedEntry = TotpEntry(
        id: widget.entry.id,
        name: name,
        issuer: issuer,
        secret: secret,
        digits: widget.entry.digits,
        algorithm: widget.entry.algorithm,
        period: widget.entry.period,
        icon: icon,
        tags: tags,
      );

      final TotpProvider provider = Provider.of<TotpProvider>(
        context,
        listen: false,
      );
      provider
          .updateEntry(updatedEntry)
          .then((_) {
            if (mounted) {
              Navigator.of(context).pop(true); // 返回true表示编辑成功
            }
          })
          .catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('更新失败: $error')));
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑验证器'), centerTitle: true),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
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
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
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
                      children: _tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              onDeleted: () => _removeTag(tag),
                            ),
                          )
                          .toList(),
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
                  if (!RegExp(
                    r'^[A-Z2-7]+=*$',
                  ).hasMatch(value.trim().toUpperCase())) {
                    return '密钥格式不正确';
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
                    '更新验证器',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
