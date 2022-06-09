// part of 'base.dart';

import 'dart:developer' show log;

import '../../roaster_repository.dart';
import '../models/bluetooth/base.dart';
import '../models/bluetooth/dummy.dart';
import '../models/machine/dummy.dart';
import 'base.dart';

class DummyAPI extends ConnectionBaseAPI<DummyMachine, DummyBluetooth> {
  DummyAPI();

  @override
  DummyMachine createMachine(DummyBluetooth device) {
    final modelId = device.name.substring(3, 7).toLowerCase();
    final productionId = device.name.substring(7, 12).toLowerCase();

    final verifiedMachine =
        DummyMachine(device: device, modelId: modelId, productionId: productionId);
    machineController.sink.add(verifiedMachine);

    return verifiedMachine;
  }

  @override
  DummyBluetooth? verifyDevice(DummyBluetooth device) {
    /// Cek apakah panjang nama bluetooth sudah sesuai
    /// Jika panjang nama tidak sama dengan
    /// 12, maka dianggap tidak valid
    if (device.name.length != 12) {
      log('> invalid-structure-name-length: ${device.name.length}', name: fn);
      return null;
    }

    /// Cek apakah ID lakone sudah sesuai
    /// Jika tidak sama dengan "lkn"
    /// maka dianggap tidak valid
    final lakoneId = device.name.substring(0, 3).toLowerCase();
    if (lakoneId != 'lkn') {
      log('> invalid-lakone-id: $lakoneId', name: fn);
      return null;
    }

    return device;
  }

  @override
  Future<bool> get bluetoothEnabledStatus async =>
      await BluetoothBaseAPI.instance.isActive == BluetoothHardwareStatus.on;

  @override
  Future<DummyMachine> connect(DummyMachine rawMachine) async {
    final validDevice = DummyBluetooth(isConnected: true, name: rawMachine.name);
    final validMachine = DummyMachine(
      device: validDevice,
      modelId: rawMachine.modelId,
      productionId: rawMachine.productionId,
    );

    latestMachine = validMachine;
    sinkBluetoothState(
        latestBluetoothState.copyWith(connectionStatus: BluetoothConnectionStatus.connected));

    return validMachine;
  }

  @override
  Future<DummyMachine> disconnect({DummyMachine? machine}) async {
    if (latestBluetoothState.isOff) {
      const code = 'bluetooth-is-off';
      log('> $code', name: fn);

      final error = CustomError(code: code, message: code);

      sinkBluetoothState(latestBluetoothState.toError(
          error: error,
          connectionStatus: BluetoothConnectionStatus.idle,
          hardwareStatus: BluetoothHardwareStatus.off));

      throw error;
    }

    log('[start-disconnect]', name: fn);
    sinkBluetoothState(
        latestBluetoothState.copyWith(connectionStatus: BluetoothConnectionStatus.disconnecting));

    late DummyMachine verifiedMachine;

    try {
      if (machine != null) {
        log('> using-demanded-machine', name: fn);
        await machine.device.disconnect();
        verifiedMachine = machine;
      } else if (latestMachine != null) {
        log('> using-latest-machine', name: fn);
        await latestMachine!.device.disconnect();
        verifiedMachine = latestMachine!;
      } else {
        throw 'no-machine';
      }
    } catch (e) {
      const errorCode = 'disconnect-error';
      final message = e.toString();
      final error = CustomError(code: errorCode, message: message);
      log('> $errorCode: $message', level: 1000, name: fn);

      sinkBluetoothState(latestBluetoothState.toError(
          error: error, connectionStatus: BluetoothConnectionStatus.idle));

      throw error;
    }

    log('> disconnect-success', level: 100, name: fn);
    sinkBluetoothState(
        latestBluetoothState.copyWith(connectionStatus: BluetoothConnectionStatus.disconnected));
    return verifiedMachine;
  }

  @override
  Future<void> sendCommand(ClientCommand command) async {
    // TODO: implement sendCommand
  }

  @override
  Future<void> startScan() async {
    log('[scan-machine-started]', name: fn);

    if (latestBluetoothState.isOff) {
      const errorCode = 'bluetooth-is-off';
      final error = CustomError(code: errorCode, message: errorCode);

      log(errorCode, name: fn);

      sinkBluetoothState(latestBluetoothState.toError(
          error: error,
          connectionStatus: BluetoothConnectionStatus.idle,
          hardwareStatus: BluetoothHardwareStatus.off));

      throw error;
    }

    /// Beritahu aplikasi bahwa scanning sedang berjalan
    sinkBluetoothState(
        latestBluetoothState.copyWith(hardwareStatus: BluetoothHardwareStatus.scanning));

    log('> start-scanning', name: fn);

    for (var i = 0; i < 7; i++) {
      final verifiedDevice = DummyBluetooth(isConnected: false, name: 'LKNZERO0000${i + 1}');
      final verifiedMachine = createMachine(verifiedDevice);
      machineController.sink.add(verifiedMachine);
    }

    log('> scanning-finished', name: fn);
    sinkBluetoothState(latestBluetoothState.copyWith(hardwareStatus: BluetoothHardwareStatus.on));
  }

  @override
  Future<void> stopScan() async {
    if (latestBluetoothState.isOff) {
      const errorCode = 'bluetooth-is-off';
      log('> $errorCode', name: fn, level: 500);

      final error = CustomError(code: errorCode, message: errorCode);

      sinkBluetoothState(latestBluetoothState.toError(
          error: error,
          hardwareStatus: BluetoothHardwareStatus.off,
          connectionStatus: BluetoothConnectionStatus.idle));

      return;
    }
  }
}
