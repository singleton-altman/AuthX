import 'package:flutter_test/flutter_test.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/utils/totp_parser.dart';

void main() {
  group('TOTP Export Tests', () {
    test('should generate correct TOTP URI', () {
      // 创建测试条目
      final entry = TotpEntry(
        id: 'test-id',
        name: 'test@example.com',
        issuer: 'Example',
        secret: 'JBSWY3DPEHPK3PXP',
        digits: 6,
        algorithm: 'SHA1',
        period: 30,
      );

      // 生成 URI
      final uri = TotpParser.toUri(entry);

      // 验证 URI 格式
      expect(uri, startsWith('otpauth://totp/'));
      expect(uri, contains('Example:test@example.com'));
      expect(uri, contains('secret=JBSWY3DPEHPK3PXP'));
      expect(uri, contains('issuer=Example'));
      expect(uri, contains('digits=6'));
      expect(uri, contains('algorithm=SHA1'));
      expect(uri, contains('period=30'));
    });

    test('should handle entry without issuer', () {
      final entry = TotpEntry(
        id: 'test-id',
        name: 'test@example.com',
        issuer: '',
        secret: 'JBSWY3DPEHPK3PXP',
      );

      final uri = TotpParser.toUri(entry);

      expect(uri, contains('otpauth://totp/test@example.com'));
      expect(uri, contains('secret=JBSWY3DPEHPK3PXP'));
    });

    test('should include icon parameter when present', () {
      final entry = TotpEntry(
        id: 'test-id',
        name: 'test@example.com',
        issuer: 'Example',
        secret: 'JBSWY3DPEHPK3PXP',
        icon: 'https://example.com/icon.png',
      );

      final uri = TotpParser.toUri(entry);

      expect(uri, contains('icon=https://example.com/icon.png'));
    });

    test('should not include icon parameter when empty', () {
      final entry = TotpEntry(
        id: 'test-id',
        name: 'test@example.com',
        issuer: 'Example',
        secret: 'JBSWY3DPEHPK3PXP',
        icon: '',
      );

      final uri = TotpParser.toUri(entry);

      expect(uri, isNot(contains('icon=')));
    });

    test('should handle special characters in names', () {
      final entry = TotpEntry(
        id: 'test-id',
        name: 'test+user@example.com',
        issuer: 'Example Corp',
        secret: 'JBSWY3DPEHPK3PXP',
      );

      final uri = TotpParser.toUri(entry);

      // URI 应该正确编码特殊字符
      expect(uri, isA<String>());
      expect(uri, startsWith('otpauth://totp/'));
    });
  });
}