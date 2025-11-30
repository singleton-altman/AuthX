import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/totp_entry.dart';
import '../../providers/totp_provider.dart';
import '../../utils/totp_parser.dart';
import '../../utils/demo_data.dart';
import '../../utils/app_theme.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _showSecrets = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TotpEntry> _getFilteredEntries(List<TotpEntry> entries) {
    if (_searchQuery.isEmpty) {
      return entries;
    }
    return entries.where((entry) {
      return entry.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.issuer.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制 $label 到剪贴板'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  void _copyAllUrls(List<TotpEntry> entries) {
    final urls = entries
        .map((entry) => TotpParser.toStandardUri(entry))
        .join('\n');
    Clipboard.setData(ClipboardData(text: urls));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制所有 ${entries.length} 个TOTP URL到剪贴板'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  void _generateQrCode(List<TotpEntry> entries) {
    final urls = entries
        .map((entry) => TotpParser.toStandardUri(entry))
        .join('\n');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('二维码导出'),
        content: SizedBox(
          width: 200,
          height: 200,
          child: QrImageView(data: urls, version: QrVersions.auto, size: 200),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryIcon(TotpEntry entry) {
    if (entry.icon.isNotEmpty) {
      // 检查是否是base64图片
      if (entry.icon.startsWith('data:image/')) {
        try {
          // 处理base64图片
          final base64String = entry.icon.split(',').last;
          final imageBytes = const Base64Decoder().convert(base64String);
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackIcon(entry);
              },
            ),
          );
        } catch (e) {
          return _buildFallbackIcon(entry);
        }
      } else {
        // 处理网络图片
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            entry.icon,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon(entry);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator(strokeWidth: 2));
            },
          ),
        );
      }
    } else {
      return _buildFallbackIcon(entry);
    }
  }

  Widget _buildFallbackIcon(TotpEntry entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarText = _getAvatarText(entry.issuer);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          avatarText,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  String _getAvatarText(String issuer) {
    if (issuer.isEmpty) return '?';

    // 取前两个字符，如果是英文取首字母
    if (RegExp(r'^[a-zA-Z]').hasMatch(issuer)) {
      return issuer.substring(0, 1).toUpperCase();
    } else {
      return issuer.length >= 2 ? issuer.substring(0, 2) : issuer;
    }
  }

  // 构建详细信息对话框
  Widget _buildDetailDialog(TotpEntry entry, ColorScheme colorScheme) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '详细信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('账户', entry.name, colorScheme),
            const SizedBox(height: 12),
            _buildDetailRow('发行方', entry.issuer, colorScheme),
            const SizedBox(height: 12),
            _buildDetailRow('密钥', entry.secret, colorScheme),
            const SizedBox(height: 12),
            _buildDetailRow('算法', entry.algorithm, colorScheme),
            const SizedBox(height: 12),
            _buildDetailRow('位数', entry.digits.toString(), colorScheme),
            const SizedBox(height: 12),
            _buildDetailRow('周期', '${entry.period}秒', colorScheme),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建二维码对话框
  Widget _buildQrDialog(
    TotpEntry entry,
    String totpUrl,
    ColorScheme colorScheme,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.name} 二维码',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            // 二维码容器，提供固定尺寸避免溢出
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: totpUrl,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '导出数据',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: _showSecrets
                ? const Icon(Icons.visibility_off)
                : const Icon(Icons.visibility),
            onPressed: () {
              setState(() {
                _showSecrets = !_showSecrets;
              });
            },
            tooltip: _showSecrets ? '隐藏密钥' : '显示密钥',
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.science),
              onPressed: () {
                final provider = Provider.of<TotpProvider>(
                  context,
                  listen: false,
                );
                provider.addEntries(DemoData.getSampleEntries());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('已添加演示数据'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              tooltip: '添加演示数据',
            ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      body: Consumer<TotpProvider>(
        builder: (context, provider, child) {
          final entries = _getFilteredEntries(provider.entries);

          if (provider.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无TOTP条目',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 搜索栏
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索条目...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // 操作按钮
              if (entries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _generateQrCode(entries),
                          icon: const Icon(Icons.qr_code, size: 18),
                          label: const Text('生成二维码'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _copyAllUrls(entries),
                          icon: const Icon(Icons.copy_all, size: 18),
                          label: Text('复制全部 (${entries.length})'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // 条目列表
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '未找到匹配的条目',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final standardUrl = TotpParser.toStandardUri(entry);
                          final fullUrl = TotpParser.toUri(entry);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.1,
                                ),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.05,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 头部 - 标题和发行方
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // 图标
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: _buildEntryIcon(entry),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            if (entry.issuer.isNotEmpty)
                                              Text(
                                                entry.issuer,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // TOTP URL 部分已移除，直接通过按钮操作

                                // 操作按钮 - 三个按钮平分卡片底部
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                SizedBox(
                                  height: 48,
                                  child: Row(
                                    children: [
                                      // 详细按钮
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    _buildDetailDialog(
                                                      entry,
                                                      colorScheme,
                                                    ),
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  color: colorScheme.primary,
                                                  size: 20,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '详细',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 分隔线
                                      Container(
                                        width: 1,
                                        color: colorScheme.outline.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      // 复制按钮
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => _copyToClipboard(
                                              fullUrl,
                                              '${entry.name} URL',
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.copy,
                                                  color: colorScheme.primary,
                                                  size: 20,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '复制',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 分隔线
                                      Container(
                                        width: 1,
                                        color: colorScheme.outline.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      // 二维码按钮
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    _buildQrDialog(
                                                      entry,
                                                      standardUrl,
                                                      colorScheme,
                                                    ),
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.qr_code,
                                                  color: colorScheme.primary,
                                                  size: 20,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '二维码',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
