import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
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
    final urls = entries.map((entry) => TotpParser.toUri(entry)).join('\n');
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
    final urls = entries.map((entry) => TotpParser.toUri(entry)).join('\n');
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
                color: colorScheme.onSurface.withOpacity(0.6),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('导出数据'),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadius,
                      ),
                    ),
                  ),
                );
              },
              tooltip: '添加演示数据',
            ),
        ],
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
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无TOTP条目',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onSurface.withOpacity(0.7),
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
                padding: const EdgeInsets.all(16.0),
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
                    fillColor: colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadius,
                      ),
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
                          icon: const Icon(Icons.qr_code),
                          label: const Text('生成二维码'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _copyAllUrls(entries),
                          icon: const Icon(Icons.copy_all),
                          label: Text('复制全部 (${entries.length})'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

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
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '未找到匹配的条目',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurface.withOpacity(0.7),
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
                          final totpUrl = TotpParser.toUri(entry);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius,
                              ),
                            ),
                            elevation: 0,
                            color: colorScheme.surfaceVariant,
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primary
                                    .withOpacity(0.1),
                                child: Text(
                                  entry.name.isNotEmpty
                                      ? entry.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                entry.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              subtitle: entry.issuer.isNotEmpty
                                  ? Text(
                                      entry.issuer,
                                      style: TextStyle(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    )
                                  : null,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // TOTP URL
                                      Text(
                                        'TOTP URL:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.borderRadius,
                                          ),
                                        ),
                                        child: SelectableText(
                                          totpUrl,
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),

                                      // 详细信息
                                      if (_showSecrets) ...[
                                        const SizedBox(height: 16),
                                        _buildDetailRow(
                                          '密钥',
                                          entry.secret,
                                          colorScheme,
                                        ),
                                        _buildDetailRow(
                                          '算法',
                                          entry.algorithm,
                                          colorScheme,
                                        ),
                                        _buildDetailRow(
                                          '位数',
                                          entry.digits.toString(),
                                          colorScheme,
                                        ),
                                        _buildDetailRow(
                                          '周期',
                                          '${entry.period}秒',
                                          colorScheme,
                                        ),
                                      ],

                                      const SizedBox(height: 16),

                                      // 操作按钮
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FilledButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text(
                                                        '${entry.name} 二维码',
                                                      ),
                                                      content: SizedBox(
                                                        width: 200,
                                                        height: 200,
                                                        child: QrImageView(
                                                          data: totpUrl,
                                                          version:
                                                              QrVersions.auto,
                                                          size: 200,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            '关闭',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.qr_code,
                                              size: 16,
                                            ),
                                            label: const Text('二维码'),
                                            style: FilledButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          FilledButton.icon(
                                            onPressed: () => _copyToClipboard(
                                              totpUrl,
                                              '${entry.name} URL',
                                            ),
                                            icon: const Icon(
                                              Icons.copy,
                                              size: 16,
                                            ),
                                            label: const Text('复制URL'),
                                            style: FilledButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ],
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
