import 'dart:ui';
import 'package:flutter/material.dart';

class ExpandedFab extends StatefulWidget {
  final VoidCallback onManualAdd;
  final VoidCallback onScanQR;
  final VoidCallback onImport;
  final VoidCallback onExport;

  const ExpandedFab({
    super.key,
    required this.onManualAdd,
    required this.onScanQR,
    required this.onImport,
    required this.onExport,
  });

  @override
  State<ExpandedFab> createState() => _ExpandedFabState();
}

class _ExpandedFabState extends State<ExpandedFab> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildSubButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          backgroundColor: Theme.of(context).cardTheme.color,
          foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
          onPressed: onTap,
          child: Icon(icon),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Stack(
      children: [
        // 遮罩层 - 使用MediaQuery获取完整屏幕尺寸
        if (_isExpanded)
          Positioned(
            top: 0, // 确保从顶部开始
            left: 0,
            right: 0,
            bottom: 0, // 确保到底部
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10.0 * _fadeAnimation.value,
                      sigmaY: 10.0 * _fadeAnimation.value,
                    ),
                    child: Container(
                      // 设置容器高度为整个屏幕高度
                      height: MediaQuery.of(context).size.height,
                      // 设置容器颜色并应用透明度动画
                      color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                    ),
                  );
                },
              ),
            ),
          ),
        
        // 主按钮和子按钮
        Positioned(
          right: 16,
          bottom: 16 + bottomPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 子按钮们（仅在展开时显示）
              if (_isExpanded)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOutBack,
                    )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSubButton(
                          icon: Icons.upload_outlined,
                          label: '导出',
                          onTap: () {
                            _toggleExpanded();
                            widget.onExport();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSubButton(
                          icon: Icons.download_outlined,
                          label: '导入',
                          onTap: () {
                            _toggleExpanded();
                            widget.onImport();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSubButton(
                          icon: Icons.qr_code_scanner,
                          label: '扫描二维码',
                          onTap: () {
                            _toggleExpanded();
                            widget.onScanQR();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSubButton(
                          icon: Icons.edit_outlined,
                          label: '手动添加',
                          onTap: () {
                            _toggleExpanded();
                            widget.onManualAdd();
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              
              // 主按钮（始终显示）
              FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                onPressed: _toggleExpanded,
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.125 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(_isExpanded ? Icons.close : Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}