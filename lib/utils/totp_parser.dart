
import 'package:authx/models/totp_entry.dart';

class TotpParseResult {
  final String name;
  final String issuer;
  final String secret;
  final int digits;
  final String algorithm;
  final int period;
  final String icon; // 添加图标字段
  final String tag; // 添加标签字段

  TotpParseResult({
    required this.name,
    required this.issuer,
    required this.secret,
    required this.digits,
    required this.algorithm,
    required this.period,
    required this.icon, // 初始化图标字段
    required this.tag, // 初始化标签字段
  });
}

class TotpParser {
  static TotpParseResult parseUri(String uri) {
    if (!uri.startsWith('otpauth://totp/')) {
      throw FormatException('Invalid TOTP URI');
    }

    final Uri parsedUri = Uri.parse(uri);
    final Map<String, String> queryParameters = parsedUri.queryParameters;

    // 解析账户名和发行方
    String name = parsedUri.path.substring(1); // 移除开头的 '/'
    String issuer = '';

    // 检查issuer参数
    if (queryParameters.containsKey('issuer')) {
      issuer = queryParameters['issuer']!;
    } else if (name.contains(':')) {
      // 从路径中提取issuer（格式：issuer:accountname）
      final parts = name.split(':');
      issuer = parts[0];
      name = parts.sublist(1).join(':');
    }

    // 检查必需的secret参数
    if (!queryParameters.containsKey('secret')) {
      throw FormatException('Missing secret parameter');
    }
    final String secret = queryParameters['secret']!;

    // 解析可选参数
    final int digits = queryParameters.containsKey('digits') 
        ? int.parse(queryParameters['digits']!) 
        : 6;
        
    final String algorithm = queryParameters.containsKey('algorithm') 
        ? queryParameters['algorithm']!.toUpperCase() 
        : 'SHA1';
        
    final int period = queryParameters.containsKey('period') 
        ? int.parse(queryParameters['period']!) 
        : 30;
        
    final String icon = queryParameters.containsKey('icon') 
        ? queryParameters['icon']! 
        : ''; // 解析图标参数
        
    final String tag = queryParameters.containsKey('tag') 
        ? queryParameters['tag']! 
        : ''; // 解析标签参数

    // 验证参数
    if (digits != 6 && digits != 8) {
      throw FormatException('Invalid digits parameter: $digits');
    }

    if (!['SHA1', 'SHA256', 'SHA512'].contains(algorithm)) {
      throw FormatException('Invalid algorithm parameter: $algorithm');
    }

    if (period <= 0) {
      throw FormatException('Invalid period parameter: $period');
    }

    return TotpParseResult(
      name: name,
      issuer: issuer,
      secret: secret,
      digits: digits,
      algorithm: algorithm,
      period: period,
      icon: icon, // 返回图标字段
      tag: tag, // 返回标签字段
    );
  }

  static String toUri(TotpEntry entry) {
    final Uri uri = Uri(
      scheme: 'otpauth',
      host: 'totp',
      path: entry.issuer.isNotEmpty ? '${entry.issuer}:${entry.name}' : entry.name,
      queryParameters: {
        'secret': entry.secret,
        'issuer': entry.issuer,
        'digits': entry.digits.toString(),
        'algorithm': entry.algorithm,
        'period': entry.period.toString(),
        if (entry.icon.isNotEmpty) 'icon': entry.icon, // 添加图标参数
        if (entry.tags.isNotEmpty) 'tag': entry.tags.join(','), // 添加标签参数
      },
    );
    
    return uri.toString();
  }
}