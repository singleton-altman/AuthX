import 'dart:async';
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
  String _totpCode = '';
  int _remainingTime = 0;
  Timer? _timer;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _updateTotp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTotp() {
    setState(() {
      _totpCode = TotpService.generateTotp(widget.entry);
      _remainingTime = TotpService.getRemainingTime(widget.entry);
    });
    
    // 每秒更新一次
    _timer = Timer(const Duration(seconds: 1), _updateTotp);
  }

  void _editEntry(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntryScreen(entry: widget.entry),
      ),
    );

    if (result == true) {
      // 如果编辑成功，刷新页面
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.entry.issuer ?? '验证码'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showOverlay ? Icons.close : Icons.more_vert),
            onPressed: () {
              setState(() {
                _showOverlay = !_showOverlay;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 主要内容
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).canvasColor,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 发行方图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _buildAvatar(), // 使用_buildAvatar方法构建图标
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  widget.entry.name ?? widget.entry.issuer ?? '账户',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 40),
                // 验证码显示
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _totpCode,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 倒计时环形进度条
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: (30 - _remainingTime) / 30,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _remainingTime <= 5 ? Colors.red : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      '$_remainingTime',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _remainingTime <= 5 ? Colors.red : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '秒后更新',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // 遮罩层和菜单
          if (_showOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showOverlay = false;
                  });
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Stack(
                      children: [
                        // 菜单面板
                        Positioned(
                          top: MediaQuery.of(context).padding.top + kToolbarHeight,
                          right: 16,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('复制验证码'),
                                  leading: const Icon(Icons.copy),
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: _totpCode));
                                    setState(() {
                                      _showOverlay = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('验证码已复制到剪贴板')),
                                    );
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  title: const Text('编辑账户'),
                                  leading: const Icon(Icons.edit),
                                  onTap: () {
                                    setState(() {
                                      _showOverlay = false;
                                    });
                                    _editEntry(context);
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  title: const Text('账户详情'),
                                  leading: const Icon(Icons.info),
                                  onTap: () {
                                    setState(() {
                                      _showOverlay = false;
                                    });
                                    // 显示账户详情对话框
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
            ),
        ],
      ),
    );
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
                _DetailRow(title: '算法', content: widget.entry.algorithm.toString().split('.').last),
                _DetailRow(title: '位数', content: widget.entry.digits.toString()),
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

  // 在_TotpDisplayScreenState类中添加以下方法
  Widget _buildAvatar() {
    // 如果有图标URL，则显示图标；否则显示默认头像
    if (widget.entry.icon.isNotEmpty) {
      try {
        // 判断是base64编码还是网络图片链接
        if (widget.entry.icon.startsWith('data:image')) {
          // base64编码图片
          final Uint8List imageBytes = _decodeBase64Image(widget.entry.icon);
          return CircleAvatar(
            radius: 40,
            backgroundImage: MemoryImage(imageBytes),
          );
        } else {
          // 网络图片链接
          return CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(widget.entry.icon),
          );
        }
      } catch (e) {
        // 如果加载失败，回退到默认头像
        return _buildDefaultAvatar();
      }
    } else {
      // 默认头像
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Text(
      widget.entry.issuer.isNotEmpty 
          ? widget.entry.issuer.substring(0, 1).toUpperCase() 
          : 'A',
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    // 移除base64数据URI前缀
    final String base64Data = base64String.split(',').last;
    // 解码base64字符串
    return Uint8List.fromList(base64.decode(base64Data));
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
          Expanded(
            child: Text(content),
          ),
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
    _issuerController = TextEditingController(text: widget.entry.issuer);
    _secretController = TextEditingController(text: widget.entry.secret);
    _iconController = TextEditingController(text: widget.entry.icon);
    _tagController = TextEditingController(text: widget.entry.tag);
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
      final String tag = _tagController.text.trim();

      final TotpEntry updatedEntry = TotpEntry(
        id: widget.entry.id,
        name: name,
        issuer: issuer,
        secret: secret,
        digits: widget.entry.digits,
        algorithm: widget.entry.algorithm,
        period: widget.entry.period,
        icon: icon,
        tag: tag,
      );

      final TotpProvider provider = Provider.of<TotpProvider>(context, listen: false);
      provider.updateEntry(updatedEntry).then((_) {
        if (mounted) {
          Navigator.of(context).pop(true); // 返回true表示编辑成功
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失败: $error')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑验证器'),
        centerTitle: true,
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

              // 标签输入框
              TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: '标签',
                  hintText: '例如：工作、个人、重要',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
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