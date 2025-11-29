import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/services/totp_service.dart';
import 'package:authx/services/timer_service.dart';
import 'package:authx/ui/screens/add_entry_screen.dart';
import 'package:authx/ui/screens/qr_scanner_screen.dart';
import 'package:authx/ui/screens/settings_screen.dart';
import 'package:authx/ui/screens/totp_display_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TimerService _timerService;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTag; // 选中的标签
  String _searchQuery = ''; // 搜索关键词
  bool _isSyncing = false; // 同步状态

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _timerService.startTimer();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _timerService.stopTimer();
    _timerService.dispose();
    _searchController.dispose();
    super.dispose();
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
        title: const Text(
          '验证码',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        actions: [
          // 深浅色切换按钮
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final currentMode = themeProvider.themeMode;
              return IconButton(
                icon: currentMode == ThemeMode.system
                    ? const Icon(Icons.smartphone, size: 24)
                    : Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        size: 24,
                      ),
                onPressed: () {
                  if (currentMode == ThemeMode.dark) {
                    themeProvider.setThemeMode(ThemeMode.light);
                  } else if (currentMode == ThemeMode.light) {
                    themeProvider.setThemeMode(ThemeMode.system);
                  } else {
                    themeProvider.setThemeMode(ThemeMode.dark);
                  }
                },
              );
            },
          ),
          // 云朵同步按钮
          IconButton(
            icon: _isSyncing
                ? const Icon(Icons.check_circle, size: 24, color: Colors.green)
                : const Icon(Icons.cloud_outlined, size: 24),
            style: _isSyncing
                ? IconButton.styleFrom(
                    backgroundColor: Colors.green.withValues(alpha: 0.15),
                  )
                : null,
            onPressed: () async {
              setState(() {
                _isSyncing = true;
              });
              // 模拟同步过程
              await Future.delayed(const Duration(seconds: 2));
              setState(() {
                _isSyncing = false;
              });
            },
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TotpProvider>(
        builder: (context, totpProvider, _) {
          if (totpProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (totpProvider.entries.isEmpty) {
            return const EmptyStateView();
          }

          // 提取所有唯一标签
          final allTags = <String>{};
          for (var entry in totpProvider.entries) {
            allTags.addAll(entry.tags);
          }
          final sortedTags = allTags.toList()..sort();

          // 根据选中的标签筛选条目
          var filteredEntries = _selectedTag == null
              ? totpProvider.entries
              : totpProvider.entries
                    .where((entry) => entry.tags.contains(_selectedTag))
                    .toList();

          // 根据搜索关键词进一步筛选
          if (_searchQuery.isNotEmpty) {
            filteredEntries = filteredEntries
                .where(
                  (entry) =>
                      entry.issuer.toLowerCase().contains(_searchQuery) ||
                      entry.name.toLowerCase().contains(_searchQuery) ||
                      entry.tags.any((tag) => tag.toLowerCase().contains(_searchQuery)),
                )
                .toList();
          }

          return Stack(
            children: [
              Column(
                children: [
                  // 搜索栏 + 倒计时胶囊
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: '搜索发行方或账户名',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  size: 20,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(
                                    color: theme.primaryColor,
                                    width: 1,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 倒计时胶囊
                        StreamBuilder<int>(
                          stream: Stream.periodic(
                            const Duration(seconds: 1),
                            (_) => 30 - (DateTime.now().second % 30),
                          ),
                          initialData: 30 - (DateTime.now().second % 30),
                          builder: (context, snapshot) {
                            final remainingTime = snapshot.data ?? 30;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: remainingTime <= 5
                                        ? Colors.red
                                        : theme.primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${remainingTime}s',
                                    style: TextStyle(
                                      color: remainingTime <= 5
                                          ? Colors.red
                                          : theme.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // 标签栏
                  if (sortedTags.isNotEmpty)
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sortedTags.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "全部" 按钮
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTag = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedTag == null
                                        ? theme.primaryColor
                                        : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _selectedTag == null
                                          ? Colors.transparent
                                          : theme.dividerColor.withValues(
                                              alpha: 0.2,
                                            ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '全部',
                                      style: TextStyle(
                                        color: _selectedTag == null
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final tag = sortedTags[index - 1];
                          final isSelected = _selectedTag == tag;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTag = isSelected ? null : tag;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : theme.dividerColor.withValues(
                                            alpha: 0.2,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  // 验证码列表
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.blue,
                      onRefresh: totpProvider.loadEntries,
                      child: filteredEntries.isEmpty
                          ? Center(
                              child: Text(
                                '该标签下没有验证器',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredEntries.length,
                              itemBuilder: (context, index) {
                                final entry = filteredEntries[index];
                                return _buildModernTotpItem(context, entry);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: FloatingActionButton(
              heroTag: "scan",
              backgroundColor: theme.primaryColor,
              onPressed: () => _onScanQR(context),
              child: const Icon(Icons.qr_code_scanner),
            ),
          ),
          FloatingActionButton(
            heroTag: "add",
            backgroundColor: theme.primaryColor,
            onPressed: () => _onManualAdd(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
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

  Widget _buildModernTotpItem(BuildContext context, TotpEntry entry) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.primaryColor,
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
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 28),
            SizedBox(height: 8),
            Text('编辑', style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
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
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(height: 8),
            Text('删除', style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 向右滑动 - 编辑
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TotpDisplayScreen(entry: entry)),
          );
          return false;
        } else {
          // 向左滑动 - 删除
          return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('删除验证器'),
                content: Text(
                  '确定要删除 "${entry.issuer.isNotEmpty ? entry.issuer : '未知服务'}" 吗？',
                ),
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
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteEntry(context, entry);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // 点击复制验证码
              final code = TotpService.generateTotp(entry);
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('验证码已复制'),
                  backgroundColor: theme.primaryColor,
                ),
              );
            },
            onLongPress: () {
              // 长按显示选项
              _showItemOptions(context, entry);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 图标显示
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: entry.icon.isEmpty
                          ? _getAvatarColor(entry.issuer).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildEntryIcon(entry),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 信息区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.issuer.isNotEmpty ? entry.issuer : '未知服务',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (entry.name.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            entry.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // 标签徽章
                        if (entry.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: entry.tags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: theme.primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 11,
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
                  ),
                  // 验证码区域 - 使用独立的StreamBuilder
                  StreamBuilder<int>(
                    stream: Stream.periodic(
                      const Duration(seconds: 1),
                      (_) => TotpService.getRemainingTime(entry),
                    ),
                    initialData: TotpService.getRemainingTime(entry),
                    builder: (context, snapshot) {
                      final remainingTime = snapshot.data ?? 30;
                      final totpCode = TotpService.generateTotp(entry);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            totpCode,
                            style: TextStyle(
                              fontSize: 20,
                              color: theme.colorScheme.onSurface,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: remainingTime / 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: remainingTime <= 5
                                      ? Colors.red
                                      : theme.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showItemOptions(BuildContext context, TotpEntry entry) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: entry.icon.isEmpty
                            ? _getAvatarColor(
                                entry.issuer,
                              ).withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildEntryIcon(entry),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.issuer.isNotEmpty ? entry.issuer : '未知服务',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (entry.name.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              entry.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.copy,
                      label: '复制',
                      onTap: () {
                        final code = TotpService.generateTotp(entry);
                        Clipboard.setData(ClipboardData(text: code));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('验证码已复制'),
                            backgroundColor: theme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.open_in_full,
                      label: '详情',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TotpDisplayScreen(entry: entry),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.edit_outlined,
                      label: '编辑',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: 导航到编辑页面
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.delete_outline,
                      label: '删除',
                      onTap: () {
                        Navigator.pop(context);
                        _confirmDelete(context, entry);
                      },
                      isDanger: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDanger ? Colors.red : theme.primaryColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDanger ? Colors.red : theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TotpEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除验证器'),
        content: Text(
          '确定要删除 "${entry.issuer.isNotEmpty ? entry.issuer : '未知服务'}" 吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEntry(context, entry);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 获取头像颜色
  Color _getAvatarColor(String issuer) {
    final colors = [
      const Color(0xFF07C160), // 微信绿
      const Color(0xFF1AAD19), // 深绿
      const Color(0xFF10AEFF), // 蓝色
      const Color(0xFFFF9C00), // 橙色
      const Color(0xFFFF6B6B), // 红色
      const Color(0xFF9B59B6), // 紫色
      const Color(0xFF3498DB), // 天蓝
    ];

    int hash = issuer.hashCode;
    return colors[(hash.abs() % colors.length)];
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

  // 构建条目图标 - 使用缓存避免闪烁
  Widget _buildEntryIcon(TotpEntry entry) {
    return _CachedEntryIcon(
      entry: entry,
      getAvatarColor: _getAvatarColor,
      getAvatarText: _getAvatarText,
    );
  }

  /// 删除条目
  void _deleteEntry(BuildContext context, TotpEntry entry) {
    Provider.of<TotpProvider>(context, listen: false)
        .deleteEntry(entry.id)
        .then((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('删除成功')));
          }
        })
        .catchError((error) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('删除失败: $error')));

            // 删除失败时重新加载列表
            Provider.of<TotpProvider>(context, listen: false).loadEntries();
          }
        });
  }
}

// 缓存的图标组件，避免每次倒计时重建时重新加载图片
class _CachedEntryIcon extends StatefulWidget {
  final TotpEntry entry;
  final Color Function(String) getAvatarColor;
  final String Function(String) getAvatarText;

  const _CachedEntryIcon({
    required this.entry,
    required this.getAvatarColor,
    required this.getAvatarText,
  });

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
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            gaplessPlayback: true, // 避免切换时的闪烁
            errorBuilder: (context, error, stackTrace) {
              // 如果base64解码失败，显示文字头像
              return Center(
                child: Text(
                  widget.getAvatarText(widget.entry.issuer),
                  style: TextStyle(
                    color: widget.getAvatarColor(widget.entry.issuer),
                    fontSize: 20,
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
              style: TextStyle(
                color: widget.getAvatarColor(widget.entry.issuer),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      } else {
        // 处理网络图片
        return Image.network(
          widget.entry.icon,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          gaplessPlayback: true, // 避免切换时的闪烁
          errorBuilder: (context, error, stackTrace) {
            // 网络图片加载失败，显示文字头像
            return Center(
              child: Text(
                widget.getAvatarText(widget.entry.issuer),
                style: TextStyle(
                  color: widget.getAvatarColor(widget.entry.issuer),
                  fontSize: 20,
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
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.getAvatarColor(widget.entry.issuer),
                ),
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
          style: TextStyle(
            color: widget.getAvatarColor(widget.entry.issuer),
            fontSize: 20,
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

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 50,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '还没有验证器',
              style: TextStyle(
                fontSize: 24,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '添加您的第一个双因素认证\n以保护账户安全',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddEntryScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      '添加第一个验证器',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QRScannerScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '扫描二维码',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
