import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/services/totp_service.dart';
import 'package:authx/services/timer_service.dart';
import 'package:authx/ui/screens/add_entry_screen.dart';
import 'package:authx/ui/screens/simple_import_screen.dart';
import 'package:authx/ui/screens/qr_scanner_screen.dart';
import 'package:authx/ui/screens/settings_screen.dart';
import 'package:authx/ui/screens/totp_display_screen.dart';
import 'package:authx/ui/screens/export_screen.dart';
import 'package:authx/ui/widgets/expanded_fab.dart';
import 'package:authx/ui/widgets/circular_progress_avatar.dart';
// 添加必要的导入
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _timerService.startTimer();
  }

  @override
  void dispose() {
    _timerService.stopTimer();
    _timerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuthX TOTP'),
        centerTitle: true,
        actions: [
          // 添加三合一主题模式按钮
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _getThemeModeIcon(themeProvider.themeMode),
              color: Theme.of(context).primaryColor,
              onPressed: () => _switchThemeMode(themeProvider),
            ),
          ),
          // 恢复设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<TotpProvider>(
            builder: (context, totpProvider, _) {
              if (totpProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (totpProvider.entries.isEmpty) {
                return const EmptyStateView();
              }

              return StreamBuilder<int>(
                stream: _timerService.secondsStream,
                initialData: DateTime.now().second,
                builder: (context, snapshot) {
                  final currentSecond = snapshot.data ?? DateTime.now().second;
                  final remainingTime = 30 - (currentSecond % 30);

                  return RefreshIndicator(
                    onRefresh: totpProvider.loadEntries,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80), // 为FAB留出空间
                      itemCount: totpProvider.entries.length,
                      itemBuilder: (context, index) {
                        final entry = totpProvider.entries[index];
                        return _buildTotpItem(context, entry, remainingTime);
                      },
                    ),
                  );
                },
              );
            },
          ),
          // 将ExpandedFab放在Stack中以确保全屏覆盖
          ExpandedFab(
            onManualAdd: () => _onManualAdd(context),
            onScanQR: () => _onScanQR(context),
            onImport: () => _onImport(context),
            onExport: () => _onExport(context),
          ),
        ],
      ),
    );
  }

  /// 获取当前主题模式对应的图标
  Icon _getThemeModeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return const Icon(Icons.wb_sunny);
      case ThemeMode.dark:
        return const Icon(Icons.nightlight);
      case ThemeMode.system:
        return const Icon(Icons.sync);
    }
  }

  /// 切换主题模式
  void _switchThemeMode(ThemeProvider themeProvider) {
    switch (themeProvider.themeMode) {
      case ThemeMode.light:
        themeProvider.setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        themeProvider.setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        themeProvider.setThemeMode(ThemeMode.light);
        break;
    }
  }

  // 添加缺失的函数定义
  void _onManualAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEntryScreen()),
    );
  }

  void _onScanQR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );
  }

  void _onImport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SimpleImportScreen()),
    );
  }

  void _onExport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExportScreen()),
    );
  }

  Widget _buildTotpItem(BuildContext context, TotpEntry entry, int remainingTime) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final double avatarSize = themeProvider.avatarSize;
    
    return Column(
      children: [
        Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.horizontal,
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // 向右滑动 - 打开TOTP显示页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TotpDisplayScreen(entry: entry),
                ),
              );
              return false; // 不需要确认对话框
            } else {
              // 向左滑动 - 删除功能
              return await _confirmDelete(context, entry);
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              // 向右滑动 - 不执行任何操作（已在confirmDismiss中处理）
            } else {
              // 向左滑动 - 删除
              _deleteEntry(context, entry);
            }
          },
          child: InkWell(
            onTap: () {
              // 点击条目复制验证码
              final code = TotpService.generateTotp(entry);
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('验证码已复制到剪贴板')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // 显示带倒计时跑道的发行方图标
                  CircularProgressAvatar(
                    icon: entry.icon,
                    issuer: entry.issuer,
                    size: avatarSize,
                    remainingTime: remainingTime,
                    period: entry.period,
                    progressColor: remainingTime <= 5 ? Colors.red : theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  // 中间信息区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.issuer.isNotEmpty ? entry.issuer : '未知服务',
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          entry.name.isNotEmpty ? entry.name : '未知账户',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (entry.tag.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.tag,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 验证码和倒计时区域
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        TotpService.generateTotp(entry),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: themeProvider.codeFontSize,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (remainingTime <= 5 ? Colors.red : theme.primaryColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${remainingTime}s',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: remainingTime <= 5 ? Colors.red : theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // 使用横线分隔列表项
        Divider(
          height: 1,
          thickness: 0.5,
          indent: avatarSize * 2 + 12 + 12, // 与图标和间距对齐
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ],
    );
  }

  /// 确认编辑条目
  Future<bool?> _confirmEdit(BuildContext context, TotpEntry entry) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('编辑条目'),
          content: Text('确定要编辑 "${entry.issuer.isNotEmpty ? entry.issuer : '未知服务'}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('编辑'),
            ),
          ],
        );
      },
    );
  }

  /// 确认删除条目
  Future<bool?> _confirmDelete(BuildContext context, TotpEntry entry) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除条目'),
          content: Text('确定要删除 "${entry.issuer.isNotEmpty ? entry.issuer : '未知服务'}" 吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  /// 编辑条目
  void _editEntry(BuildContext context, TotpEntry entry) async {
    // 这里可以导航到编辑页面
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('编辑功能将在后续版本中实现')),
      );
      
      // 恢复列表项位置
      Provider.of<TotpProvider>(context, listen: false).loadEntries();
    }
  }

  /// 删除条目
  void _deleteEntry(BuildContext context, TotpEntry entry) {
    Provider.of<TotpProvider>(context, listen: false).deleteEntry(entry.id).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    }).catchError((error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $error')),
        );
        
        // 删除失败时重新加载列表
        Provider.of<TotpProvider>(context, listen: false).loadEntries();
      }
    });
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline, 
            size: 64, 
            color: theme.primaryColor.withOpacity(0.5)
          ),
          const SizedBox(height: 16),
          Text(
            '暂无TOTP条目',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角"+"添加新的验证器',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEntryScreen()),
              );
            },
            child: const Text('添加第一个验证器'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}