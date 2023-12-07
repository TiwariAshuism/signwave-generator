import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
    BluetoothDevice? connectedDevice;
  Future<bool> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();

    await Future.delayed(Duration(seconds: 2));

    if (statuses[Permission.locationWhenInUse]!.isDenied &&
        statuses[Permission.bluetoothScan]!.isDenied &&
        statuses[Permission.bluetoothAdvertise]!.isDenied &&
        statuses[Permission.bluetoothConnect]!.isDenied) {
      Fluttertoast.showToast(
        msg: "Please Grant all the Required Permissions",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );

      Map<Permission, PermissionStatus> statuses = await [
        Permission.locationWhenInUse,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ].request();
    } // Check each permission status after.

    if (statuses[Permission.locationWhenInUse]!.isDenied &&
        statuses[Permission.bluetoothScan]!.isDenied &&
        statuses[Permission.bluetoothAdvertise]!.isDenied &&
        statuses[Permission.bluetoothConnect]!.isDenied) {
      Fluttertoast.showToast(
        msg:
            "The application can't run without the location and Bluetooth permission. Kindly go to settings and allow the application for the same.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }

    return statuses.values.map((value) => value.isGranted).contains(false)
        ? false
        : true;
  }

  Future<void> scanDevices() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
    }
    final isGranted = Platform.isAndroid ? await checkPermissions() : true;
    if (isGranted) {
      await FlutterBlue.instance.startScan(timeout: const Duration(seconds: 5));

      // Listen to scan results
      var subscription = FlutterBlue.instance.scanResults.listen((results) {
        // Do something with scan results
        for (ScanResult r in results) {
          print('${r.device.name} found! rssi: ${r.rssi}');
        }
      });
      print('subscription: $subscription');
    }
  }

  // Scan result stream
  Stream<List<ScanResult>> get scanResults => FlutterBlue.instance.scanResults;

  // Connect to device
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    // final mtu = await device.mtu.first;
    // Logger.info("current MTU is : $mtu");
    // await device.requestMtu(512);
    // // await device.connect();
    // final mtu1 = await device.mtu.first;
    // Logger.info("current MTU is : $mtu1");
  }
}
