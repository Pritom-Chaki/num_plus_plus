import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:num_plus_plus/src/backend/math_model.dart';

class FunctionPage extends StatelessWidget {
  const FunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plot'),),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        width: double.infinity,
        height: double.infinity,
        child: const FunctionChart(),
      ),
    );
  }
}

typedef CalculationFunction = num Function(num x);

class FunctionChart extends StatefulWidget {
  const FunctionChart({super.key});

  @override
  FunctionChartState createState() => FunctionChartState();
}

class FunctionChartState extends State<FunctionChart> {
  List<double> xCoordinate = <double>[];
  List<FlSpot> _spots = <FlSpot>[];
  double start = -6.0;
  double end = 6.0;

  @override
  void initState() {
    super.initState();
    _spots = _plotData(Provider.of<FunctionModel>(context, listen: false).calc, start, end);
  }

  List<FlSpot> _plotData(CalculationFunction calc, double start, double end) {
    const interval = 500;
    double step = (end - start) / interval;
    List<FlSpot> spots = [];
    for (var i = 0; i < interval; i++) {
      var result = calc(start+step*i);
      if (result.isFinite) {
        spots.add(FlSpot(start+step*i, double.parse(result.toString())));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    // onTap: () {
    //   debugPrint('tap');
    // },
    onScaleStart: (detail) {
      debugPrint('object');
    },
    child: LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _spots,
            isCurved: true,
            dotData: FlDotData(
              show: false,
            ),
          ),
          LineChartBarData(
            spots: [
              FlSpot(start, 0),
              FlSpot(end, 0),
            ],
            colors: [Colors.black],
            dotData: FlDotData(
              show: false,
            ),
          ),
          LineChartBarData(
            spots: [
              FlSpot(0, -5.0),
              FlSpot(0, 5.0),
            ],
            colors: [Colors.black],
            dotData: FlDotData(
              show: false,
            ),
          ),
        ],
        gridData: FlGridData(
          show: false,
          getDrawingHorizontalLine: (value) {
            return FlLine();
          }
        ),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: false,
            getTitles: (value) {
              if(value.remainder(5) == 0) {
                return value.toInt().toString();
              } else {
                return '0';
              }
            }
          ),
          leftTitles: SideTitles(
            showTitles: false,
            getTitles: (value) {
              if(value.remainder(5) == 0) {
                return value.toInt().toString();
              } else {
                return '0';
              }
            }
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: false,
          fullHeightTouchLine: false,
          handleBuiltInTouches: false,
          // touchCallback: (response) {
          //   if (response.touchInput.getOffset().dx != 0.0) {
          //     if (xCoordinate.length < 2) {
          //       xCoordinate.add(response.touchInput.getOffset().dx);
          //     } else {
          //       xCoordinate.removeAt(0);
          //       xCoordinate.add(response.touchInput.getOffset().dx);
          //       setState(() {
          //         start += xCoordinate[1] - xCoordinate[0];
          //         end += xCoordinate[1] - xCoordinate[0];
          //         _spots = _plotData(Provider.of<FunctionModel>(context, listen: false).calc, start, end);
          //       });
          //     }
          //   }
          // },
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 10),
    ),
  );
}