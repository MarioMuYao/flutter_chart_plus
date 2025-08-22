import 'dart:math';

import 'package:example/page/extension_datetime.dart';
// import 'package:example/page/widget/wave_progress_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class PieChartDemoPage extends StatefulWidget {
  const PieChartDemoPage({Key? key}) : super(key: key);

  @override
  State<PieChartDemoPage> createState() => _PieChartDemoPageState();
}

class _PieChartDemoPageState extends State<PieChartDemoPage> with SingleTickerProviderStateMixin {
  final DateTime startTime = DateTime(2023, 1, 1);

  ChartController controller = ChartController();

  @override
  Widget build(BuildContext context) {
    final List<Map> dataList = [
      {
        'time': startTime.add(const Duration(days: 1)),
        'value1': 1.45,
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 3)),
        'value1': 1.83,
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 5)),
        'value1': 1.09,
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': 1.87,
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': 1.26,
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': 76.49,
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text("刷新"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Pie'),
            // SizedBox(
            //   height: 200,
            //   child: ChartWidget(
            //     coordinateRender: ChartCircularCoordinateRender(
            //       margin: const EdgeInsets.all(30),
            //       animationDuration: const Duration(seconds: 1),
            //       onClickChart: (BuildContext context, List<ChartLayoutState> list) {
            //         debugPrint("点击事件:$list");
            //       },
            //       charts: [
            //         Pie(
            //           data: dataList,
            //           position: (item, _) => (double.parse(item['value1'].toString())),
            //           valueFormatter: (item) => item['value1'].toString(),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // const Text('Hole Pie'),
            Container(
              color: Colors.lightBlue,
              child: Padding(
                padding: EdgeInsets.all(50),
                child: SizedBox(
                  height: 160,
                  child: ChartWidget(
                    controller: controller,
                    coordinateRender: ChartCircularCoordinateRender(
                      margin: EdgeInsets.all(30),
                      onClickChart: (context, list) {
                        print('=======${list.firstOrNull?.selectedIndex}');
                      },
                      borderWidth: 0,
                      animationDuration: const Duration(seconds: 1),
                      charts: [
                        Pie(
                          startAngle: -90 * pi / 180,
                          scale: 1.1,
                          spaceWidth: 2,
                          dividerColor: Colors.black,
                          guideLine: true,
                          lineColor: Colors.red,
                          // guideLineWidth: 20,
                          drawValueTextAfterAnimation: false,
                          data: dataList,
                          position: (item, index) => (double.parse(item['value1'].toString())),
                          holeRadius: 20,
                          // valueTextOffset: 20,
                          legendFormatter: (item) {
                            return '10%';
                          },
                          // legendValueFormatter: (p0) => 'sss',
                          centerTextStyle:
                              const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),

                          valueFormatter: (item) => '',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                controller.chartsStateList.firstOrNull?.selectedIndex = 2;
                controller.notify();
              },
              child: Text('aaaaa'),
            ),
          ],
        ),
      ),
    );
  }
}
