part of flutter_chart_plus;

typedef RadarChartValue<T> = List<num> Function(T);
typedef RadarValueFormatter<T> = List<dynamic> Function(T);
typedef RadarLegendFormatter = List<dynamic> Function();
typedef RadarLegendTextPainterBuilder<T> = TextPainter Function(T, int);
typedef RadarLineBackgroundColorBuilder = Color Function(int);

enum RadarBorderStyle {
  polygon, //多边形
  circle, //圆形
}

///雷达图
/// @author JD
class Radar<T> extends ChartBodyRender<T> {
  Radar({
    required super.data,
    required this.values,
    required this.max,
    this.dashStartSpacing = 0,
    this.lineWidth = 1,
    this.lineColor = Colors.black12,
    this.direction = RotateDirection.forward,
    this.valueFormatter,
    this.legendFormatter,
    this.legendTextPainterBuilder,
    this.lineBackgroundColorBuilder,
    this.strokeWidth = 1,
    this.colors = colors10,
    this.startAngle = -math.pi / 2,
    this.fillColors,
    this.count = 5,
    this.spacing = 4,
    this.borderStyle = RadarBorderStyle.polygon,
    this.legendTextStyle = const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
  });

  ///开始的方向
  final RotateDirection direction;

  ///最大值
  final num max;

  ///点的位置
  final RadarChartValue<T> values;

  ///值文案格式化 不要使用过于耗时的方法
  final RadarValueFormatter<T>? valueFormatter;

  ///图例文案格式化 不要使用过于耗时的方法
  final RadarLegendFormatter? legendFormatter;

  final RadarLegendTextPainterBuilder? legendTextPainterBuilder;

  final RadarLineBackgroundColorBuilder? lineBackgroundColorBuilder;

  final double dashStartSpacing;

  ///基线的宽度
  final double lineWidth;

  ///基线的颜色
  final Color lineColor;

  /// 值线的宽度
  final double strokeWidth;

  ///值的线颜色
  final List<Color> colors;

  ///值的填充颜色
  final List<Color>? fillColors;

  ///图例样式
  final TextStyle legendTextStyle;

  ///开始弧度，可以调整起始位置
  final double startAngle;

  ///分隔线的数量
  final int count;

  ///间隔
  final double spacing;

  final RadarBorderStyle borderStyle;

  late double _sweepAngle;
  late final Paint _linePaint = Paint()
    ..strokeWidth = lineWidth
    ..isAntiAlias = true
    ..color = lineColor
    ..style = PaintingStyle.stroke;
  late final Paint _dataLinePaint = Paint()
    ..strokeWidth = strokeWidth
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
  Paint? _fillDataLinePaint;

  @override
  void init(ChartsState state) {
    ChartCircularCoordinateState layout = state.layout as ChartCircularCoordinateState;

    super.init(state);
    _linePathList.clear();
    _borderLinePaths.clear();
    _textPainterList.clear();
    _dataLinePathList.clear();

    int itemLength = data.length;
    double percent = 1 / itemLength;
    // 计算出每个数据所占的弧度值
    _sweepAngle = percent * math.pi * 2 * (direction == RotateDirection.forward ? 1 : -1);

    if (fillColors != null) {
      _fillDataLinePaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill;
    }

    //图例
    List<dynamic>? legendList = legendFormatter?.call();
    Offset center = layout.center;
    double radius = layout.radius;

    if (borderStyle == RadarBorderStyle.polygon) {
      _borderLinePaths = List.generate(count, (index) => Path());
    }
    double dividerRadius = layout.radius / count;

    for (int i = 0; i < itemLength; i++) {
      //开始点
      double startAngle = this.startAngle + _sweepAngle * i;
      T itemData = data[i];
      //画边框
      double x = math.cos(startAngle) * radius + center.dx;
      final y = math.sin(startAngle) * radius + center.dy;
      _linePathList.add(_buildDashPath(
          Path()
            ..moveTo(x, y)
            ..lineTo(center.dx, center.dy),
          4,
          4));

      //画分隔线
      if (borderStyle == RadarBorderStyle.polygon) {
        for (int ii = 0; ii < count; ii++) {
          final r = dividerRadius * (ii + 1);
          final x1 = math.cos(startAngle) * r + center.dx;
          final y1 = math.sin(startAngle) * r + center.dy;
          if (i == 0) {
            _borderLinePaths[ii].moveTo(x1, y1);
          } else {
            _borderLinePaths[ii].lineTo(x1, y1);
          }
        }
      }

      if (legendTextPainterBuilder != null || legendList != null) {
        TextPainter? legendTextPainter;
        if (legendTextPainterBuilder != null) {
          legendTextPainter = legendTextPainterBuilder?.call(itemData, i);
        } else if (legendList != null) {
          legendTextPainter = TextPainter(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: legendList[i].toString(),
              style: legendTextStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout(
              minWidth: 0,
              maxWidth: layout.size.width,
            );
        }
        if (legendTextPainter != null) {
          Offset textOffset = Offset(
            x < center.dx
                ? (x - legendTextPainter.width - spacing)
                : x > center.dx
                    ? x + spacing
                    : x - legendTextPainter.width / 2,
            x == center.dx
                ? y > center.dy
                    ? y + spacing
                    : y < center.dy
                        ? y - legendTextPainter.height - spacing
                        : y - legendTextPainter.height / 2
                : y - legendTextPainter.height / 2,
          );
          //最后再绘制，防止被挡住
          _textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
        }
      }

      //画value线
      List<num> pos = values.call(itemData);
      List<dynamic>? valueLegendList = valueFormatter?.call(itemData);
      assert(valueLegendList == null || pos.length == valueLegendList.length);
      for (int j = 0; j < pos.length; j++) {
        Path? dataLinePath = _dataLinePathList[j];
        if (dataLinePath == null) {
          dataLinePath = Path();
          _dataLinePathList[j] = dataLinePath;
        }
        num subPos = pos[j];
        double vp = subPos / max;
        double newRadius = radius * vp;
        final dataX = math.cos(startAngle) * newRadius + center.dx;
        final dataY = math.sin(startAngle) * newRadius + center.dy;
        if (i == 0) {
          dataLinePath.moveTo(dataX, dataY);
        } else {
          dataLinePath.lineTo(dataX, dataY);
        }

        //画文案
        if (valueLegendList != null) {
          String legend = valueLegendList[j].toString();
          TextPainter legendTextPainter = TextPainter(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: legend,
              style: legendTextStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout(
              minWidth: 0,
              maxWidth: layout.size.width,
            );
          bool isLeft = dataX < center.dx;
          bool isTop = dataY <= (center.dy - radius) && legendList != null;
          Offset textOffset = Offset(
              isLeft ? (dataX - legendTextPainter.width) : dataX, isTop ? dataY : dataY - legendTextPainter.height);
          //最后再绘制，防止被挡住
          _textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
        }
      }
    }

    if (borderStyle == RadarBorderStyle.polygon) {
      for (var element in _borderLinePaths) {
        element.close();
      }
    }
  }

  /// 虚线
  Path _buildDashPath(Path path, double dashWidth, double gapWidth) {
    final Path r = Path();
    for (ui.PathMetric metric in path.computeMetrics()) {
      double start = 0.0;
      while (start < metric.length - dashStartSpacing) {
        double end = start + dashWidth;
        r.addPath(metric.extractPath(start, end), Offset.zero);
        start = end + gapWidth;
      }
    }
    return r;
  }

  ///由内向外的线
  final List<Path> _linePathList = [];

  ///外边框
  List<Path> _borderLinePaths = [];

  ///图例 和 value
  final List<RadarTextPainter> _textPainterList = [];

  ///数据相关的path
  final Map<int, Path> _dataLinePathList = {};

  @override
  void draw(Canvas canvas, ChartsState state) {
    ChartCircularCoordinateState layout = state.layout as ChartCircularCoordinateState;
    double dividerRadius = layout.radius / count;
    if (borderStyle == RadarBorderStyle.circle) {
      if (lineBackgroundColorBuilder != null) {
        for (int i = count - 1; i >= 0; i--) {
          canvas.drawCircle(
            layout.center,
            dividerRadius * (i + 1),
            _linePaint
              ..style = PaintingStyle.fill
              ..color = lineBackgroundColorBuilder?.call(i) ?? Colors.transparent,
          );
        }
      }
      for (int ii = 0; ii < count; ii++) {
        canvas.drawCircle(
          layout.center,
          dividerRadius * (ii + 1),
          _linePaint
            ..style = PaintingStyle.stroke
            ..color = lineColor,
        );
      }
    } else if (borderStyle == RadarBorderStyle.polygon) {
      if (lineBackgroundColorBuilder != null) {
        for (int i = _borderLinePaths.length - 1; i >= 0; i--) {
          canvas.drawPath(
            _borderLinePaths[i],
            _linePaint
              ..style = PaintingStyle.fill
              ..color = lineBackgroundColorBuilder?.call(i) ?? Colors.transparent,
          );
        }
      }
      //画边框
      for (var element in _borderLinePaths) {
        canvas.drawPath(
          element,
          _linePaint
            ..style = PaintingStyle.stroke
            ..color = lineColor,
        );
      }
    }

    for (var element in _linePathList) {
      canvas.drawPath(element, _linePaint);
    }

    //画数据
    int index = 0;
    for (Path dataPath in _dataLinePathList.values) {
      dataPath.close();
      // 设置绘制属性
      _dataLinePaint.color = colors[index];
      canvas.drawPath(dataPath, _dataLinePaint);

      if (fillColors != null) {
        _fillDataLinePaint?.color = fillColors![index];
        canvas.drawPath(dataPath, _fillDataLinePaint!);
      }
      index++;
    }
    //最后再绘制，防止被挡住
    for (RadarTextPainter textPainter in _textPainterList) {
      textPainter.textPainter.paint(canvas, textPainter.offset);
    }
  }
}

class RadarTextPainter {
  final TextPainter textPainter;
  final Offset offset;
  RadarTextPainter({required this.textPainter, required this.offset});
}
