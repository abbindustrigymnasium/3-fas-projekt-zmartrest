import 'package:flutter/foundation.dart';
import 'package:polar/polar.dart';

const identifier = 'C36A972B';
final polar = Polar();

void test() {
  polar.connectToDevice(identifier);
  streamWhenReady();
}

void streamWhenReady() async {
  await polar.sdkFeatureReady.firstWhere(
    (e) =>
        e.identifier == identifier &&
        e.feature == PolarSdkFeature.onlineStreaming,
  );
  final availabletypes =
      await polar.getAvailableOnlineStreamDataTypes(identifier);

  debugPrint('available types: $availabletypes');

  if (availabletypes.contains(PolarDataType.hr)) {
    polar
        .startHrStreaming(identifier)
        .listen((e) => debugPrint('HR data received'));
  }
  if (availabletypes.contains(PolarDataType.ecg)) {
    polar
        .startEcgStreaming(identifier)
        .listen((e) => debugPrint('ECG data received'));
  }
  if (availabletypes.contains(PolarDataType.acc)) {
    polar
        .startAccStreaming(identifier)
        .listen((e) => debugPrint('ACC data received'));
  }
}

/*

import 'package:polar/polar.dart';

class PolarService {
  final Polar _polar = Polar();

  // Stream for discovered devices
  Stream<PolarDeviceInfo> get deviceDiscoveryStream => _polar.searchForDevice();

  // Connect to a Polar device
  Future<void> connectToDevice(String deviceId) async {
    try {
      await _polar.connectToDevice(deviceId);
    } catch (e) {
      throw Exception('Failed to connect to device: $e');
    }
  }

  // Start heart rate stream
  Future<void> setupHeartRateStream(String deviceId) async {
    try {
      _polar.startHrStreaming(deviceId).listen(
        (PolarHrData data) {
          print('Heart rate data received: $data');
        },
        onError: (error) {
          print('Heart rate stream error: $error');
        },
      );
    } catch (e) {
      throw Exception('Failed to set up heart rate stream: $e');
    }
  }
}

*/