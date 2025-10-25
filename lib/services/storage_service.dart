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
      return [];
    }
  }

  /// 保存所有TOTP条目
  Future<void> saveEntries(List<TotpEntry> entries) async {
    try {
      final String entriesJson = json.encode(
        entries.map((entry) => entry.toJson()).toList(),
      );
      await _storage.write(key: _entriesKey, value: entriesJson);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 添加单个条目
  Future<void> addEntry(TotpEntry entry) async {
    final entries = await getEntries();
    entries.add(entry);
    await saveEntries(entries);
  }

  /// 删除单个条目
  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((entry) => entry.id == id);
    await saveEntries(entries);
  }

  /// 更新单个条目
  Future<void> updateEntry(TotpEntry updatedEntry) async {
    final entries = await getEntries();
    final index = entries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index != -1) {
      entries[index] = updatedEntry;
      await saveEntries(entries);
    }
  }
}