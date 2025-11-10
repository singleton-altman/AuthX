import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorChanged;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示当前选中的颜色
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '当前颜色: ${_colorToHex(selectedColor)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showColorPickerDialog(context),
                child: const Text('选择颜色'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 将颜色转换为十六进制字符串
  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  // 显示颜色选择器对话框
  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择颜色'),
          content: SingleChildScrollView(
            child: ColorPickerWidget(
              initialColor: selectedColor,
              onColorChanged: (color) {
                onColorChanged(color);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorPickerWidget({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 色相选择器
        _ColorHuePicker(
          initialColor: _currentColor,
          onColorChanged: (color) {
            setState(() {
              _currentColor = color;
              widget.onColorChanged(color);
            });
          },
        ),
        const SizedBox(height: 20),
        // 饱和度和亮度选择器
        _ColorSaturationBrightnessPicker(
          initialColor: _currentColor,
          onColorChanged: (color) {
            setState(() {
              _currentColor = color;
              widget.onColorChanged(color);
            });
          },
        ),
        const SizedBox(height: 20),
        // 透明度选择器
        _ColorAlphaPicker(
          initialColor: _currentColor,
          onColorChanged: (color) {
            setState(() {
              _currentColor = color;
              widget.onColorChanged(color);
            });
          },
        ),
        const SizedBox(height: 20),
        // 颜色预览
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              _colorToHex(_currentColor),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 将颜色转换为十六进制字符串
  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}

// 色相选择器
class _ColorHuePicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const _ColorHuePicker({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  _ColorHuePickerState createState() => _ColorHuePickerState();
}

class _ColorHuePickerState extends State<_ColorHuePicker> {
  late double _hue;

  @override
  void initState() {
    super.initState();
    _hue = _colorToHue(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('色相 (H)'),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: GestureDetector(
            onTapUp: (TapUpDetails details) {
              _handleHueChange(details.localPosition.dx);
            },
            onPanUpdate: (DragUpdateDetails details) {
              _handleHueChange(details.localPosition.dx);
            },
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _HuePainter(
                selectedHue: _hue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleHueChange(double dx) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double width = renderBox.size.width;
    final double hue = (dx / width * 360.0).clamp(0.0, 360.0);
    
    setState(() {
      _hue = hue;
      Color newColor = HSVColor.fromAHSV(
        widget.initialColor.a,
        _hue,
        _colorToSaturation(widget.initialColor),
        _colorToValue(widget.initialColor),
      ).toColor();
      widget.onColorChanged(newColor);
    });
  }

  double _colorToHue(Color color) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    return hsvColor.hue;
  }

  double _colorToSaturation(Color color) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    return hsvColor.saturation;
  }

  double _colorToValue(Color color) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    return hsvColor.value;
  }
}

// 色相绘制器
class _HuePainter extends CustomPainter {
  final double selectedHue;

  _HuePainter({
    required this.selectedHue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 绘制色相渐变
    final Gradient gradient = LinearGradient(
      colors: [
        const Color(0xFFFF0000), // 红色
        const Color(0xFFFFFF00), // 黄色
        const Color(0xFF00FF00), // 绿色
        const Color(0xFF00FFFF), // 青色
        const Color(0xFF0000FF), // 蓝色
        const Color(0xFFFF00FF), // 品红
        const Color(0xFFFF0000), // 回到红色
      ],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // 绘制选择指示器
    final double indicatorPosition = (selectedHue / 360.0) * size.width;
    final Paint indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(indicatorPosition, 0),
      Offset(indicatorPosition, size.height),
      indicatorPaint,
    );

    // 绘制三角形指示器
    final Path trianglePath = Path();
    trianglePath.moveTo(indicatorPosition - 5, -5);
    trianglePath.lineTo(indicatorPosition + 5, -5);
    trianglePath.lineTo(indicatorPosition, -15);
    trianglePath.close();

    final Paint trianglePaint = Paint()..color = Colors.white;
    canvas.drawPath(trianglePath, trianglePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 饱和度和亮度选择器
class _ColorSaturationBrightnessPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const _ColorSaturationBrightnessPicker({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  _ColorSaturationBrightnessPickerState createState() =>
      _ColorSaturationBrightnessPickerState();
}

class _ColorSaturationBrightnessPickerState
    extends State<_ColorSaturationBrightnessPicker> {
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    HSVColor hsv = HSVColor.fromColor(widget.initialColor);
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('饱和度 (S) 和 亮度 (V)'),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 150,
          child: GestureDetector(
            onTapUp: (TapUpDetails details) {
              _handleSaturationValueChange(details.localPosition);
            },
            onPanUpdate: (DragUpdateDetails details) {
              _handleSaturationValueChange(details.localPosition);
            },
            child: CustomPaint(
              painter: _SaturationBrightnessPainter(
                hue: HSVColor.fromColor(widget.initialColor).hue,
                selectedSaturation: _saturation,
                selectedValue: _value,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('S: ${_saturation.toStringAsFixed(2)}'),
            Text('V: ${_value.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }

  void _handleSaturationValueChange(Offset localPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    
    final double saturation = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final double value = (1.0 - (localPosition.dy / size.height)).clamp(0.0, 1.0);
    
    setState(() {
      _saturation = saturation;
      _value = value;
      Color newColor = HSVColor.fromAHSV(
        widget.initialColor.a,
        HSVColor.fromColor(widget.initialColor).hue,
        saturation,
        value,
      ).toColor();
      widget.onColorChanged(newColor);
    });
  }
}

// 饱和度和亮度绘制器
class _SaturationBrightnessPainter extends CustomPainter {
  final double hue;
  final double selectedSaturation;
  final double selectedValue;

  _SaturationBrightnessPainter({
    required this.hue,
    required this.selectedSaturation,
    required this.selectedValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 绘制饱和度和亮度的渐变
    final Paint paint = Paint();
    final Gradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFFFFFFF), // 白色
        HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(), // 当前色相的纯色
      ],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // 绘制从底部到顶部的黑色渐变
    final Paint blackGradientPaint = Paint();
    final Gradient blackGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF000000), // 黑色
        const Color(0x00000000), // 透明
      ],
    );

    blackGradientPaint.shader = blackGradient.createShader(rect);
    canvas.drawRect(rect, blackGradientPaint);

    // 绘制选择指示器
    final double indicatorX = selectedSaturation * size.width;
    final double indicatorY = (1.0 - selectedValue) * size.height;

    final Paint indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      10,
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 透明度选择器
class _ColorAlphaPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const _ColorAlphaPicker({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  _ColorAlphaPickerState createState() => _ColorAlphaPickerState();
}

class _ColorAlphaPickerState extends State<_ColorAlphaPicker> {
  late double _alpha;

  @override
  void initState() {
    super.initState();
    _alpha = widget.initialColor.a;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('透明度 (A)'),
        const SizedBox(height: 10),
        Slider(
          value: _alpha,
          min: 0.0,
          max: 1.0,
          onChanged: (double value) {
            setState(() {
              _alpha = value;
              Color newColor = widget.initialColor.withValues(alpha: value);
              widget.onColorChanged(newColor);
            });
          },
        ),
        Text('A: ${_alpha.toStringAsFixed(2)}'),
      ],
    );
  }
}