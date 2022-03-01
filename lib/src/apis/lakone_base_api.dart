import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
// as serial_api;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart' as ble_api;
import 'package:rxdart/rxdart.dart';

import '../../roaster_repository.dart';

part 'ble_api.dart';
part 'serial_api.dart';

abstract class BluetoothBaseAPI<Machine extends RoasterMachine,
    BluetoothDevice> {
  late StreamSubscription<List<int>> _rawDataController;

  final StreamController<Machine> _machineController;
  final StreamController<LakoneBluetoothState> _bluetoothController;
  final StreamController<String> _insightRawDataController;

  String get fn => "api.bluetooth";

  LakoneBluetoothState _latestBluetoothState;
  Machine? _latestMachine;

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
  void _sinkBluetoothState(LakoneBluetoothState state) {
    _latestBluetoothState = state;
  }

  BluetoothDevice? _verifyDevice(BluetoothDevice device);

  Machine _createMachine(BluetoothDevice device);

  BluetoothBaseAPI()
      : _machineController = BehaviorSubject<Machine>(),
        _bluetoothController = BehaviorSubject<LakoneBluetoothState>(),
        _insightRawDataController = BehaviorSubject<String>(),
        _latestBluetoothState = const LakoneBluetoothInitial();

  Stream<String> get onRawDataReceived => _insightRawDataController.stream;

  Stream<Machine> get onScanReceived => _machineController.stream;

  Stream<LakoneBluetoothState> get onBluetoothStateChanged =>
      _bluetoothController.stream;

  LakoneBluetoothState get latestBluetoothState => _latestBluetoothState;

  // Future<bool?> requestDisableBluetooth() async =>
  //     await serial_api.FlutterBluetoothSerial.instance.requestDisable();
}
