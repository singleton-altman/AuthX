import 'package:flutter/material.dart';
import 'package:authx/utils/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = AppTheme.primaryColor;
  double _avatarSize = 20.0; // 默认头像大小
  double _codeFontSize = 20.0; // 默认验证码文字大小
  
  // 获取当前主题模式
  ThemeMode get themeMode => _themeMode;
  
  // 获取主色调
  Color get primaryColor => _primaryColor;
  
  // 获取头像大小
  double get avatarSize => _avatarSize;
  
  // 获取验证码文字大小
  double get codeFontSize => _codeFontSize;

  // 设置主题模式
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // 设置主色调
  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
  
  // 设置头像大小
  void setAvatarSize(double size) {
    _avatarSize = size;
    notifyListeners();
  }
  
  // 设置验证码文字大小
  void setCodeFontSize(double size) {
    _codeFontSize = size;
    notifyListeners();
  }
}