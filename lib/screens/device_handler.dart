import 'package:polar/polar.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:zmartrest/bluetooth_permission_handler.dart';

class DeviceHandler {
  final polar = Polar();
  final String identifier;
  //final List<String> logs = []; // List of logs
  final ValueNotifier<List<String>> logs = ValueNotifier<List<String>>([]);
  PolarExerciseEntry? exerciseEntry;
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  DeviceHandler({required this.identifier});

  // Method to connect the device
  Future<void> connect() async {
    try {
      await BluetoothPermissionHandler.requestBluetoothPermissions();
      log('Connecting to device with id $identifier...');
      await polar.connectToDevice(identifier);
      streamWhenReady();
      isConnected.value = true;
    } catch (e) {
      log('Error connecting to device: $e');
      isConnected.value = false;
    }
  }

  // Method to start streaming when ready
  void streamWhenReady() async {
    try {
      await polar.sdkFeatureReady.firstWhere(
        (e) => e.identifier == identifier &&
            e.feature == PolarSdkFeature.onlineStreaming,
      );

      final availableTypes = await polar.getAvailableOnlineStreamDataTypes(identifier);
      debugPrint('Available types: $availableTypes');

      // Start streaming data based on available types
      if (availableTypes.contains(PolarDataType.hr)) {
        polar.startHrStreaming(identifier).listen((e) {
          log('Heart rate: ${e.samples.map((e) => e.hr)}');
        });
      }
      if (availableTypes.contains(PolarDataType.ecg)) {
        polar.startEcgStreaming(identifier).listen((e) {
          log('ECG data received: ${e.samples}');
        });
      }
      if (availableTypes.contains(PolarDataType.acc)) {
        polar.startAccStreaming(identifier).listen((e) {
          log('Accelerometer data: ${e.samples}');
        });
      }
    } catch (e) {
      log('Error in streaming: $e');
    }
  }

  // Method to disconnect the device
  Future<void> disconnect() async {
    try {
      await polar.disconnectFromDevice(identifier);
      log('Device disconnected');
      isConnected.value = false;
    } catch (e) {
      log('Error disconnecting: $e');
    }
  }

  // Log method
  void log(String log) {
    debugPrint(log);
    //logs.add(log);
    logs.value = [...logs.value, log]; // Notify listeners of the update
  }

  Future<void> handleRecordingAction(RecordingAction action) async {
    switch (action) {
      case RecordingAction.start:
        log('Starting recording');
        await polar.startRecording(
          identifier,
          exerciseId: const Uuid().v4(),
          interval: RecordingInterval.interval_1s,
          sampleType: SampleType.rr,
        );
        log('Started recording');
        break;
      case RecordingAction.stop:
        log('Stopping recording');
        await polar.stopRecording(identifier);
        log('Stopped recording');
        break;
      case RecordingAction.status:
        log('Getting recording status');
        final status = await polar.requestRecordingStatus(identifier);
        log('Recording status: $status');
        break;
      case RecordingAction.list:
        log('Listing recordings');
        final entries = await polar.listExercises(identifier);
        log('Recordings: $entries');
        // H10 can only store one recording at a time
        exerciseEntry = entries.first;
        break;
      case RecordingAction.fetch:
        log('Fetching recording');
        if (exerciseEntry == null) {
          log('Exercises not yet listed');
          await handleRecordingAction(RecordingAction.list);
        }
        final entry = await polar.fetchExercise(identifier, exerciseEntry!);
        log('Fetched recording: $entry');
        break;
      case RecordingAction.remove:
        log('Removing recording');
        if (exerciseEntry == null) {
          log('No exercise to remove. Try calling list first.');
          return;
        }
        await polar.removeExercise(identifier, exerciseEntry!);
        log('Removed recording');
        break;
    }
  }
}

enum RecordingAction {
  start,
  stop,
  status,
  list,
  fetch,
  remove,
}