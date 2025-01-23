import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/device_handler.dart';
//import 'package:zmartrest/simulated_device_handler.dart';
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
  String currentTab = "connect";

  Future<String?> getUserId() async {
    final userInfo = await getUserInfo();
    final userId = userInfo?['id'];

    return userId;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 60,
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Measure", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
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
                              //debugPrint('isConnected: $isConnected');
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
                          if (logs.isEmpty) {
                            return const Text('No logs available, make sure to connect first.');
                          } else {
                            return Column(
                              children: logs.reversed.take(10).map(Text.new).toList(),
                            );
                          }
                          
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