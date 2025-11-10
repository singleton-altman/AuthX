class TotpEntry {
  final String id;
  final String name;
  final String issuer;
  final String secret;
  final int digits;
  final String algorithm;
  final int period;
  final String icon; // 添加图标字段
  final List<String> tags; // 添加标签列表

  TotpEntry({
    required this.id,
    required this.name,
    required this.issuer,
    required this.secret,
    this.digits = 6,
    this.algorithm = 'SHA1',
    this.period = 30,
    this.icon = '', // 默认为空字符串
    this.tags = const [], // 默认为空列表
  });

  // 从JSON创建TOTP条目
  factory TotpEntry.fromJson(Map<String, dynamic> json) {
    return TotpEntry(
      id: json['id'],
      name: json['name'],
      issuer: json['issuer'],
      secret: json['secret'],
      digits: json['digits'] ?? 6,
      algorithm: json['algorithm'] ?? 'SHA1',
      period: json['period'] ?? 30,
      icon: json['icon'] ?? '', // 从JSON读取图标字段
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [], // 从JSON读取标签列表
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'secret': secret,
      'digits': digits,
      'algorithm': algorithm,
      'period': period,
      'icon': icon, // 将图标字段转换为JSON
      'tags': tags, // 将标签列表转换为JSON
    };
  }
}