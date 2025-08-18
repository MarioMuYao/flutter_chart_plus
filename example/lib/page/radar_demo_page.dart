import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class RadarChartDemoPage extends StatefulWidget {
  const RadarChartDemoPage({Key? key}) : super(key: key);

  @override
  State<RadarChartDemoPage> createState() => _RadarChartDemoPageState();
}

class _RadarChartDemoPageState extends State<RadarChartDemoPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map> dataList = [
      {
        'title': "饮食",
        'value1': 600,
        'value2': 300,
        'value3': 200,
      },
      {
        'title': "穿衣",
        'value1': 400,
        'value2': 200,
        'value3': 300,
      },
      {
        'title': "出行",
        'value1': 200,
        'value2': 400,
        'value3': 300,
      },
      {
        'title': "游戏",
        'value1': 400,
        'value2': 200,
        'value3': 100,
      },
      {
        'title': "运动",
        'value1': 100,
        'value2': 300,
        'value3': 200,
      },
      {
        'title': "泡妞",
        'value1': 100,
        'value2': 300,
        'value3': 200,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('radar'),
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 20),
              child: ChartWidget(
                coordinateRender: ChartCircularCoordinateRender(
                  borderColor: Colors.transparent,
                  margin: const EdgeInsets.all(20),
                  charts: [
                    Radar(
                      spacing: 8,
                      max: 600,
                      data: dataList,
                      fillColors: colors10.map((e) => e.withOpacity(0.2)).toList(),
                      // legendFormatter: () => dataList.map((e) => e['title']).toList(),
                      legendTextPainterBuilder: (item, index) => TextPainter(
                        textDirection: TextDirection.ltr,
                        textAlign: [4, 5].contains(index) ? TextAlign.end : TextAlign.start,
                        text: TextSpan(
                          text: '${item['title']}${[0, 3].contains(index) ? ' ' : '\n'}',
                          children: <InlineSpan>[
                            TextSpan(
                              text: '${item['value1']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      )..layout(maxWidth: 60),
                      // valueFormatter: (item) => [
                      //   item['value1'],
                      // ],
                      strokeWidth: 3,
                      lineColor: Colors.black,
                      lineBackgroundColorBuilder: (index) => index.isEven ? Colors.red : Colors.white,
                      values: (item) => [
                        (double.parse(item['value1'].toString())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 20),
              child: ChartWidget(
                coordinateRender: ChartCircularCoordinateRender(
                  margin: const EdgeInsets.all(12),
                  charts: [
                    Radar(
                      max: 600,
                      data: dataList,
                      borderStyle: RadarBorderStyle.circle,
                      fillColors: colors10.map((e) => e.withOpacity(0.2)).toList(),
                      legendFormatter: () => dataList.map((e) => e['title']).toList(),
                      valueFormatter: (item) => [
                        item['value1'],
                      ],
                      values: (item) => [
                        (double.parse(item['value1'].toString())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Text('multiple radar'),
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 20),
              child: ChartWidget(
                coordinateRender: ChartCircularCoordinateRender(
                  margin: const EdgeInsets.all(12),
                  charts: [
                    Radar(
                      max: 600,
                      data: dataList,
                      fillColors: colors10.map((e) => e.withOpacity(0.2)).toList(),
                      valueFormatter: (item) => [
                        item['value1'].toString(),
                        item['value2'].toString(),
                      ],
                      values: (item) => [
                        (double.parse(item['value1'].toString())),
                        (double.parse(item['value2'].toString())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
