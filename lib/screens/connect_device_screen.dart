import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/device_handler.dart';
import 'package:zmartrest/pocketbase.dart';
import 'package:zmartrest/logic.dart';
 
class DeviceScreen extends StatefulWidget {
  final HealthMonitorSystem healthMonitorSystem;
  final DeviceHandler deviceHandler;

  const DeviceScreen({
    super.key,
    required this.deviceHandler,
    required this.healthMonitorSystem,
  });

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> with WidgetsBindingObserver {
  //static const identifier = 'C36A972B';
  // static const identifier = 'E985E828';

  String currentTab = "connect";

  /*
  DeviceHandler? deviceHandler;
  HealthMonitorSystem? healthMonitorSystem;
  bool isLoading = true;
  */

  Future<String?> getUserId() async {
    final userInfo = await getUserInfo();
    final userId = userInfo?['id'];

    return userId;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //_initializeDeviceHandler();
  }

  /*
  Future<void> _initializeDeviceHandler() async {
    try {
      final userInfo = await getUserInfo(); // Fetch user info
      final userId = userInfo?['id'];

      if (userId == null) {
        throw Exception("User ID is null");
      }

      healthMonitorSystem = HealthMonitorSystem(userId: userId); // Initialize HealthMonitorSystem
      deviceHandler = DeviceHandler(
        identifier: identifier,
        healthMonitorSystem: healthMonitorSystem!,
      );

      _addDeviceHandlerListeners();
    } catch (e) {
      debugPrint("Error initializing DeviceHandler: $e");
    } finally {
      setState(() {
        isLoading = false; // Initialization is complete
      });
    }
  }

  void _addDeviceHandlerListeners() {
    if (deviceHandler == null) return;

    deviceHandler!.polar.batteryLevel.listen(
      (e) => setState(() => deviceHandler!.log('Battery: ${e.level}')),
      onError: (error) => setState(() => deviceHandler!.log('Battery error: $error')),
    );

    deviceHandler!.polar.deviceConnecting.listen(
      (_) => setState(() => deviceHandler!.log('Device connecting')),
      onError: (error) => setState(() => deviceHandler!.log('Connecting error: $error')),
    );

    deviceHandler!.polar.deviceConnected.listen(
      (_) => setState(() => deviceHandler!.log('Device connected')),
      onError: (error) => setState(() => deviceHandler!.log('Connection error: $error')),
    );

    deviceHandler!.polar.deviceDisconnected.listen(
      (_) => setState(() => deviceHandler!.log('Device disconnected')),
      onError: (error) => setState(() => deviceHandler!.log('Disconnection error: $error')),
    );
  }
  */

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    //deviceHandler?.disconnect();
    super.dispose();
  }

  /*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _handleAppExit();
    }
  }
  */
  
  /*
  Future<void> _handleAppExit() async {
    if (deviceHandler?.isConnected.value == true) {
      await deviceHandler?.disconnect();
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    /*
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (deviceHandler == null || healthMonitorSystem == null) {
      return Scaffold(
        body: Center(
          child: Text("Failed to initialize DeviceHandler or HealthMonitorSystem."),
        ),
      );
    }
    */

    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShadTabs(
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
                        valueListenable: widget.deviceHandler.isConnected,
                        builder: (context, isConnected, _) {
                          return ShadButton(
                            icon: ShadImage(isConnected ? LucideIcons.square : LucideIcons.cable),
                            onPressed: () async {
                              if (isConnected) {
                                await widget.deviceHandler.disconnect();
                              } else {
                                await widget.deviceHandler.connect();
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
                        valueListenable: widget.deviceHandler.logs,
                        builder: (context, logs, _) {
                          return Column(
                            children: logs.reversed.take(10).map(Text.new).toList(),
                          );
                        },
                      )
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
}