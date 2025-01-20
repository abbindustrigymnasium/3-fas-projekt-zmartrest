import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:zmartrest/logic.dart';

class DeviceHandler {
  final String identifier;
  final ValueNotifier<List<String>> logs = ValueNotifier<List<String>>([]);
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  final HealthMonitorSystem healthMonitorSystem;
  Timer? _simulationTimer;
  final Random _random = Random();

  DeviceHandler({
    required this.identifier,
    required this.healthMonitorSystem,
  });

  Future<void> connect() async {
    log('Simulating connection to device with id $identifier...');
    await Future.delayed(const Duration(seconds: 1)); // Simulate connection delay
    isConnected.value = true;
    log('Device connected (simulated).');

    startSimulatingData();
  }

  void startSimulatingData() {
    log('Starting simulated data streaming...');
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Simulate heart rate data
      final simulatedHr = _random.nextInt(40) + 60; // Random HR between 60-100
      log('Simulated Heart Rate: $simulatedHr');
      healthMonitorSystem.processHeartRateData(simulatedHr);

      // Simulate accelerometer data
      final simulatedAcc = AccelerometerReading(
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        x: _random.nextDouble() * 2 - 1, // Random value between -1 and 1
        y: _random.nextDouble() * 2 - 1,
        z: _random.nextDouble() * 2 - 1,
      );
      log('Simulated Accelerometer Data: x=${simulatedAcc.x}, y=${simulatedAcc.y}, z=${simulatedAcc.z}');
      healthMonitorSystem.processAccelerometerData(
        simulatedAcc.timestamp,
        simulatedAcc.x,
        simulatedAcc.y,
        simulatedAcc.z,
      );

      // Simulate PPI data
      final simulatedPpi = _random.nextInt(300) + 400; // Random PPI between 400-700 ms
      log('Simulated PPI: $simulatedPpi');
      final isExercising = false;
      healthMonitorSystem.processRmssdData(simulatedPpi.toDouble(), isExercising);
    });
  }

  Future<void> disconnect() async {
    log('Disconnecting simulated device...');
    _simulationTimer?.cancel();
    _simulationTimer = null;
    isConnected.value = false;
    log('Device disconnected (simulated).');
  }

  void log(String message) {
    debugPrint(message);
    logs.value = [...logs.value, message];
  }
}

// Example usage
/*
void main() {
  final healthMonitorSystem = HealthMonitorSystem(userId: 'test_user');
  final simulatedDevice = DeviceHandler(
    identifier: 'simulated_device_001',
    healthMonitorSystem: healthMonitorSystem,
  );

  simulatedDevice.connect();

  // To disconnect later
  // simulatedDevice.disconnect();
}

*/