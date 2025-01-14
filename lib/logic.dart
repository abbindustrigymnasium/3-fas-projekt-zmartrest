import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:polar/polar.dart';
import 'package:zmartrest/screens/device_handeler';

// Sensor reading models
class AccelerometerReading {
  final int timestamp;
  final double x, y, z;

  AccelerometerReading({
    required this.timestamp,
    required this.x,
    required this.y,
    required this.z,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'x': x,
    'y': y,
    'z': z,
  };
}

class HeartRateReading {
  final int timestamp;
  final double hr, hrv, rR;

  HeartRateReading({
    required this.timestamp,
    required this.hr,
    required this.hrv,
    required this.rR,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'hr': hr,
    'hrv': hrv,
    'r_r': rR,
  };
}

class HealthMonitorSystem {
  final PocketBase pb;
  final String userId;
  final Polar polar;
  final String polarIdentifier;
  
  // Stream controllers for real-time data
  final _accelerometerController = StreamController<AccelerometerReading>.broadcast();
  final _heartRateController = StreamController<HeartRateReading>.broadcast();
  
  // Buffers for batch processing
  final List<AccelerometerReading> _accelerometerBuffer = [];
  final List<HeartRateReading> _heartRateBuffer = [];
  final int _bufferSize = 10;

  // Stream subscriptions
  StreamSubscription? _hrSubscription;
  StreamSubscription? _accSubscription;
  StreamSubscription? _ecgSubscription;

  // Getters for the streams
  Stream<AccelerometerReading> get accelerometerStream => _accelerometerController.stream;
  Stream<HeartRateReading> get heartRateStream => _heartRateController.stream;

  HealthMonitorSystem({
    required this.pb,
    required this.userId,
    required this.polar,
    required this.polarIdentifier,
  });

  // Initialize connection to Polar device
  Future<void> initializePolarDevice() async {
    try {
      await polar.connectToDevice(polarIdentifier);
      await _setupStreams();
    } catch (e) {
      debugPrint('Error initializing Polar device: $e');
      rethrow;
    }
  }

  // Set up Polar data streams
  Future<void> _setupStreams() async {
    try {
      // Wait for SDK to be ready
      await polar.sdkFeatureReady.firstWhere(
        (e) =>
            e.identifier == polarIdentifier &&
            e.feature == PolarSdkFeature.onlineStreaming,
      );

      // Get available data types
      final availableTypes = await polar.getAvailableOnlineStreamDataTypes(polarIdentifier);
      debugPrint('Available Polar data types: $availableTypes');

      // Set up heart rate streaming
      if (availableTypes.contains(PolarDataType.hr)) {
        _hrSubscription = polar.startHrStreaming(polarIdentifier).listen(
          (PolarHrData data) {
            if (data.samples.isNotEmpty) {
              final hrValue = data.samples.first;
              processHeartRateData(
                double.parse(hrValue.toString()),  // Heart rate value
                0.0,  // HRV placeholder
                0.0,  // R-R placeholder
              );
              debugPrint('HR data received: $hrValue');
            }
          },
          onError: (error) {
            debugPrint('Heart rate stream error: $error');
          },
        );
      }

      // Set up accelerometer streaming
      if (availableTypes.contains(PolarDataType.acc)) {
        _accSubscription = polar.startAccStreaming(polarIdentifier).listen(
          (PolarAccData data) {
            if (data.samples.isNotEmpty) {
              final sample = data.samples.first;
              processAccelerometerData(
                sample.x.toDouble(),
                sample.y.toDouble(),
                sample.z.toDouble(),
              );
            }
            debugPrint('ACC data received');
          },
          onError: (error) {
            debugPrint('Accelerometer stream error: $error');
          },
        );
      }
    } catch (e) {
      debugPrint('Error setting up Polar streams: $e');
      rethrow;
    }
  }

  // Process accelerometer data
  void processAccelerometerData(double x, double y, double z) {
    final reading = AccelerometerReading(
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      x: x,
      y: y,
      z: z,
    );
    
    _accelerometerController.add(reading);
    _accelerometerBuffer.add(reading);
    
    if (_accelerometerBuffer.length >= _bufferSize) {
      _sendAccelerometerBuffer();
    }
  }

  // Process heart rate data
  void processHeartRateData(double hr, double hrv, double rR) {
    final reading = HeartRateReading(
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      hr: hr,
      hrv: hrv,
      rR: rR,
    );
    
    _heartRateController.add(reading);
    _heartRateBuffer.add(reading);
    
    if (_heartRateBuffer.length >= _bufferSize) {
      _sendHeartRateBuffer();
    }
  }

  // Add accelerometer data to PocketBase
  Future<void> addAccelerometerData(
    List<double> accelerometerList,
    int timestamp,
  ) async {
    try {
      final accelerometerData = {
        'timestamp': timestamp,
        'x': accelerometerList[0],
        'y': accelerometerList[1],
        'z': accelerometerList[2],
        'user': userId,
      };

      final result = await pb.collection('accelerometer_data').create(
        body: accelerometerData,
      );
      debugPrint('Accelerometer data added: ${result.toJson()}');
    } catch (e) {
      debugPrint('Error adding accelerometer data: $e');
      rethrow;
    }
  }

  // Add heart rate data to PocketBase
  Future<void> addHeartrateData(
    List<double> heartrateList,
    int timestamp,
  ) async {
    try {
      final heartrateData = {
        'timestamp': timestamp,
        'hr': heartrateList[0],
        'hrv': heartrateList[1],
        'r_r': heartrateList[2],
        'user': userId,
      };

      final result = await pb.collection('heart_rate_data').create(
        body: heartrateData,
      );
      debugPrint('Heart rate data added: ${result.toJson()}');
    } catch (e) {
      debugPrint('Error adding heart rate data: $e');
      rethrow;
    }
  }

  // Send accelerometer buffer to backend
  Future<void> _sendAccelerometerBuffer() async {
    if (_accelerometerBuffer.isEmpty) return;

    try {
      final List<Future<void>> futures = _accelerometerBuffer.map((reading) {
        return addAccelerometerData(
          [reading.x, reading.y, reading.z],
          reading.timestamp,
        );
      }).toList();

      await Future.wait(futures);
      _accelerometerBuffer.clear();
    } catch (e) {
      debugPrint('Error sending accelerometer buffer: $e');
    }
  }

  // Send heart rate buffer to backend
  Future<void> _sendHeartRateBuffer() async {
    if (_heartRateBuffer.isEmpty) return;

    try {
      final List<Future<void>> futures = _heartRateBuffer.map((reading) {
        return addHeartrateData(
          [reading.hr, reading.hrv, reading.rR],
          reading.timestamp,
        );
      }).toList();

      await Future.wait(futures);
      _heartRateBuffer.clear();
    } catch (e) {
      debugPrint('Error sending heart rate buffer: $e');
    }
  }

  // Fetch accelerometer data
  Future<List<Map<String, dynamic>>> fetchAccelerometerData(
    int timestampFrom,
    int timestampTo,
  ) async {
    try {
      final result = await pb.collection('accelerometer_data').getList(
        page: 1,
        perPage: 50,
        filter:
            'user = "$userId" && timestamp >= $timestampFrom && timestamp <= $timestampTo',
      );

      return result.items.map((record) {
        return {
          'timestamp': record.data['timestamp'],
          'x': record.data['x'],
          'y': record.data['y'],
          'z': record.data['z'],
          'user': record.data['user'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch accelerometer data: $e');
      return [];
    }
  }

  // Fetch heart rate data
  Future<List<Map<String, dynamic>>> fetchHeartrateData(
    int timestampFrom,
    int timestampTo,
  ) async {
    try {
      final result = await pb.collection('heart_rate_data').getList(
        page: 1,
        perPage: 50,
        filter:
            'user = "$userId" && timestamp >= $timestampFrom && timestamp <= $timestampTo',
      );

      return result.items.map((record) {
        return {
          'timestamp': record.data['timestamp'],
          'hr': record.data['hr'],
          'hrv': record.data['hrv'],
          'r_r': record.data['r_r'],
          'user': record.data['user'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch heart rate data: $e');
      return [];
    }
  }

  // Fetch historical data
  Future<Map<String, List<Map<String, dynamic>>>> getHistoricalData(
    int timestampFrom,
    int timestampTo,
  ) async {
    try {
      final accelerometerFuture = fetchAccelerometerData(timestampFrom, timestampTo);
      final heartRateFuture = fetchHeartrateData(timestampFrom, timestampTo);

      final results = await Future.wait([accelerometerFuture, heartRateFuture]);

      return {
        'accelerometer': results[0],
        'heartRate': results[1],
      };
    } catch (e) {
      debugPrint('Error fetching historical data: $e');
      return {
        'accelerometer': [],
        'heartRate': [],
      };
    }
  }

  // Force send any remaining buffered data
  Future<void> flushBuffers() async {
    await Future.wait([
      _sendAccelerometerBuffer(),
      _sendHeartRateBuffer(),
    ]);
  }

  // Clean up resources
  Future<void> dispose() async {
    await Future.wait([
      _hrSubscription?.cancel() ?? Future.value(),
      _accSubscription?.cancel() ?? Future.value(),
      _ecgSubscription?.cancel() ?? Future.value(),
    ]);
    
    await flushBuffers();
    _accelerometerController.close();
    _heartRateController.close();
  }
}


// Example usage
void main() async {
  final pb = PocketBase('https://your-pocketbase-url.com');
  
  final healthMonitor = HealthMonitorSystem(
    pb: pb,
    userId: 'current_user_id',
    polar: Polar(),
    polarIdentifier: 'C36A972B',
  );

  try {
    await healthMonitor.initializePolarDevice();
    
    // Listen to heart rate updates
    healthMonitor.heartRateStream.listen((reading) {
      debugPrint('Heart Rate: ${reading.hr}');
    });

    // Listen to accelerometer updates
    healthMonitor.accelerometerStream.listen((reading) {
      debugPrint('Acceleration: (${reading.x}, ${reading.y}, ${reading.z})');
    });

    // Example of fetching historical data
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final oneHourAgo = now - (60 * 60);
    
    final historicalData = await healthMonitor.getHistoricalData(
      oneHourAgo,
      now,
    );
    
    debugPrint('Historical data: $historicalData');
  } catch (e) {
    debugPrint('Error in health monitoring: $e');
  }
}