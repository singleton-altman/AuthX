import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:authx/models/totp_entry.dart';
import 'package:authx/utils/base32.dart';

class TotpService {
  /// 生成当前TOTP码
  static String generateTotp(TotpEntry entry) {
    final int counter = (DateTime.now().millisecondsSinceEpoch ~/ 1000) ~/ entry.period;
    return _generateTotp(entry.secret, counter, entry.digits, entry.algorithm);
  }

  /// 在指定时间生成TOTP码 (用于测试)
  static String generateTotpAtTime(TotpEntry entry, DateTime time) {
    final int counter = (time.millisecondsSinceEpoch ~/ 1000) ~/ entry.period;
    return _generateTotp(entry.secret, counter, entry.digits, entry.algorithm);
  }

  /// 计算剩余时间
  static int getRemainingTime(TotpEntry entry) {
    final int currentTimeSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return entry.period - (currentTimeSeconds % entry.period);
  }

  static String _generateTotp(String secret, int counter, int digits, String algorithm) {
    try {
      // 解码Base32密钥
      final Uint8List key = Uint8List.fromList(Base32.decode(secret));
      final Uint8List counterBytes = _intToBytes(counter);
      
      // 根据算法选择HMAC函数
      final Hmac hmac = _getHmac(algorithm, key);
      final Uint8List hash = Uint8List.fromList(hmac.convert(counterBytes).bytes);
      
      // 动态截断
      final int offset = hash[hash.length - 1] & 0x0F;
      final int binary = ((hash[offset] & 0x7F) << 24) |
          ((hash[offset + 1] & 0xFF) << 16) |
          ((hash[offset + 2] & 0xFF) << 8) |
          (hash[offset + 3] & 0xFF);

      // 生成指定长度的OTP
      final int pow10 = _pow(10, digits);
      final int otp = binary % pow10;
      return otp.toString().padLeft(digits, '0');
    } catch (e) {
      // 如果出现任何错误，返回默认值
      return 'ERROR'.padLeft(digits, '0');
    }
  }

  static Hmac _getHmac(String algorithm, Uint8List key) {
    switch (algorithm.toUpperCase()) {
      case 'SHA1':
        return Hmac(sha1, key);
      case 'SHA256':
        return Hmac(sha256, key);
      case 'SHA512':
        return Hmac(sha512, key);
      default:
        return Hmac(sha1, key);
    }
  }

  static Uint8List _intToBytes(int value) {
    final Uint8List bytes = Uint8List(8);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = (value & 0xFF);
      value >>= 8;
    }
    return bytes;
  }
  
  static int _pow(int base, int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}