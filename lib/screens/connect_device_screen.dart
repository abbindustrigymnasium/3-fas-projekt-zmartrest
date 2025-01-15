import 'package:flutter/material.dart';
import 'package:polar/polar.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'device_handler.dart';
 
class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  //static const identifier = 'C36A972B';
  static const identifier = 'E985E828';

  //final polar = Polar();
  final DeviceHandler deviceHandler = DeviceHandler(identifier: identifier);
  //final logs = [''];

  String currentTab = "connect";

  PolarExerciseEntry? exerciseEntry;

  @override
  void initState() {
    super.initState();
  
    // Scan for devices
    /*
    polar.searchForDevice().listen(
      (e) {
        log('Found device in scan: ${e.deviceId}');
        // Log additional device info if available
        log('Device name: ${e.name}');
        log('Device address: ${e.address}');
      },
      onError: (error) => log('Scan error: $error')
    );
    */

    // Add error handlers to all listeners
    deviceHandler.polar.batteryLevel.listen(
      (e) => setState(() => deviceHandler.log('Battery: ${e.level}')),
      onError: (error) => setState(() => deviceHandler.log('Battery error: $error')),
    );
    
    deviceHandler.polar.deviceConnecting.listen(
      (_) => setState(() => deviceHandler.log('Device connecting')),
      onError: (error) => setState(() => deviceHandler.log('Connecting error: $error')),
    );

    deviceHandler.polar.deviceConnected.listen(
      (_) => setState(() => deviceHandler.log('Device connected')),
      onError: (error) => setState(() => deviceHandler.log('Connection error: $error')),
    );

    deviceHandler.polar.deviceDisconnected.listen(
      (_) => setState(() => deviceHandler.log('Device disconnected')),
      onError: (error) => setState(() => deviceHandler.log('Disconnection error: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Connect your Polar device", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              ),
              */
              ShadTabs(
                //value: "connect",
                value: currentTab,
                onChanged: (value) {
                  setState(() {
                    currentTab = value; // Update the tab when user switches
                  });
                },
                tabBarConstraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40),
                contentConstraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40),
                tabs: [
                  ShadTab(
                    value: "connect",
                    content: ShadCard(
                      title: const Text('Connect'),
                      description: const Padding(padding: EdgeInsets.only(bottom: 20), child: Text("Connect your device.")),
                      width: MediaQuery.of(context).size.width - 40,
                      footer: ValueListenableBuilder<bool>(
                        valueListenable: deviceHandler.isConnected,
                        builder: (context, isConnected, _) {
                          return ShadButton(
                            icon: ShadImage(isConnected ? LucideIcons.square : LucideIcons.cable),
                            onPressed: () async {
                              if (isConnected) {
                                await deviceHandler.disconnect();
                              } else {
                                await deviceHandler.connect();
                              }
                              setState(() {});
                            },
                            child: Text(isConnected ? 'Stop' : 'Connect'),
                          );
                        },
                      ),
                    ),
                    child: const Text('Connect'),
                  ),
                  ShadTab(
                    value: "logs",
                    content: ShadCard(
                      title: const Text('Logs'),
                      description: const Padding(padding: EdgeInsets.only(bottom: 20), child: Text("Logs from device:")),
                      width: MediaQuery.of(context).size.width - 40,
                      child: ValueListenableBuilder<List<String>>(
                        valueListenable: deviceHandler.logs,
                        builder: (context, logs, _) {
                          return Column(
                            children: logs.reversed.take(10).map(Text.new).toList(),
                          );
                        },
                      )
                      /*
                      child: Column(
                        children: deviceHandler.logs.reversed.take(10).map(Text.new).toList(),
                      )
                      */
                    ),
                    child: Text("Logs"),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 60),
                child: SizedBox(
                  width: 320,
                  child: ShadAlert(
                    iconSrc: LucideIcons.bell,
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

  /*
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Polar example app'),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => RecordingAction.values
                  .map((e) => PopupMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onSelected: handleRecordingAction,
              child: const IconButton(
                icon: Icon(Icons.fiber_manual_record),
                disabledColor: Colors.white,
                onPressed: null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                log('Disconnecting from device: $identifier');
                polar.disconnectFromDevice(identifier);
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
                onPressed: () async {
                  try {
                    await BluetoothPermissionHandler
                        .requestBluetoothPermissions();
                    log('Connecting to device: $identifier');
                    await polar.connectToDevice(identifier);
                    streamWhenReady();
                  } catch (e) {
                    log('Error connecting to device: $e');
                  }
                },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          shrinkWrap: true,
          children: logs.reversed.map(Text.new).toList(),
        ),
      ),
    );
  }
  */

  /*
 
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
          .listen((e) => log('Heart rate: ${e.samples.map((e) => e.hr)}'));
    }
    if (availabletypes.contains(PolarDataType.ecg)) {
      polar
          .startEcgStreaming(identifier)
          .listen((e) => log('ECG data received'));
    }
    if (availabletypes.contains(PolarDataType.acc)) {
      polar
          .startAccStreaming(identifier)
          .listen((e) => log('ACC data received'));
    }
  }

  void log(String log) {
    debugPrint(log);
    setState(() {
      logs.add(log);
    });
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
  */
}


/*
enum RecordingAction {
  start,
  stop,
  status,
  list,
  fetch,
  remove,
}
*/