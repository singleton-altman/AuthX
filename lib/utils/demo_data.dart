import '../models/totp_entry.dart';

class DemoData {
  static List<TotpEntry> getSampleEntries() {
    return [
      TotpEntry(
        id: 'demo-1',
        name: 'john.doe@gmail.com',
        issuer: 'Google',
        secret: 'JBSWY3DPEHPK3PXP',
        digits: 6,
        algorithm: 'SHA1',
        period: 30,
        icon: '',
      ),
      TotpEntry(
        id: 'demo-2',
        name: 'john.doe@outlook.com',
        issuer: 'Microsoft',
        secret: 'HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ',
        digits: 6,
        algorithm: 'SHA1',
        period: 30,
        icon: '',
      ),
      TotpEntry(
        id: 'demo-3',
        name: 'johndoe',
        issuer: 'GitHub',
        secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
        digits: 6,
        algorithm: 'SHA1',
        period: 30,
        icon: '',
      ),
      TotpEntry(
        id: 'demo-4',
        name: 'john.doe@company.com',
        issuer: 'AWS',
        secret: 'MFRGG2LTMVZGS3THMFZXIZLSMVZGS3TH',
        digits: 6,
        algorithm: 'SHA256',
        period: 30,
        icon: '',
      ),
      TotpEntry(
        id: 'demo-5',
        name: 'johndoe',
        issuer: 'Discord',
        secret: 'NFZWS2LTNFZWS2LTNFZWS2LTNFZWS2LT',
        digits: 6,
        algorithm: 'SHA1',
        period: 30,
        icon: '',
      ),
    ];
  }

  static String getSampleExportText() {
    final entries = getSampleEntries();
    return entries.map((entry) {
      final issuerPrefix = entry.issuer.isNotEmpty ? '${entry.issuer}:' : '';
      return 'otpauth://totp/$issuerPrefix${entry.name}?secret=${entry.secret}&issuer=${entry.issuer}&digits=${entry.digits}&algorithm=${entry.algorithm}&period=${entry.period}';
    }).join('\n');
  }
}