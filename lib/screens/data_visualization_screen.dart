import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

class _DataVisualizationState extends State<DataVisualizationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.only(bottom: 40, top: 60),
              child: ShadDateRangePickerFormField(
                width: MediaQuery.of(context).size.width - 60,
                label: const Text('Select date range'),
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
            const SizedBox(height: 20),
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
                  if (widget.heartRateData.isNotEmpty) ...[
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
                          SplineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: widget.heartRateData,
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
                  if (widget.accelerometerData.isNotEmpty) ...[
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
                  if (widget.rmssdData.isNotEmpty) ...[
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
                        series: <CartesianSeries<dynamic, dynamic>>[
                          SplineSeries(
                            dataSource: widget.rmssdData, // TODO: CHANGE COLOR IF THE MOTIONSTATE IS NOT NORMAL
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
                          SplineSeries(
                              dataSource: widget.rmssdBaselineData,
                              xValueMapper: ( data, _) =>
                                  DateTime.fromMillisecondsSinceEpoch(
                                    (data['timestamp'] * 1000).toInt()),
                              yValueMapper: (data, _) =>
                                  (data['rmssd_baseline'] as num).toDouble(),
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