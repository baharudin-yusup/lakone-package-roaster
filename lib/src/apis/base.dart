import 'dart:async';
import 'dart:developer' show log;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import '../../roaster_repository.dart';
import '../models/bluetooth/base.dart';
import '../models/machine/base.dart';

abstract class ConnectionBaseAPI<Machine extends MachineBaseAPI, BluetoothDevice> {
  StreamSubscription<List<int>>? rawDataController;

  late final StreamController<Machine> machineController;
  late final StreamController<LakoneBluetoothState> bluetoothController;
  late final StreamController<String> insightRawDataController;
  late LakoneBluetoothState latestBluetoothState;

  String get fn => "api.base";

  Machine? latestMachine;

  Future<bool> get bluetoothEnabledStatus;

  Future<bool?> requestEnableBluetooth() async {
    AppSettings.openBluetoothSettings();
    return null;
  }

  Future<void> startScan();

  Future<void> stopScan();

  Future<Machine> connect(Machine rawMachine);

  Future<Machine> disconnect({Machine? machine});

  Future<void> sendCommand(ClientCommand command);

  @mustCallSuper
  void sinkBluetoothState(LakoneBluetoothState state) {
    latestBluetoothState = state;
    bluetoothController.sink.add(state);
  }

  BluetoothDevice? verifyDevice(BluetoothDevice device);

  Machine createMachine(BluetoothDevice device);

  @mustCallSuper
  ConnectionBaseAPI()
      : machineController = BehaviorSubject<Machine>(),
        bluetoothController = BehaviorSubject<LakoneBluetoothState>(),
        insightRawDataController = BehaviorSubject<String>(),
        latestBluetoothState = const LakoneBluetoothInitial() {
    const bluetooth = BluetoothBaseAPI.instance;
    bluetooth.isActive.then((status) {
      final isOn = status == BluetoothHardwareStatus.on;
      log('>> change-bluetooth-state-to: ${isOn ? "on" : "off"}', name: fn);
      sinkBluetoothState(latestBluetoothState.copyWith(hardwareStatus: status));
    });

    bluetooth.activeStatus.listen((state) {
      final isOn = state == BluetoothHardwareStatus.on;
      log('>> change-bluetooth-state-to: ${isOn ? "on" : "off"}', name: fn);
      sinkBluetoothState(latestBluetoothState.copyWith(hardwareStatus: state));
    });
  }

  Stream<String> get onRawDataReceived => insightRawDataController.stream;

  Stream<Machine> get onScanReceived => machineController.stream;

  Stream<LakoneBluetoothState> get onBluetoothStateChanged => bluetoothController.stream;

// Future<bool?> requestDisableBluetooth() async =>
//     await serial_api.FlutterBluetoothSerial.instance.requestDisable();
}
