import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/widgets/divider.dart';
import 'package:zmartrest/widgets/chart_sheet.dart';

class DataVisualizationScreen extends StatefulWidget {
  final Map<String, dynamic> selectedUser;
  final String currentTheme;
  final List<Map<String, dynamic>> accelerometerData;
  final List<Map<String, dynamic>> heartRateData;
  final List<Map<String, dynamic>> rmssdData;
  final List<Map<String, dynamic>> rmssdBaselineData;
  final ShadDateTimeRange? selectedDateRange;
  final Function(ShadDateTimeRange range) onDateRangeSelected;
  final bool isLoading;
  final bool hasFetchedData;

  const DataVisualizationScreen({
    Key? key,
    required this.selectedUser,
    required this.currentTheme,
    required this.accelerometerData,
    required this.heartRateData,
    required this.rmssdData,
    required this.rmssdBaselineData,
    this.selectedDateRange,
    required this.onDateRangeSelected,
    required this.isLoading,
    required this.hasFetchedData,
  }) : super(key: key);

  @override
  _DataVisualizationState createState() => _DataVisualizationState();
}

double getMaxRmssd(List<dynamic> data) {
  //debugPrint('RMSSD data in data_visualization_screen: $data');

  double maxValue = 0;
  for (var point in data) {
    double rmssd = (point['rmssd'] as num).toDouble();
    if (rmssd > maxValue) {
      maxValue = rmssd;
    }
  }
  //debugPrint('Max rmssd: $maxValue');
  return maxValue;
}

class _DataVisualizationState extends State<DataVisualizationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _displayHeartRate = true;
  bool _displayAccelerometer = true;
  bool _displayRmssd = true;
  bool _trendlines = false;

  @override
  Widget build(BuildContext context) {
    final maxRmssd = getMaxRmssd(widget.rmssdData);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 60),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: ShadDateRangePickerFormField(
                width: MediaQuery.of(context).size.width - 60,
                mainAxisAlignment: MainAxisAlignment.center,
                label: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  alignment: Alignment.center,
                  child: Text('Date range',),
                ),
                initialValue: widget.selectedDateRange,
                validator: (v) {
                  if (v == null) return 'A range of dates is required.';
                  if (v.start == null) return 'The start date is required.';
                  if (v.end == null) return 'The end date is required.';
                  return null;
                },
                onChanged: (ShadDateTimeRange? range) {
                  if (range?.start != null && range?.end != null) {
                    widget.onDateRangeSelected(range!);
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadSwitch(value: _displayHeartRate, onChanged: (value) => setState(() => _displayHeartRate = value), label: const Text('Heart Rate'), checkedTrackColor: Colors.redAccent,),
                    ShadSwitch(value: _displayAccelerometer, onChanged: (value) => setState(() => _displayAccelerometer = value), label: const Text('Accelerometer'), checkedTrackColor: Colors.blueAccent,),
                    ShadSwitch(value: _displayRmssd, onChanged: (value) => setState(() => _displayRmssd = value), label: const Text('RMSSD'), checkedTrackColor: Colors.deepPurpleAccent,),
                  ],
                ),
                Column(
                  children: [
                    ShadButton.secondary(
                      height: 90,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text('Configure charts'),
                      onPressed: () => showShadSheet(
                        context: context,
                        builder: (context) => TimeFilterSheet(
                          onSave: (trendlines) {
                            if (trendlines) {
                              setState(() {
                                _trendlines = trendlines;
                              });
                            }
                          },
                          trendlines: _trendlines,
                          onSwitch: (value) {
                            setState(() {
                              _trendlines = value;
                            });
                          },
                        ),
                        side: ShadSheetSide.right,
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 60,
              child: VisualDivider(currentTheme: widget.currentTheme)
            ),
            const SizedBox(height: 40),
            if (widget.isLoading)
              const CircularProgressIndicator()
            else if (!widget.hasFetchedData)
              const Text('Select a date range to fetch data')
            else if (widget.hasFetchedData && widget.accelerometerData.isEmpty && widget.heartRateData.isEmpty)
              const Text('No data available for the selected date range')
            else
              Column(
                children: [
                  // Heart Rate Chart
                  if (widget.heartRateData.isNotEmpty && _displayHeartRate) ...[
                    const Text(
                      'Heart Rate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: SfCartesianChart(
                        tooltipBehavior: TooltipBehavior(enable: true),
                        trackballBehavior: TrackballBehavior(
                          enable: true,
                          activationMode: ActivationMode.singleTap,
                          tooltipSettings: InteractiveTooltip(format: 'point.y BPM'),
                        ),
                        primaryXAxis: DateTimeCategoryAxis(
                          intervalType: DateTimeIntervalType.hours,
                          dateFormat: DateFormat('HH:mm'),
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: widget.heartRateData.isEmpty
                              ? 0
                              : widget.heartRateData
                                      .map((e) => (e['hr'] as num).toDouble())
                                      .reduce((a, b) => a < b ? a : b) -
                                  5,
                          maximum: widget.heartRateData.isEmpty
                              ? 100
                              : widget.heartRateData
                                      .map((e) => (e['hr'] as num).toDouble())
                                      .reduce((a, b) => a > b ? a : b) +
                                  5,
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        plotAreaBorderWidth: 0,
                        series: <CartesianSeries<dynamic, dynamic>>[
                          LineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: widget.heartRateData,
                            trendlines: <Trendline>[
                              if (_trendlines) Trendline(color: widget.currentTheme == 'dark' ? const Color.fromARGB(255, 46, 46, 46) : const Color.fromARGB(255, 196, 196, 196), type: TrendlineType.linear),
                            ],
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                DateTime.fromMillisecondsSinceEpoch(
                                    (data['timestamp'] * 1000).toInt()),
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                (data['hr'] as num).toDouble(),
                            color: Colors.redAccent,
                            enableTooltip: true,
                            markerSettings: MarkerSettings(
                              //isVisible: true,
                              isVisible: false,
                              shape: DataMarkerType.circle,
                              color: widget.currentTheme == 'light' 
                                  ? Colors.white 
                                  : const Color.fromARGB(255, 15, 15, 15),
                              width: 6,
                              height: 6,
                              borderWidth: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 60),
                  // Accelerometer Chart
                  if (widget.accelerometerData.isNotEmpty && _displayAccelerometer) ...[
                    const Text(
                      'Accelerometer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: SfCartesianChart(
                        tooltipBehavior: TooltipBehavior(enable: true),
                        trackballBehavior: TrackballBehavior(
                          enable: true,
                          activationMode: ActivationMode.singleTap,
                        ),
                        primaryXAxis: DateTimeCategoryAxis(
                          intervalType: DateTimeIntervalType.hours,
                          dateFormat: DateFormat('HH:mm'),
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        plotAreaBorderWidth: 0,
                        series: <CartesianSeries<dynamic, dynamic>>[
                          // X axis
                          SplineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: widget.accelerometerData,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                DateTime.fromMillisecondsSinceEpoch(
                                    (data['timestamp'] * 1000).toInt()),
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                (data['x'] as num).toDouble(),
                            color: Colors.blue,
                            enableTooltip: true,
                            markerSettings: MarkerSettings(
                              //isVisible: true,
                              isVisible: false,
                              shape: DataMarkerType.circle,
                              color: widget.currentTheme == 'light' 
                                  ? Colors.white 
                                  : const Color.fromARGB(255, 15, 15, 15),
                              width: 6,
                              height: 6,
                              borderWidth: 0,
                            ),
                          ),
                          // Y axis
                          SplineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: widget.accelerometerData,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                DateTime.fromMillisecondsSinceEpoch(
                                    (data['timestamp'] * 1000).toInt()),
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                (data['y'] as num).toDouble(),
                            color: Colors.green,
                            enableTooltip: true,
                            markerSettings: MarkerSettings(
                              //isVisible: true,
                              isVisible: false,
                              shape: DataMarkerType.circle,
                              color: widget.currentTheme == 'light' 
                                  ? Colors.white 
                                  : const Color.fromARGB(255, 15, 15, 15),
                              width: 6,
                              height: 6,
                              borderWidth: 0,
                            ),
                          ),
                          // Z axis
                          SplineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: widget.accelerometerData,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                DateTime.fromMillisecondsSinceEpoch(
                                    (data['timestamp'] * 1000).toInt()),
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                (data['z'] as num).toDouble(),
                            color: Colors.orange,
                            enableTooltip: true,
                            markerSettings: MarkerSettings(
                              //isVisible: true,
                              isVisible: false,
                              shape: DataMarkerType.circle,
                              color: widget.currentTheme == 'light' 
                                  ? Colors.white 
                                  : const Color.fromARGB(255, 15, 15, 15),
                              width: 6,
                              height: 6,
                              borderWidth: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Legend for accelerometer data
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendItem(color: Colors.blue, label: 'X-axis'),
                          SizedBox(width: 16),
                          _LegendItem(color: Colors.green, label: 'Y-axis'),
                          SizedBox(width: 16),
                          _LegendItem(color: Colors.orange, label: 'Z-axis'),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 60),
                  if (widget.rmssdData.isNotEmpty && _displayRmssd) ...[
                    const Text(
                      'RMSSD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: SfCartesianChart(
                        tooltipBehavior: TooltipBehavior(enable: true),
                        trackballBehavior: TrackballBehavior(
                          enable: true,
                          activationMode: ActivationMode.singleTap,
                        ),
                        primaryXAxis: DateTimeCategoryAxis(
                          intervalType: DateTimeIntervalType.hours,
                          dateFormat: DateFormat('HH:mm'),
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        plotAreaBorderWidth: 0,
                        series: <CartesianSeries<Map<String, dynamic>, DateTime>>[
                          SplineSeries(
                            dataSource: widget.rmssdData,
                            trendlines: <Trendline>[
                              if (_trendlines) Trendline(color: widget.currentTheme == 'dark' ? const Color.fromARGB(255, 46, 46, 46) : const Color.fromARGB(255, 196, 196, 196), type: TrendlineType.linear),
                            ],
                            xValueMapper: ( data, _) =>
                                DateTime.fromMillisecondsSinceEpoch(
                                  (data['timestamp'] * 1000).toInt()),
                            yValueMapper: (data, _) =>
                                (data['rmssd'] as num).toDouble(),
                            color: Colors.deepPurpleAccent,
                            enableTooltip: true,
                            markerSettings: MarkerSettings(
                              //isVisible: true,
                              isVisible: false,
                              shape: DataMarkerType.circle,
                              color: widget.currentTheme == 'light' 
                                  ? Colors.white 
                                  : const Color.fromARGB(255, 15, 15, 15),
                              width: 6,
                              height: 6,
                              borderWidth: 0,
                            ),
                          ),
                          StepAreaSeries(
                            enableTrackball: false,
                            dataSource: widget.rmssdData,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                DateTime.fromMillisecondsSinceEpoch(
                                  (data['timestamp'] * 1000).toInt()),
                            yValueMapper: (Map<String, dynamic>data, _) {
                              return data['is_exercising'] ? maxRmssd : 0.0;
                            },
                            color: const Color.fromARGB(255, 255, 95, 149),
                            opacity: 0.2,
                            markerSettings: MarkerSettings(
                              //isVisible: true,
                              isVisible: false,
                              shape: DataMarkerType.circle,
                              color: widget.currentTheme == 'light' 
                                  ? Colors.white 
                                  : const Color.fromARGB(255, 15, 15, 15),
                              width: 6,
                              height: 6,
                              borderWidth: 0,
                            ),
                          ),
                          SplineSeries(
                              dataSource: widget.rmssdBaselineData,
                              xValueMapper: (Map<String, dynamic> data, _) =>
                                  DateTime.fromMillisecondsSinceEpoch(
                                    (data['timestamp'] * 1000).toInt()),
                              yValueMapper: (data, _) {
                                debugPrint("Baseline data in chart: ${data.toString()}");
                                return (data['rmssd_baseline'] as num).toDouble();
                                /*
                                debugPrint("Baseline data in chart: ${data.toString()}");
                                if (data['rmssd_baseline'] != null) {
                                  debugPrint("Baseline data in chart: ${data['rmssd_baseline'].toString()}");
                                  return (data['rmssd_baseline'] as num).toDouble();
                                } else if (data['rmssd'] != null) {
                                  debugPrint("Baseline data in chart: ${data['rmssd'].toString()}");
                                  //return (data['rmssd'] as num).toDouble();
                                }
                                return 0.0;
                                */

                              },
                              color: Colors.deepOrangeAccent,
                              enableTooltip: true,
                              markerSettings: MarkerSettings(
                                //isVisible: true,
                                isVisible: false,
                                shape: DataMarkerType.circle,
                                color: widget.currentTheme == 'light' 
                                    ? Colors.white 
                                    : const Color.fromARGB(255, 15, 15, 15),
                                width: 6,
                                height: 6,
                                borderWidth: 0,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendItem(color: Colors.deepOrangeAccent, label: 'Baseline'),
                          SizedBox(width: 16),
                          _LegendItem(color: Colors.deepPurpleAccent, label: 'RMSSD'),
                          SizedBox(width: 16),
                          _LegendItem(color: Colors.pinkAccent, label: 'Exercising'),
                        ],
                      ),
                    ),
                  ]
                ],
              )
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}