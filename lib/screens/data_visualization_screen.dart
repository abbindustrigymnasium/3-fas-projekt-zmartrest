import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
                    label: const Text('Select date range'),
                    /*
                    description: const Text(
                      'Select the range of dates you want to analyze data between.',
                    ),
                    */
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
                          child: LineChart(
                            LineChartData(
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final date = DateTime.fromMillisecondsSinceEpoch(
                                          (value * 1000).toInt());
                                      return Text(
                                        DateFormat('HH:mm').format(date),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: heartRateData
                                      .map((data) => FlSpot(
                                            data['timestamp'].toDouble(),
                                            data['hr'].toDouble(),
                                          ))
                                      .toList(),
                                  color: Colors.red,
                                  dotData: const FlDotData(show: false),
                                ),
                              ],
                            ),
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
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final date = DateTime.fromMillisecondsSinceEpoch(
                                          (value * 1000).toInt());
                                      return Text(
                                        DateFormat('HH:mm').format(date),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineBarsData: [
                                // X axis
                                LineChartBarData(
                                  spots: accelerometerData
                                      .map((data) => FlSpot(
                                            data['timestamp'].toDouble(),
                                            data['x'].toDouble(),
                                          ))
                                      .toList(),
                                  color: Colors.blue,
                                  dotData: const FlDotData(show: false),
                                ),
                                // Y axis
                                LineChartBarData(
                                  spots: accelerometerData
                                      .map((data) => FlSpot(
                                            data['timestamp'].toDouble(),
                                            data['y'].toDouble(),
                                          ))
                                      .toList(),
                                  color: Colors.green,
                                  dotData: const FlDotData(show: false),
                                ),
                                // Z axis
                                LineChartBarData(
                                  spots: accelerometerData
                                      .map((data) => FlSpot(
                                            data['timestamp'].toDouble(),
                                            data['z'].toDouble(),
                                          ))
                                      .toList(),
                                  color: Colors.orange,
                                  dotData: const FlDotData(show: false),
                                ),
                              ],
                            ),
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
        )
      )
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
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}