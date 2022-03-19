import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roaster_repository/src/apis/apis.dart';
import 'package:roaster_repository/src/apis/lakone_base_api.dart';

import 'models/models.dart';

class _AdditionalData {
  String fragment = "";
}

class LakoneRepository {
  final StreamController<Insight> _insightController =
      StreamController<Insight>();
  final fn = "repository.lakone";
  final BluetoothBaseAPI<MachineAPI, BluetoothDeviceAPI> _api = BleAPI();
  final _AdditionalData _data = _AdditionalData();

  Stream<Insight> get onInsightReceived => _insightController.stream;

  LakoneRepository() {
    _api.onRawDataReceived.listen((data) {
      for (var i = 0; i < data.length; i++) {
        if (data[i] == "{") {
          _data.fragment = '';
        } else if (data[i] == "}") {
          var perfectData = _data.fragment;
          _data.fragment = '';
          _translate(perfectData);
        } else if (data[i] != "\r" && data[i] != "\n") {
          _data.fragment += data[i];
        }
      }
    });
  }

  /// Re-implements on API
  Future<bool> get bluetoothEnabledStatus async => _api.bluetoothEnabledStatus;

  void requestEnableBluetooth() => _api.requestEnableBluetooth();

  // Future<bool?> requestDisableBluetooth() async =>
  //     await _api.requestDisableBluetooth();

  Future<void> startScan() async {
    bool permissionOk = true;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      late final bool specialPermission = androidInfo.version.sdkInt != null &&
          androidInfo.version.sdkInt! > 30;

      if (specialPermission) {
        final bool connect =
            await Permission.bluetoothConnect.request().isGranted;

        final bool scan = await Permission.bluetoothScan.request().isGranted;

        final bool advertise =
            await Permission.bluetoothAdvertise.request().isGranted;

        final bool location = await Permission.location.request().isGranted;

        if (!connect || !scan || !location || !advertise) {
          permissionOk = false;
        }
      } else {
        final bool location = await Permission.location.request().isGranted;
        final bool bluetooth = await Permission.bluetooth.request().isGranted;
      }
    }

    if (permissionOk) {
      await _api.startScan();
    }
  }

  Future<void> stopScan() async => await _api.stopScan();

  Future<MachineAPI> connect(MachineAPI device) async =>
      await _api.connect(device);

  Future<MachineAPI> disconnect() async => await _api.disconnect();

  Future<void> sendCommand(ClientCommand command) async =>
      await _api.sendCommand(command);

  Stream<MachineAPI> get onScanReceived => _api.onScanReceived;

  Stream<LakoneBluetoothState> get onBluetoothStateChanged =>
      _api.onBluetoothStateChanged;

  LakoneBluetoothState get latestBluetoothState => _api.latestBluetoothState;

  void _translate(String information) {
    log('information: $information', name: fn);

    if (information.isEmpty) {
      return;
    }

    late HeaderType headerType;
    late List<String> dataHeader;
    late int statusHeader;
    var headerInfo = information.split(';');

    if (headerInfo.length < 2) {
      log('error header length < 2: ${headerInfo.length}');
      return;
    }

    try {
      headerType = HeaderType.values.firstWhere(
        (header) => (header.index + 1) == (int.tryParse(headerInfo[0]) ?? -1),
        orElse: () => HeaderType.unknown,
      );
    } catch (error) {
      log('_translator() headerType error [$information]: ${error.toString()}',
          name: fn);
    }

    try {
      dataHeader = headerInfo[1].split(',');
    } catch (error) {
      log('_translator() dataHeader error [$information]: ${error.toString()}',
          name: fn);
    }

    try {
      /// TODO: ADD STATUS HEADER ON ARDUINO
      statusHeader =
          headerInfo.length < 3 ? 0 : int.tryParse(headerInfo[2]) ?? -3;
    } catch (error) {
      log('_translator() statusHeader error [$information]: ${error.toString()}',
          name: fn);
    }

    switch (headerType) {
      case HeaderType.record:
        _insightController.sink.add(Record.fromRoaster(dataHeader, false));
        break;
      case HeaderType.command:
        log('read: ${information.toString()}', name: fn);
        _insightController.sink.add(_handleReceivedCommand(
            dataInfo: dataHeader, statusInfo: statusHeader));
        break;
      case HeaderType.recordWithRor:
        _insightController.sink.add(Record.fromRoaster(dataHeader, true));
        break;
      case HeaderType.unknown:
        _insightController.sink.add(UnknownInsight(headerInfo[0]));
        break;
    }
  }

  FeedbackCommand _handleReceivedCommand(
      {required List<String> dataInfo, required int statusInfo}) {
    var code = CommandCode.values.firstWhere(
      (commandCode) =>
          commandCode.toString() == 'CommandCode.' + dataInfo[0].toLowerCase(),
      orElse: () => CommandCode.uk,
    );

    switch (code) {
      case CommandCode.st:
        if (dataInfo[1] != '0' && dataInfo[1] != '1' && dataInfo[1] != '2') {
          return ErrorCommand(commandCode: code, errorCode: -1);
        }

        var value = dataInfo[1] == '1';

        if (dataInfo[1] == '2') {
          return const FeedbackResetCommand(value: true);
        }
        return FeedbackStartCommand(value: value);
      case CommandCode.ch:
        if (dataInfo[1] != '0' && dataInfo[1] != '1') {
          return ErrorCommand(commandCode: code, errorCode: -1);
        }

        var value = dataInfo[1] == '1';
        return FeedbackChargeCommand(value: value);
      case CommandCode.dr:
        if (dataInfo[1] != '0' && dataInfo[1] != '1') {
          _insightController.sink
              .add(ErrorCommand(commandCode: code, errorCode: -1));
        }

        var value = dataInfo[1] == '1';
        return FeedbackDrumCommand(value: value);
      case CommandCode.cr:
        if (dataInfo[1] != '0' && dataInfo[1] != '1') {
          return ErrorCommand(commandCode: code, errorCode: -1);
        }

        var value = dataInfo[1] == '1';
        return FeedbackCrackCommand(value: value);
      case CommandCode.de:
        if (dataInfo[1] != '0' && dataInfo[1] != '1') {
          return ErrorCommand(commandCode: code, errorCode: -1);
        }

        var value = dataInfo[1] == '1';
        return FeedbackDryEndCommand(value: value);
      case CommandCode.dc:
        if (dataInfo[1] != '0' && dataInfo[1] != '1') {
          return ErrorCommand(commandCode: code, errorCode: -1);
        }

        var value = dataInfo[1] == '1';
        return FeedbackDischargeCommand(value: value);
      case CommandCode.cl:
        if (dataInfo[1] != '0' && dataInfo[1] != '1') {
          return ErrorCommand(
              commandCode: code, errorCode: -1, value: dataInfo[1]);
        }

        var value = dataInfo[1] == '1';
        return FeedbackCoolingCommand(value: value);
      case CommandCode.ht:
        var value = int.tryParse(dataInfo[1]);
        if (value == null || (value < 0 && value > 110)) {
          return ErrorCommand(commandCode: code, errorCode: -1, value: value);
        }

        return FeedbackHeaterCommand(value: value);
      case CommandCode.af:
        var value = int.tryParse(dataInfo[1]);
        if (value == null || (value < 0 && value > 100)) {
          return ErrorCommand(commandCode: code, errorCode: -1, value: value);
        }

        return FeedbackAirflowCommand(value: value);
      case CommandCode.ic:
        var value = dataInfo[1] == '1';

        return FeedbackInitialConditionCommand(
            value: value, status: InsightStatus(code: statusInfo));
      case CommandCode.md:
        if (dataInfo[1] != '0' && dataInfo[1] != '1' && dataInfo[1] != '-1') {
          return ErrorCommand(commandCode: code, errorCode: -1);
        }

        var type = ModeType.values.firstWhere(
          (modeType) => modeType.index == int.parse(dataInfo[1]),
          orElse: () => ModeType.unknown,
        );

        return FeedbackModeCommand(
            type: type, status: InsightStatus(code: statusInfo));
      case CommandCode.at:
        return FeedbackAutoCommand(status: InsightStatus(code: statusInfo));
      case CommandCode.nc:
        return FeedbackNotifyCommand(data: dataInfo[1]);
        break;
      case CommandCode.uk:
        log('unknown command: $dataInfo | $statusInfo');
        return ErrorCommand(commandCode: code, errorCode: -2);
    }
  }
}
