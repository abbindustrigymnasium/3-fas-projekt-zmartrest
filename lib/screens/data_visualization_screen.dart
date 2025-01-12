import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/pocketbase.dart';

class DataVisualizationScreen extends StatefulWidget {
  final Map<String, dynamic> selectedUser;

  const DataVisualizationScreen({
    Key? key,
    required this.selectedUser,
  }) : super(key: key);

  @override
  _DataVisualizationState createState() => _DataVisualizationState();
}

class _DataVisualizationState extends State<DataVisualizationScreen> {
  List<Map<String, dynamic>> accelerometerData = [];
  List<Map<String, dynamic>> heartRateData = [];
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _fetchData(ShadDateTimeRange range) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Convert DateTime to Unix timestamp
      final startTimestamp = range.start!.millisecondsSinceEpoch ~/ 1000;
      final endTimestamp = range.end!.millisecondsSinceEpoch ~/ 1000;

      // Fetch all data
      final allData = await fetchAllDataFromTo(
        pb,
        widget.selectedUser['id'],
        startTimestamp,
        endTimestamp,
      );

      setState(() {
        accelerometerData = allData['accelerometer'] ?? [];
        heartRateData = allData['heartrate'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 60),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, top: 40),
                  child: ShadDateRangePickerFormField(
                    width: 340,
                    label: const Text('Select date range'),
                    validator: (v) {
                      if (v == null) return 'A range of dates is required.';
                      if (v.start == null) return 'The start date is required.';
                      if (v.end == null) return 'The end date is required.';
                      return null;
                    },
                    onChanged: (ShadDateTimeRange? range) {
                      if (range?.start != null && range?.end != null) {
                        _fetchData(range!);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else if (accelerometerData.isNotEmpty || heartRateData.isNotEmpty)
                  Column(
                    children: [
                      // Heart Rate Chart
                      if (heartRateData.isNotEmpty) ...[
                        const Text(
                          'Heart Rate Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: SfCartesianChart(
                            tooltipBehavior: TooltipBehavior(enable: true),
                            primaryXAxis: DateTimeCategoryAxis(
                              intervalType: DateTimeIntervalType.hours,
                              dateFormat: DateFormat('HH:mm'),
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: heartRateData.isEmpty
                                  ? 0
                                  : heartRateData
                                          .map((e) => (e['hr'] as num).toDouble())
                                          .reduce((a, b) => a < b ? a : b) -
                                      5,
                              maximum: heartRateData.isEmpty
                                  ? 100
                                  : heartRateData
                                          .map((e) => (e['hr'] as num).toDouble())
                                          .reduce((a, b) => a > b ? a : b) +
                                      5,
                            ),
                            series: <CartesianSeries<dynamic, dynamic>>[
                              SplineSeries<Map<String, dynamic>, DateTime>(
                                dataSource: heartRateData,
                                xValueMapper: (Map<String, dynamic> data, _) =>
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (data['timestamp'] * 1000).toInt()),
                                yValueMapper: (Map<String, dynamic> data, _) =>
                                    (data['hr'] as num).toDouble(),
                                color: Colors.redAccent,
                                enableTooltip: true,
                                markerSettings: MarkerSettings(
                                  isVisible: true, // Enable markers
                                  shape: DataMarkerType.circle, // Shape of the markers
                                  color: Colors.white, // Color of the markers
                                  width: 6,
                                  height: 6,
                                  borderWidth: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Accelerometer Chart
                      if (accelerometerData.isNotEmpty) ...[
                        const Text(
                          'Accelerometer Data',
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
                            primaryXAxis: DateTimeCategoryAxis(
                              intervalType: DateTimeIntervalType.hours,
                              dateFormat: DateFormat('HH:mm'),
                            ),
                            primaryYAxis: NumericAxis(),
                            series: <CartesianSeries<dynamic, dynamic>>[
                              // X axis
                              SplineSeries<Map<String, dynamic>, DateTime>(
                                dataSource: accelerometerData,
                                xValueMapper: (Map<String, dynamic> data, _) =>
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (data['timestamp'] * 1000).toInt()),
                                yValueMapper: (Map<String, dynamic> data, _) =>
                                    (data['x'] as num).toDouble(),
                                color: Colors.blue,
                                enableTooltip: true,
                                markerSettings: MarkerSettings(
                                  isVisible: true, // Enable markers
                                  shape: DataMarkerType.circle, // Shape of the markers
                                  color: Colors.white, // Color of the markers
                                  width: 6,
                                  height: 6,
                                  borderWidth: 0,
                                ),
                              ),
                              // Y axis
                              SplineSeries<Map<String, dynamic>, DateTime>(
                                dataSource: accelerometerData,
                                xValueMapper: (Map<String, dynamic> data, _) =>
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (data['timestamp'] * 1000).toInt()),
                                yValueMapper: (Map<String, dynamic> data, _) =>
                                    (data['y'] as num).toDouble(),
                                color: Colors.green,
                                enableTooltip: true,
                                markerSettings: MarkerSettings(
                                  isVisible: true, // Enable markers
                                  shape: DataMarkerType.circle, // Shape of the markers
                                  color: Colors.white, // Color of the markers
                                  width: 6,
                                  height: 6,
                                  borderWidth: 0,
                                ),
                              ),
                              // Z axis
                              SplineSeries<Map<String, dynamic>, DateTime>(
                                dataSource: accelerometerData,
                                xValueMapper: (Map<String, dynamic> data, _) =>
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (data['timestamp'] * 1000).toInt()),
                                yValueMapper: (Map<String, dynamic> data, _) =>
                                    (data['z'] as num).toDouble(),
                                color: Colors.orange,
                                enableTooltip: true,
                                markerSettings: MarkerSettings(
                                  isVisible: true, // Enable markers
                                  shape: DataMarkerType.circle, // Shape of the markers
                                  color: Colors.white, // Color of the markers
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
                    ],
                  )
                else
                  const Text('Select a date range to view data'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for the legend
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
