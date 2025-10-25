import 'package:flutter/foundation.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/services/storage_service.dart';
import 'package:authx/services/totp_service.dart';

class TotpProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<TotpEntry> _entries = [];
  bool _isLoading = false;

  List<TotpEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  TotpProvider() {
    loadEntries();
  }

  /// 加载所有条目
  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _storageService.getEntries();
    } catch (e) {
      _entries = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 添加多个条目
  Future<void> addEntries(List<TotpEntry> newEntries) async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries.addAll(newEntries);
      await _storageService.saveEntries(_entries);
    } catch (e) {
      // 忽略错误
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 添加新条目
  Future<void> addEntry(TotpEntry entry) async {
    try {
      await _storageService.addEntry(entry);
      await loadEntries();
    } catch (e) {
      rethrow;
    }
  }

  /// 更新条目
  Future<void> updateEntry(TotpEntry entry) async {
    try {
      await _storageService.updateEntry(entry);
      await loadEntries();
    } catch (e) {
      rethrow;
    }
  }

  /// 删除条目
  Future<void> deleteEntry(String id) async {
    try {
      await _storageService.deleteEntry(id);
      await loadEntries();
    } catch (e) {
      rethrow;
    }
  }

  /// 生成指定条目的TOTP码
  String generateTotp(String id) {
    final TotpEntry? entry = _entries.firstWhereOrNull((e) => e.id == id);
    if (entry != null) {
      return TotpService.generateTotp(entry);
    }
    return '';
  }

  /// 获取指定条目的剩余时间
  int getRemainingTime(String id) {
    final TotpEntry? entry = _entries.firstWhereOrNull((e) => e.id == id);
    if (entry != null) {
      return TotpService.getRemainingTime(entry);
    }
    return 0;
  }
}

extension on Iterable<TotpEntry> {
  TotpEntry? firstWhereOrNull(bool Function(TotpEntry) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}