import 'dart:async';
import 'package:polar/polar.dart';
import 'package:flutter/foundation.dart';

import 'package:zmartrest/services/bluetooth_permission_handler.dart';
import 'package:zmartrest/logic.dart';

class DeviceHandler {
  final polar = Polar();
  final String identifier;
  final ValueNotifier<List<String>> logs = ValueNotifier<List<String>>([]);
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  List<double> ppIntervals = [];

  final MonitorSystem monitorSystem;
  Timer? _uploadTimer; // Timer for periodic pocketbase uploads
  final ValueNotifier<bool> isExercising = ValueNotifier<bool>(false);
  StreamSubscription? _motionStateSubscription;

  DeviceHandler({
    required this.identifier,
    required this.monitorSystem,
  });

  // Method to connect the device
  Future<void> connect() async {
    try {
      await BluetoothPermissionHandler.requestBluetoothPermissions();
      log('Connecting to device with id $identifier...');
      await polar.connectToDevice(identifier);
      streamWhenReady();
      isConnected.value = true;
      _startPeriodicUpload();
    } catch (e) {
      log('Error connecting to device: $e');
      isConnected.value = false;
    }
  }
  
  //Periodic data upload
  void _startPeriodicUpload() {
    _uploadTimer?.cancel(); // Ensure any existing timer is canceled
    _uploadTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      log('Uploading buffered data to PocketBase...');
      try {
        await monitorSystem.flushBuffers();
        log('Data uploaded successfully.');
      } catch (e) {
        log('Error during data upload: $e');
      }
    });
  }

  void _stopPeriodicUpload() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
  }

  // Method to start streaming when ready
  void streamWhenReady() async {
    try {
      await polar.sdkFeatureReady.firstWhere(
        (e) => e.identifier == identifier &&
            e.feature == PolarSdkFeature.onlineStreaming,
      );

      // Get available data streams
      final availableTypes = await polar.getAvailableOnlineStreamDataTypes(identifier);
      log('Available streams: $availableTypes');

      // Start streaming data
      /*
      if (availableTypes.contains(PolarDataType.hr)) {
        polar.startHrStreaming(identifier).listen((data) {
          //log('Heart rate: ${data.samples.map((data) => data.hr)}');
          
          final hrSample = data.samples.first;
          log('Heart rate: ${hrSample.hr}');
          monitorSystem.processHeartRateData(hrSample.hr);
        });
      }
      */

      if (availableTypes.contains(PolarDataType.acc)) {
        polar.startAccStreaming(identifier).listen((data) {
          final accSample = data.samples.first;
          final timeStamp = accSample.timeStamp;

          log('Accelerometer data: x=${accSample.x}, y=${accSample.y}, z=${accSample.z}');

          // Pass data to logic
          monitorSystem.processAccelerometerData(
            timeStamp.millisecondsSinceEpoch ~/ 1000,
            data.samples.first.x.toDouble(),
            data.samples.first.y.toDouble(),
            data.samples.first.z.toDouble()
          );
        });
      }

      if (availableTypes.contains(PolarDataType.ppi)) {
        polar.startPpiStreaming(identifier).listen((data) {
          final ppiSample = data.samples.first;
          log('PPI: ${ppiSample.ppi}');

          ppIntervals += [ppiSample.ppi.toDouble()];
          if (ppIntervals.isNotEmpty) {
            final rmssd = monitorSystem.calculateRmssd(ppIntervals);
            monitorSystem.processRmssdData(rmssd, isExercising.value);
          }

          // HR data from PPI instead, therefore we don't need a seperate HR stream
          final hr = ppiSample.hr;
          log('HR: $hr');
          monitorSystem.processHeartRateData(hr);
        });
      }

      _motionStateSubscription = monitorSystem.motionStateStream.listen((state) {
        isExercising.value = state == MotionState.exercising;
        log('Motion state: ${state.toString()}');
      });
    } catch (e) {
      log('Error in streaming: $e');
    }
  }

  // Method to disconnect the device
  Future<void> disconnect() async {
    try {
      await polar.disconnectFromDevice(identifier);
      await _motionStateSubscription?.cancel();
      log('Device disconnected');
      isConnected.value = false;

      _stopPeriodicUpload();

      // Upload data on disconnect
      log('Uploading data on disconnect...');
      await monitorSystem.flushBuffers();
      log('Data uploaded successfully on disconnect.');
    } catch (e) {
      log('Error disconnecting: $e');
    }
  }

  // Log method
  void log(String log) {
    debugPrint(log);
    logs.value = [...logs.value, log]; // Notify listeners of the update
  }
}