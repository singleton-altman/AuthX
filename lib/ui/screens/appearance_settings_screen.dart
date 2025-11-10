import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/ui/widgets/circular_progress_avatar.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('外观设置'),
        elevation: 0,
      ),
      body: _AppearanceSettingsBody(
        animationController: _animationController,
      ),
    );
  }
}

class _AppearanceSettingsBody extends StatelessWidget {
  final AnimationController animationController;

  const _AppearanceSettingsBody({
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                // 显示设置
                _DisplaySettingsSection(themeProvider: themeProvider),
                
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                
                // 主题颜色设置
                _ThemeColorSection(themeProvider: themeProvider),
                
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                
                // 主题模式设置
                _ThemeModeSection(),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 显示设置部分
class _DisplaySettingsSection extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _DisplaySettingsSection({
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
            border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.text_fields_outlined,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '显示设置',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 实时预览
            _InteractivePreview(themeProvider: themeProvider),
            
            const SizedBox(height: 20),
            
            // 显示控制
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _DisplayControls(themeProvider: themeProvider),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 交互式预览组件
class _InteractivePreview extends StatefulWidget {
  final ThemeProvider themeProvider;

  const _InteractivePreview({
    required this.themeProvider,
  });

  @override
  State<_InteractivePreview> createState() => _InteractivePreviewState();
}

class _InteractivePreviewState extends State<_InteractivePreview> {
  late Timer _timer;
  String _currentCode = '';
  int _timeRemaining = 30;

  @override
  void initState() {
    super.initState();
    _updateCode();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = (_timeRemaining - 1) % 30;
        if (_timeRemaining == 29) {
          _updateCode();
        }
      });
    });
  }

  void _updateCode() {
    // 生成随机6位数字作为预览
    final random = Random();
    _currentCode = List.generate(6, (_) => random.nextInt(10).toString()).join('');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 头像
          CircularProgressAvatar(
            issuer: 'A',
            size: widget.themeProvider.avatarSize,
            remainingTime: _timeRemaining,
            period: 30,
            progressColor: widget.themeProvider.primaryColor,
          ),
          
          const SizedBox(width: 12),
          
          // 信息区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '预览账户',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'authx@example.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // TOTP代码
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currentCode,
                style: TextStyle(
                  fontSize: widget.themeProvider.codeFontSize,
                  fontWeight: FontWeight.w600,
                  color: widget.themeProvider.primaryColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_timeRemaining秒',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 显示控制组件
class _DisplayControls extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _DisplayControls({
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        
        if (isSmallScreen) {
          // 小屏幕：垂直布局
          return Column(
            children: [
              _AdvancedSizeControl(
                icon: Icons.person_outline,
                title: '头像大小',
                currentValue: themeProvider.avatarSize.toInt(),
                min: 16,
                max: 48,
                onChanged: themeProvider.setAvatarSize,
                themeProvider: themeProvider,
              ),
              const SizedBox(height: 16),
              _AdvancedSizeControl(
                icon: Icons.text_fields_outlined,
                title: '文字大小',
                currentValue: themeProvider.codeFontSize.toInt(),
                min: 12,
                max: 32,
                onChanged: themeProvider.setCodeFontSize,
                themeProvider: themeProvider,
              ),
            ],
          );
        } else {
          // 大屏幕：水平布局
          return Row(
            children: [
              Expanded(
                child: _AdvancedSizeControl(
                  icon: Icons.person_outline,
                  title: '头像大小',
                  currentValue: themeProvider.avatarSize.toInt(),
                  min: 16,
                  max: 48,
                  onChanged: themeProvider.setAvatarSize,
                  themeProvider: themeProvider,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AdvancedSizeControl(
                  icon: Icons.text_fields_outlined,
                  title: '文字大小',
                  currentValue: themeProvider.codeFontSize.toInt(),
                  min: 12,
                  max: 32,
                  onChanged: themeProvider.setCodeFontSize,
                  themeProvider: themeProvider,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// 高级尺寸控制组件
class _AdvancedSizeControl extends StatefulWidget {
  final IconData icon;
  final String title;
  final int currentValue;
  final int min;
  final int max;
  final Function(double) onChanged;
  final ThemeProvider themeProvider;

  const _AdvancedSizeControl({
    required this.icon,
    required this.title,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.themeProvider,
  });

  @override
  State<_AdvancedSizeControl> createState() => _AdvancedSizeControlState();
}

class _AdvancedSizeControlState extends State<_AdvancedSizeControl> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  double _dragValue = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _dragValue = widget.currentValue.toDouble();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _animationController.forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final double width = box.size.width;
    final double dragDelta = details.delta.dx;
    
    setState(() {
      _dragValue += (dragDelta / width) * (widget.max - widget.min);
      _dragValue = _dragValue.clamp(widget.min.toDouble(), widget.max.toDouble());
      
      // 立即更新
      widget.onChanged(_dragValue.roundToDouble());
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragValue = widget.currentValue.toDouble();
    });
    _animationController.reverse();
  }

  void _onTapAdd() {
    if (widget.currentValue < widget.max) {
      setState(() {
        _dragValue = (widget.currentValue + 1).toDouble();
      });
      widget.onChanged(_dragValue);
      _playHapticFeedback();
    }
  }

  void _onTapSubtract() {
    if (widget.currentValue > widget.min) {
      setState(() {
        _dragValue = (widget.currentValue - 1).toDouble();
      });
      widget.onChanged(_dragValue);
      _playHapticFeedback();
    }
  }

  void _playHapticFeedback() {
    // 模拟触觉反馈
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (widget.currentValue - widget.min) / (widget.max - widget.min);

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isDragging ? _scaleAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDragging 
                    ? widget.themeProvider.primaryColor.withValues(alpha: 0.05)
                    : theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isDragging
                      ? widget.themeProvider.primaryColor.withValues(alpha: 0.2)
                      : theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和图标
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            widget.icon,
                            size: 18,
                            color: widget.themeProvider.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.themeProvider.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.currentValue}px',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.themeProvider.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 进度条
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Stack(
                      children: [
                        // 背景
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        // 进度
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          height: 4,
                          width: MediaQuery.of(context).size.width * 0.25 * progress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.themeProvider.primaryColor,
                                widget.themeProvider.primaryColor.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: widget.themeProvider.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        
                        // 滑块指示器
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.25 * progress - 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.themeProvider.primaryColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.themeProvider.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 按钮控制
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 减小按钮
                      _ControlButton(
                        icon: Icons.remove,
                        isEnabled: widget.currentValue > widget.min,
                        onTap: _onTapSubtract,
                        themeProvider: widget.themeProvider,
                      ),
                      
                      // 数值标签
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${widget.currentValue}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.themeProvider.primaryColor,
                          ),
                        ),
                      ),
                      
                      // 增大按钮
                      _ControlButton(
                        icon: Icons.add,
                        isEnabled: widget.currentValue < widget.max,
                        onTap: _onTapAdd,
                        themeProvider: widget.themeProvider,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 控制按钮组件
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;
  final ThemeProvider themeProvider;

  const _ControlButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled 
              ? themeProvider.primaryColor.withValues(alpha: 0.1)
              : theme.disabledColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled 
                ? themeProvider.primaryColor.withValues(alpha: 0.3)
                : theme.disabledColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? themeProvider.primaryColor : theme.disabledColor,
        ),
      ),
    );
  }
}

// 主题颜色设置部分
class _ThemeColorSection extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _ThemeColorSection({
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
            border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '主题颜色',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 颜色选择器
            _ThemeColorSettings(themeProvider: themeProvider),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// 主题颜色设置组件
class _ThemeColorSettings extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _ThemeColorSettings({
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 定义预设颜色列表
    final presetColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: presetColors.map((color) {
          final isSelected = themeProvider.primaryColor == color;
          
          return GestureDetector(
            onTap: () => themeProvider.setPrimaryColor(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? Colors.white
                      : theme.dividerColor.withValues(alpha: 0.3),
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// 主题模式设置部分
class _ThemeModeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
            border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_medium_outlined,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '主题模式',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 主题模式选项
            const _ThemeModeSettings(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// 主题模式设置
class _ThemeModeSettings extends StatelessWidget {
  const _ThemeModeSettings();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;

    return Column(
      children: [
        _ThemeModeOption(
          icon: Icons.wb_sunny,
          title: '亮色模式',
          subtitle: '使用浅色主题',
          isSelected: themeMode == ThemeMode.light,
          onTap: () => themeProvider.setThemeMode(ThemeMode.light),
        ),
        _ThemeModeOption(
          icon: Icons.nightlight,
          title: '暗色模式',
          subtitle: '使用深色主题',
          isSelected: themeMode == ThemeMode.dark,
          onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
        ),
        _ThemeModeOption(
          icon: Icons.sync,
          title: '跟随系统',
          subtitle: '自动匹配系统主题',
          isSelected: themeMode == ThemeMode.system,
          onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          isLast: true,
        ),
      ],
    );
  }
}

// 主题模式选项
class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLast;

  const _ThemeModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}