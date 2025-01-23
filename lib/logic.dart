import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:zmartrest/pocketbase.dart';

// Motion state enum
enum MotionState {
  normal,
  exercising
}

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
  final int hr;

  HeartRateReading({
    required this.timestamp,
    required this.hr,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'hr': hr,
  };
}

class RMSSDData {
  final int timestamp;
  final double rmssd;
  final bool isExercising;

  RMSSDData({
    required this.timestamp,
    required this.rmssd,
    required this.isExercising,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'rmssd': rmssd,
    'is_exercising': isExercising,
  };
}

class RMSSDBaselineData {
  final int timestamp;
  final double? rmssdBaseline;

  RMSSDBaselineData({
    required this.timestamp,
    required this.rmssdBaseline,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'rmssd_baseline': rmssdBaseline,
  };
}

class HealthMonitorSystem {
  final String userId;
  
  // Motion state monitoring
  final _motionStateController = StreamController<MotionState>.broadcast();
  final List<AccelerometerReading> _activityBuffer = [];
  final int _activityWindowSize = 50; // About 1 second of data at 52Hz
  final double _exerciseThreshold = 1000.0; // mG threshold for exercise detection
  
  // Stream controllers for sensor data
  final _accelerometerController = StreamController<AccelerometerReading>.broadcast();
  final _heartRateController = StreamController<HeartRateReading>.broadcast();
  final _rmssdController = StreamController<RMSSDData>.broadcast();
  final _rmssdBaselineController = StreamController<RMSSDBaselineData>.broadcast();
  
  // Data buffers
  final List<AccelerometerReading> _accelerometerBuffer = [];
  final List<HeartRateReading> _heartRateBuffer = [];
  final List<RMSSDData> _rmssdBuffer = [];
  final List<RMSSDBaselineData> _rmssdBaselineBuffer = [];
  //final int _bufferSize = 10; // Max buffer size

  double? _rmssdBaseline;
  //final _baselineWindow = <double>[];

  // Getters for streams
  Stream<MotionState> get motionStateStream => _motionStateController.stream;
  Stream<AccelerometerReading> get accelerometerStream => _accelerometerController.stream;
  Stream<HeartRateReading> get heartRateStream => _heartRateController.stream;
  Stream<RMSSDData> get rmssdStream => _rmssdController.stream;
  Stream<RMSSDBaselineData> get baselineStream => _rmssdBaselineController.stream;

  HealthMonitorSystem({required this.userId});

  void processAccelerometerData(int timestamp, double x, double y, double z) {
    final reading = AccelerometerReading(
      timestamp: timestamp,
      x: x,
      y: y,
      z: z,
    );
    
    _accelerometerController.add(reading);
    _accelerometerBuffer.add(reading);
    _activityBuffer.add(reading);
    
    // Detect motion state when we have enough data
    if (_activityBuffer.length >= _activityWindowSize) {
      _detectMotionState();
      _activityBuffer.removeAt(0);
    }
    
    /*
    if (_accelerometerBuffer.length >= _bufferSize) {
      _sendAccelerometerBuffer();
    }
    */
  }

  void processHeartRateData(int hr) {
    final reading = HeartRateReading(
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      hr: hr,
    );
    
    _heartRateController.add(reading);
    _heartRateBuffer.add(reading);
    
    /*
    if (_heartRateBuffer.length >= _bufferSize) {
      _sendHeartRateBuffer();
    }
    */
  }

  // Reference: https://www.kubios.com/blog/hrv-analysis-methods/
  double calculateRmssd(List<double> rrIntervals) {
    if (rrIntervals.length < 2) {
      throw ArgumentError('At least two RR intervals are required to calculate RMSSD.');
    }

    double sumOfSquares = 0.0;

    for (int i = 0; i < rrIntervals.length - 1; i++) {
      final difference = rrIntervals[i + 1] - rrIntervals[i];
      sumOfSquares += pow(difference, 2);
    }

    final rmssd = sqrt(sumOfSquares / (rrIntervals.length - 1));
    return rmssd;
  }

  void processRmssdData(double rmssd, bool isExercising) {
    debugPrint('Processing RMSSD data: $rmssd, isExercising: $isExercising');
    final reading = RMSSDData(
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      rmssd: rmssd,
      isExercising: isExercising,
    );

    _rmssdController.add(reading);
    _rmssdBuffer.add(reading);

    /*
    if (_rmssdBuffer.length >= _bufferSize) {
      _sendRmssdBuffer();
    }
    */

    // Update baseline only during normal state
    /*
    if (_motionStateController.hasListener && 
        _motionStateController.stream.last == MotionState.normal) {
      _updateBaselineRmssd(rmssd);
    }
    */
    
    
    _updateBaselineRmssd(rmssd);
    
    /*
    if (_motionStateController.hasListener) {
      _updateBaselineRmssd(rmssd);
    }
    */
  }

  void _updateBaselineRmssd(double rmssd) {
    if (_rmssdBaseline == null) {
      _rmssdBaseline = rmssd;
    } else {
      // Smoothing factor of 0.1 for gradual updates
      _rmssdBaseline = (_rmssdBaseline! * 0.9) + (rmssd * 0.1);
    }

    final calculation = RMSSDBaselineData(
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      rmssdBaseline: _rmssdBaseline,
    );

    debugPrint("RMSSD baseline: $calculation");

    _rmssdBaselineController.add(calculation);
    _rmssdBaselineBuffer.add(calculation);

    /*
    if (_rmssdBaselineBuffer.length >= _bufferSize) {
      _sendRmssdBaselineBuffer();
    }
    */
  }

  void _detectMotionState() {
    if (_activityBuffer.isEmpty) return;

    // Calculate average magnitude of acceleration over the window
    double totalMagnitude = 0;
    
    for (var reading in _activityBuffer) {
      // Calculate magnitude of acceleration in mG
      double magnitude = sqrt(pow(reading.x, 2) + pow(reading.y, 2) + pow(reading.z, 2));
      totalMagnitude += magnitude;
    }
    
    double avgMagnitude = totalMagnitude / _activityBuffer.length;
    
    // Determine motion state based on average magnitude
    // If average magnitude is above threshold, consider it exercise
    MotionState currentState = avgMagnitude > _exerciseThreshold 
        ? MotionState.exercising 
        : MotionState.normal;
    
    _motionStateController.add(currentState);
  }

  Future<void> _sendAccelerometerBuffer() async {
    if (_accelerometerBuffer.isEmpty) return;

    try {
      final List<Future<void>> futures = _accelerometerBuffer.map((reading) {
        return addAccelerometerData(
          pb,
          userId,
          reading.timestamp,
          [reading.x, reading.y, reading.z],
        );
      }).toList();

      await Future.wait(futures);
      _accelerometerBuffer.clear();
    } catch (e) {
      debugPrint('Error sending accelerometer buffer: $e');
    }
  }

  Future<void> _sendHeartRateBuffer() async {
    if (_heartRateBuffer.isEmpty) return;

    try {
      final List<Future<void>> futures = _heartRateBuffer.map((reading) {
        return addHeartrateData(
          pb,
          userId,
          reading.timestamp,
          [reading.hr],
        );
      }).toList();

      await Future.wait(futures);
      _heartRateBuffer.clear();
    } catch (e) {
      debugPrint('Error sending heart rate buffer: $e');
    }
  }

  Future<void> _sendRmssdBuffer() async {
    if (_rmssdBuffer.isEmpty) return;

    try {
      final List<Future<void>> futures = _rmssdBuffer.map((reading) {
        return addRmssdData(pb, userId, reading.timestamp, reading.rmssd, reading.isExercising);
      }).toList();

      await Future.wait(futures);
      _rmssdBuffer.clear();
    } catch (e) {
      debugPrint('Error sending rmssd buffer: $e');
    }
  }

  Future<void> _sendRmssdBaselineBuffer() async {
    if (_rmssdBaselineBuffer.isEmpty) return;

    try {
      final List<Future<void>> futures = _rmssdBaselineBuffer.map((reading) {
        debugPrint('Sending baseline reading: ${reading.rmssdBaseline}');
        return addRmssdBaselineData(pb, userId, reading.timestamp, reading.rmssdBaseline);
      }).toList();

      await Future.wait(futures);
      _rmssdBuffer.clear();
    } catch (e) {
      debugPrint('Error sending rmssd buffer: $e');
    }
  }

  Future<void> flushBuffers() async {
    await Future.wait([
      _sendAccelerometerBuffer(),
      _sendHeartRateBuffer(),
      _sendRmssdBuffer(),
      _sendRmssdBaselineBuffer()
    ]);
  }

  Future<void> dispose() async {
    await flushBuffers();
    await _motionStateController.close();
    await _accelerometerController.close();
    await _heartRateController.close();
    await _rmssdController.close();
    await _rmssdBaselineController.close();
  }
}