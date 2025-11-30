import 'dart:convert';
import 'dart:ui';
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
  late TotpEntry _currentEntry;

  @override
  void initState() {
    super.initState();
    // 初始化 _currentEntry
    _currentEntry = widget.entry;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _editEntry(BuildContext context) {
    if (!mounted) return;

    Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditEntryScreen(entry: _currentEntry),
          ),
        )
        .then((result) {
          if (!mounted) return;

          if (result == true) {
            // 编辑成功后，从provider重新获取最新的entry数据
            final totpProvider = Provider.of<TotpProvider>(
              context,
              listen: false,
            );
            final updatedEntry = totpProvider.entries.firstWhere(
              (e) => e.id == _currentEntry.id,
              orElse: () => _currentEntry,
            );
            if (mounted) {
              setState(() {
                _currentEntry = updatedEntry;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _currentEntry.issuer.isNotEmpty ? _currentEntry.issuer : '验证码',
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
      body: Stack(
        children: [
          // 主要内容 - 整合式设计
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 头部区域 - 静态内容，不需要重建
                    _buildHeaderSection(theme),

                    // 验证码显示区域 - 只有这部分需要动态更新
                    _buildTotpSection(theme),
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
  Widget _buildHeaderSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
              color: _currentEntry.icon.isEmpty
                  ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: _currentEntry.icon.isEmpty
                  ? Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      width: 2,
                    )
                  : null,
              boxShadow: _currentEntry.icon.isEmpty
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
              child: _buildEntryIcon(_currentEntry),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _currentEntry.name.isNotEmpty
                ? _currentEntry.name
                : (_currentEntry.issuer.isNotEmpty
                      ? _currentEntry.issuer
                      : '账户'),
            style: TextStyle(
              fontSize: 20,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_currentEntry.issuer.isNotEmpty && _currentEntry.name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _currentEntry.issuer,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          // 标签显示
          if (_currentEntry.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentEntry.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // 构建验证码区域 - 只有这部分需要动态更新
  Widget _buildTotpSection(ThemeData theme) {
    return StreamBuilder<int>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => TotpService.getRemainingTime(_currentEntry),
      ),
      initialData: TotpService.getRemainingTime(_currentEntry),
      builder: (context, snapshot) {
        final remainingTime = snapshot.data ?? 30;
        final totpCode = TotpService.generateTotp(_currentEntry);

        return Container(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
          child: Column(
            children: [
              // 验证码数字 - 进度条在底部
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      totpCode,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        fontFamily: 'monospace',
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 进度条 - 在框底部，从右到左，自适应宽度
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 4,
                        width: double.infinity,
                        color: theme.colorScheme.surfaceContainer.withValues(
                          alpha: 0.3,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: FractionallySizedBox(
                                widthFactor: remainingTime / 30,
                                child: Container(
                                  height: 4,
                                  color: remainingTime <= 5
                                      ? Colors.red
                                      : theme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          SnackBar(
                            content: const Text('验证码已复制'),
                            backgroundColor: theme.primaryColor,
                          ),
                        );
                      },
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.edit,
                      title: '编辑',
                      onTap: () => _editEntry(context),
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.info_outline,
                      title: '详情',
                      onTap: () => _showAccountDetails(context),
                      theme: theme,
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
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.primaryColor, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                if (_currentEntry.issuer.isNotEmpty)
                  _DetailRow(title: '发行方', content: _currentEntry.issuer),
                if (_currentEntry.name.isNotEmpty)
                  _DetailRow(title: '账户名', content: _currentEntry.name),
                _DetailRow(
                  title: '算法',
                  content: _currentEntry.algorithm.toString().split('.').last,
                ),
                _DetailRow(
                  title: '位数',
                  content: _currentEntry.digits.toString(),
                ),
                _DetailRow(title: '周期', content: '${_currentEntry.period}秒'),
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

  // 删除条目
  Future<void> _deleteEntry(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除账户'),
          content: const Text('确定要删除此账户吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final totpProvider = Provider.of<TotpProvider>(context, listen: false);
      await totpProvider.deleteEntry(_currentEntry.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // 账户输入框
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

                // 密钥输入框
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

                const SizedBox(height: 24),

                // 提交按钮
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
      ),
    );
  }
}
