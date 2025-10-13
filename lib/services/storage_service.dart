import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:authx/models/totp_entry.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const String _entriesKey = 'totp_entries';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  /// 获取所有TOTP条目
  Future<List<TotpEntry>> getEntries() async {
    try {
      final String? entriesJson = await _storage.read(key: _entriesKey);
      if (entriesJson == null || entriesJson.isEmpty) {
        return [];
      }

      final List<dynamic> entriesList = json.decode(entriesJson);
      return entriesList
          .map((entry) => TotpEntry.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (e) {
      // 如果解析失败，返回空列表
      return [];
    }
  }

  /// 添加新的TOTP条目
  Future<void> addEntry(TotpEntry entry) async {
    final List<TotpEntry> entries = await getEntries();
    entries.add(entry);
    await _saveEntries(entries);
  }

  /// 更新TOTP条目
  Future<void> updateEntry(TotpEntry entry) async {
    final List<TotpEntry> entries = await getEntries();
    final int index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      await _saveEntries(entries);
    }
  }

  /// 删除TOTP条目
  Future<void> deleteEntry(String id) async {
    final List<TotpEntry> entries = await getEntries();
    entries.removeWhere((entry) => entry.id == id);
    await _saveEntries(entries);
  }

  /// 保存所有条目
  Future<void> _saveEntries(List<TotpEntry> entries) async {
    final String entriesJson = json.encode(
      entries.map((entry) => entry.toJson()).toList(),
    );
    await _storage.write(key: _entriesKey, value: entriesJson);
  }
}