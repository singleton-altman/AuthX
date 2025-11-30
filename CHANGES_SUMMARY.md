# TOTP Display Screen 深色模式和 UI 改进

## 概述
成功完成了 `totp_display_screen.dart` 的深色模式适配和 UI 改进，包括：
1. 完整的深色模式主题支持
2. 将圆形倒计时改为线性进度条
3. 添加标签显示功能

## 详细变更

### 1. 主题参数传递
- **修改的方法**：
  - `build()` 方法：获取当前主题数据并传递给子方法
  - `_buildHeaderSection(ThemeData theme)`：接收主题参数
  - `_buildTotpSection(ThemeData theme)`：接收主题参数
  - `_buildQuickAction()`：添加 `theme` 参数
  - `_buildMenuItem()`：添加 `theme` 参数
  - `_buildDivider()`：添加 `theme` 参数

### 2. 深色模式颜色适配

#### _buildHeaderSection（头部区域）
- **背景色**：`Colors.white` → `theme.colorScheme.surface`
- **文本色**：`Colors.black87` → `theme.colorScheme.onSurface`
- **副文本色**：`Colors.black54` → `theme.colorScheme.onSurface.withValues(alpha: 0.7)`
- **占位符背景**：`Color(0xFFF0F0F0)` → `theme.colorScheme.secondary.withValues(alpha: 0.1)`
- **占位符边框**：`Color(0xFFE0E0E0)` → `theme.dividerColor.withValues(alpha: 0.2)`

#### _buildTotpSection（验证码区域）
- **验证码背景**：`Color(0xFFF8F8F8)` → `theme.colorScheme.secondary.withValues(alpha: 0.08)`
- **验证码文本色**：`Colors.black87` → `theme.colorScheme.onSurface`
- **进度条颜色**：`Colors.blue` → `theme.primaryColor`（< 5秒时保持 `Colors.red`）
- **倒计时文本色**：新增合适的透明度和颜色

#### _buildQuickAction（快捷操作按钮）
- **按钮背景**：`Color(0xFFF8F8F8)` → `theme.colorScheme.secondary.withValues(alpha: 0.08)`
- **按钮边框**：`Color(0xFFE0E0E0)` → `theme.dividerColor.withValues(alpha: 0.2)`
- **图标颜色**：`Colors.blue` → `theme.primaryColor`
- **文本颜色**：`Colors.black87` → `theme.colorScheme.onSurface`

#### 菜单相关
- **菜单背景**：已使用 `theme.colorScheme.surface`
- **菜单项文本**：`Colors.black87` → `theme.colorScheme.onSurface`
- **分隔线颜色**：`Color(0xFFE5E5E5)` → `theme.dividerColor.withValues(alpha: 0.3)`
- **SnackBar 背景**：`Colors.blue` → `theme.primaryColor`

### 3. 标签显示功能
在 `_buildHeaderSection` 中添加标签显示：
```dart
if (widget.entry.tags.isNotEmpty) ...[
  const SizedBox(height: 16),
  Wrap(
    spacing: 8,
    runSpacing: 8,
    children: widget.entry.tags
        .map((tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))
        .toList(),
  ),
],
```

### 4. 倒计时 UI 改进
将圆形环形进度条替换为线性进度条（从右到左）：
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Stack(
    children: [
      // 背景
      Container(
        height: 8,
        width: double.infinity,
        color: theme.colorScheme.surfaceContainer
            .withValues(alpha: 0.3),
      ),
      // 进度条（从右到左）
      Align(
        alignment: Alignment.topRight,
        child: Container(
          height: 8,
          width: (remainingTime / 30) * MediaQuery.of(context).size.width - 64,
          decoration: BoxDecoration(
            color: remainingTime <= 5
                ? Colors.red
                : theme.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ],
  ),
),
```

## 构建结果
✓ 编译无错误
✓ Flutter analyze 通过
✓ iOS build 成功（17.8MB）

## 文件修改
- `/Users/dongshu/Desktop/MS/2FA/authx/lib/ui/screens/totp_display_screen.dart`

## 后续步骤
1. 在模拟器或真实设备上测试深色模式切换
2. 验证所有颜色在浅色和深色模式下的显示效果
3. 确保标签显示和进度条动画流畅
4. 测试所有菜单项和快捷操作按钮的响应
