import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

import '../menu/menu_screen.dart';
import 'BluetoothController.dart';

class BluetoothScan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                const SizedBox(height: 20 * 3),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade200, Colors.pink.shade500],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          controller.scanDevices();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Click here to Scan',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 1,
                    color: const Color.fromARGB(144, 255, 255, 255),
                    child: StreamBuilder<List<ScanResult>>(
                      stream: controller.scanResults,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final device = snapshot.data![index].device;
                                if (device.name == "") {
                                  return Container(); // Return an empty container for devices with no name
                                }

                                return Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Color(0xFFE0E0E0),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(18, 18),
                                        blurRadius: 58,
                                        color: Color(0xFF5A5A5A),
                                      ),
                                      BoxShadow(
                                        offset: Offset(-18, -18),
                                        blurRadius: 58,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    onTap: () {},
                                    title: Text(device.name == ""
                                        ? "Unknown Device"
                                        : device.name),
                                    subtitle: Text(device.id.id),
                                    trailing:
                                        StreamBuilder<BluetoothDeviceState>(
                                      stream: device.state,
                                      initialData:
                                          BluetoothDeviceState.disconnected,
                                      builder: (context, snapshot) {
                                        final connectionState = snapshot.data;
                                        final isDeviceConnected =
                                            connectionState ==
                                                BluetoothDeviceState.connected;
                                        final text = isDeviceConnected
                                            ? 'Disconnect'
                                            : 'Connect';
                                        final buttonColor = isDeviceConnected
                                            ? Colors.purple[900]
                                            : Colors.transparent;
                                        final textColor = Colors.pink;
                                        return TextButton(
                                          onPressed: () {
                                            if (isDeviceConnected) {
                                              device.disconnect();
                                            } else {
                                              controller
                                                  .connectToDevice(device);

                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MenuScreen(
                                                                device: device,
                                                              )),
                                                      (Route<dynamic> route) =>
                                                          false);
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: buttonColor,
                                            foregroundColor: textColor,
                                            side: BorderSide(
                                                color: Colors.black,
                                                width: 2.0),
                                          ),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text('No devices found'),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
