import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
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
        // Duration for how long the toast should appear
        gravity: ToastGravity.BOTTOM,
        // Position of the toast message
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );

      Map<Permission, PermissionStatus> statuses = await [
        Permission.locationWhenInUse,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ].request();
    } //check each permission status after.

    if (statuses[Permission.locationWhenInUse]!.isDenied &&
        statuses[Permission.bluetoothScan]!.isDenied &&
        statuses[Permission.bluetoothAdvertise]!.isDenied &&
        statuses[Permission.bluetoothConnect]!.isDenied) {
      Fluttertoast.showToast(
        msg:
        "The application can't run without the location and bluetooth permission. Kindly go to settings and allow the application for the same.",
        toastLength: Toast.LENGTH_SHORT,
        // Duration for how long the toast should appear
        gravity: ToastGravity.BOTTOM,
        // Position of the toast message
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }

    return statuses.values.map((value) => value.isGranted).contains(false)
        ? false
        : true;
  }

  Future scanDevices() async {
    final isGranted = Platform.isAndroid ? await checkPermissions() : true;
    if (isGranted) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

// Listen to scan results
      var subscription = FlutterBluePlus.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          print('${r.device.name} found! rssi: ${r.rssi}');
        }
      });
      print('subscription: $subscription');
    }
  }

  // scan result stream
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // connect to device
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    // final mtu = await device.mtu.first;
    // Logger.info("current MTU is : $mtu");
    // await device.requestMtu(512);
    // // await device.connect();
    // final mtu1 = await device.mtu.first;
    // Logger.info("current MTU is : $mtu1");
  }
}
