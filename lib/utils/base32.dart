class Base32 {
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// 解码Base32字符串为字节
  static List<int> decode(String input) {
    // 移除空白字符和填充字符
    input = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    
    List<int> bytes = [];
    int buffer = 0;
    int bufferSize = 0;
    
    for (int i = 0; i < input.length; i++) {
      int charIndex = _alphabet.indexOf(input[i]);
      if (charIndex == -1) {
        throw FormatException('Invalid Base32 character: ${input[i]}');
      }
      
      buffer = (buffer << 5) | charIndex;
      bufferSize += 5;
      
      if (bufferSize >= 8) {
        bufferSize -= 8;
        bytes.add((buffer >> bufferSize) & 0xFF);
      }
    }
    
    return bytes;
  }
  
  /// 编码字节为Base32字符串
  static String encode(List<int> bytes) {
    String output = '';
    int buffer = 0;
    int bufferSize = 0;
    
    for (int i = 0; i < bytes.length; i++) {
      buffer = (buffer << 8) | (bytes[i] & 0xFF);
      bufferSize += 8;
      
      while (bufferSize >= 5) {
        bufferSize -= 5;
        output += _alphabet[(buffer >> bufferSize) & 0x1F];
      }
    }
    
    if (bufferSize > 0) {
      buffer <<= (5 - bufferSize);
      output += _alphabet[buffer & 0x1F];
    }
    
    return output;
  }
}