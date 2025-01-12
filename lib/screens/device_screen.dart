import 'package:polar/polar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const identifier = 'C36A972B';
final polar = Polar();

Future<void> connect(String identifier) async {
  try {
    await requestPermissions();

    polar.deviceConnected.listen((device) {
      debugPrint('Device connected: ${device.deviceId}');
      if (device.deviceId == identifier) {
        streamWhenReady();
      }
    });

    polar.deviceDisconnected.listen((device) {
      debugPrint('Device disconnected: ${device.info.deviceId}');
    });

    polar.connectToDevice(identifier);
  } catch (e) {
    debugPrint('Error connecting: $e');
  }
}

void streamWhenReady() async {
  try {
    await polar.sdkFeatureReady.firstWhere(
      (e) =>
        e.identifier == identifier &&
        e.feature == PolarSdkFeature.onlineStreaming,
    );

    final availabletypes =
      await polar.getAvailableOnlineStreamDataTypes(identifier);

    debugPrint('Available types: $availabletypes');

    if (availabletypes.contains(PolarDataType.hr)) {
      polar
        .startHrStreaming(identifier)
        .listen((e) => debugPrint('HR data received: $e'));
    }
  } catch (e) {
    debugPrint('Error during streaming setup: $e');
  }
}

Future<void> requestPermissions() async {
  await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Connect your Polar device", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              ),
              ShadButton(
                child: const Text('Connect'),
                icon: const ShadImage(LucideIcons.cable),
                onPressed: () {
                  connect(identifier);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 60),
                child: Container(
                  width: 320,
                  child: ShadAlert(
                    iconSrc: LucideIcons.bluetooth,
                    description: Text("Make sure bluetooth is enabled on your device."),
                  ),
                ) 
              )
            ],
          ),
        )
        
      ),
    );
  }
}
