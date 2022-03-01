part of 'lakone_base_api.dart';

// class SerialAPI
//     extends BluetoothBaseAPI<SerialRoasterMachine, serial_api.BluetoothDevice> {
//   final serial = serial_api.FlutterBluetoothSerial.instance;
//
//   // final _SerialAdditionalData _data = _SerialAdditionalData();
//
//   SerialAPI() {
//     /// Init Bluetooth ON/OFF data
//     serial_api.FlutterBluetoothSerial.instance.state.then((state) {
//       final BluetoothHardwareStatus hardwareStatus = state.isEnabled
//           ? BluetoothHardwareStatus.on
//           : BluetoothHardwareStatus.off;
//       log('>> change-bluetooth-state-to: ${state.isEnabled ? "on" : "off"}',
//           name: fn);
//       _sinkBluetoothState(
//           latestBluetoothState.copyWith(hardwareStatus: hardwareStatus));
//     });
//
//     /// Listen Bluetooth ON/OFF data
//     serial_api.FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
//       final BluetoothHardwareStatus hardwareStatus = state.isEnabled
//           ? BluetoothHardwareStatus.on
//           : BluetoothHardwareStatus.off;
//
//       log('>> change-bluetooth-state-to: ${state.isEnabled ? "on" : "off"}',
//           name: fn);
//       _sinkBluetoothState(latestBluetoothState.copyWith(
//           hardwareStatus: hardwareStatus,
//           connectionStatus: BluetoothConnectionStatus.idle));
//     });
//   }
//
//   @override
//   String get fn => "api.serial";
//
//   @override
//   Future<SerialRoasterMachine> connect(SerialRoasterMachine rawMachine) async {
//     log('[connect-started]', name: fn);
//     log('> device: $rawMachine', name: fn);
//     _sinkBluetoothState(latestBluetoothState.copyWith(
//         connectionStatus: BluetoothConnectionStatus.connecting));
//
//     /// Variabel yang akan digunakan untuk koneksi
//     late serial_api.BluetoothConnection connection;
//
//     /// Cek apakah mesin sudah terkoneksi sebelumnya
//     /// jika sudah, maka putuskan sambungan
//     /// terlebih dahulu
//     log('> check-if-device-is-already-connected', name: fn);
//     final bool isConnected = await rawMachine.isConnected;
//     if (isConnected) {
//       log('> device-already-connected: trying-to-disconnect',
//           level: 100, name: fn);
//       try {
//         await rawMachine.disconnect();
//         log('> disconnect-success', level: 100, name: fn);
//       } catch (e) {
//         const errorCode = 'disconnect-error';
//         final message = e.toString();
//         final error = CustomError(code: errorCode, message: message);
//         log('> $errorCode: $message', level: 1000, name: fn);
//
//         _sinkBluetoothState(latestBluetoothState.toError(
//             error: error, connectionStatus: BluetoothConnectionStatus.idle));
//
//         throw error;
//       }
//     }
//
//     /// Lakukan koneksi dengan mesin
//     else {
//       log('> device-is-not-connected', name: fn);
//       log('> trying-to-connect', name: fn);
//       try {
//         connection = await serial_api.BluetoothConnection.toAddress(
//                 rawMachine.device.address)
//             .timeout(
//           const Duration(seconds: 10),
//           onTimeout: () async {
//             log('trying-to-connect-error: timeout-exception', name: fn);
//             throw 'timeout-exception';
//           },
//         ).onError((error, stackTrace) async {
//           log('trying-to-connect-error: on-error', name: fn);
//           throw error ?? 'unknown-error';
//         });
//
//         if (!connection.isConnected) {
//           throw 'connection-ok-but-unconnected';
//         }
//
//         log('> connect-success', name: fn);
//       } catch (e) {
//         String errorCode = 'connect-error';
//         String message = e.toString();
//         log('> $errorCode: $message', name: fn, level: 1000);
//
//         final error = CustomError(code: errorCode, message: message);
//
//         _sinkBluetoothState(latestBluetoothState.toError(
//             error: error, connectionStatus: BluetoothConnectionStatus.idle));
//         throw error;
//       }
//     }
//
//     final validMachine = SerialRoasterMachine(
//       device: rawMachine.device,
//       modelId: rawMachine.modelId,
//       productionId: rawMachine.productionId,
//       connection: connection,
//     );
//     _latestMachine = validMachine;
//
//     _rawDataController = validMachine.connection!.input!.listen((rawData) {
//       final data = String.fromCharCodes(rawData).trim();
//       // log('> raw-data-from-machine: $data', name: fn);
//       _insightRawDataController.sink.add(data);
//     });
//
//     _sinkBluetoothState(latestBluetoothState.copyWith(
//         connectionStatus: BluetoothConnectionStatus.connected));
//
//     return validMachine;
//   }
//
//   @override
//   Future<SerialRoasterMachine> disconnect(
//       {SerialRoasterMachine? machine}) async {
//     log('[start-disconnect]', name: fn);
//
//     if (latestBluetoothState.isOff) {
//       const code = 'bluetooth-is-off';
//       log('> $code', name: fn);
//
//       final error = CustomError(code: code, message: code);
//
//       _sinkBluetoothState(_latestBluetoothState.toError(
//           error: error,
//           connectionStatus: BluetoothConnectionStatus.idle,
//           hardwareStatus: BluetoothHardwareStatus.off));
//
//       throw error;
//     }
//
//     _sinkBluetoothState(_latestBluetoothState.copyWith(
//         connectionStatus: BluetoothConnectionStatus.disconnecting));
//
//     late SerialRoasterMachine verifiedMachine;
//
//     try {
//       /// Putuskan sambungan dari mesin permintaan user
//       if (machine != null) {
//         log('> using-demanded-machine', name: fn);
//         await machine.disconnect();
//         verifiedMachine = machine;
//       }
//
//       /// Putuskan sambungan dari mesin terakhir yang disimpan
//       else if (_latestMachine != null) {
//         log('> using-latest-machine', name: fn);
//         await _latestMachine!.disconnect();
//         verifiedMachine = _latestMachine!;
//       }
//
//       /// Tidak ada mesin yang dituju
//       else {
//         throw 'no-machine';
//       }
//     } catch (e) {
//       const errorCode = 'disconnect-error';
//       final message = e.toString();
//       final error = CustomError(code: errorCode, message: message);
//       log('> $errorCode: $message', level: 1000, name: fn);
//
//       _sinkBluetoothState(latestBluetoothState.toError(
//           error: error, connectionStatus: BluetoothConnectionStatus.idle));
//
//       throw error;
//     }
//
//     log('> trying-to-disconnect-subscription', name: fn);
//     try {
//       _rawDataController.cancel();
//       log('> disconnect-subscription-success', name: fn);
//     } catch (e) {
//       const errorCode = 'disconnect-subscription-error';
//       final message = e.toString();
//       final error = CustomError(code: errorCode, message: message);
//       log('> $errorCode: $message', level: 1000, name: fn);
//
//       _sinkBluetoothState(latestBluetoothState.toError(
//           error: error, connectionStatus: BluetoothConnectionStatus.idle));
//
//       throw error;
//     }
//
//     log('> disconnect-success', level: 100, name: fn);
//     _sinkBluetoothState(_latestBluetoothState.copyWith(
//         connectionStatus: BluetoothConnectionStatus.disconnected));
//     return verifiedMachine;
//   }
//
//   @override
//   Future<void> sendCommand(ClientCommand command) async {
//     log('[send-command-started]', name: fn);
//
//     log('> check-machine-avability', name: fn);
//     if (_latestMachine == null) {
//       log('> check-machine-avability: failed', name: fn);
//       const errorCode = 'latest-machine-is-null';
//       const message = 'latest-machine-is-null';
//       log('$errorCode: $message', name: fn, level: 1000);
//
//       final error = CustomError(code: errorCode, message: message);
//
//       throw error;
//     }
//     log('> check-machine-avability: success', name: fn);
//
//     final isConnected = await _latestMachine!.isConnected;
//     if (!isConnected) {
//       const errorCode = 'latest-machine-is-unconnected';
//       const message = 'latest-machine-is-unconnected';
//       log('$errorCode: $message', name: fn, level: 1000);
//
//       final error = CustomError(code: errorCode, message: message);
//
//       throw error;
//     }
//
//     _latestMachine!.connection!.output
//         .add(Uint8List.fromList(utf8.encode(command.send)));
//     await _latestMachine!.connection!.output.allSent;
//   }
//
//   @override
//   Future<void> startScan() async {
//     log('[start-scan]', name: fn);
//
//     if (latestBluetoothState.isOff) {
//       const errorCode = 'bluetooth-is-off';
//       final error = CustomError(code: errorCode, message: errorCode);
//
//       log(errorCode, name: fn);
//
//       _sinkBluetoothState(latestBluetoothState.toError(
//           error: error,
//           connectionStatus: BluetoothConnectionStatus.idle,
//           hardwareStatus: BluetoothHardwareStatus.off));
//
//       throw error;
//     }
//
//     /// Beritahu aplikasi bahwa scanning sedang berjalan
//     _sinkBluetoothState(
//       latestBluetoothState.copyWith(
//           hardwareStatus: BluetoothHardwareStatus.scanning),
//     );
//
//     serial.startDiscovery().listen((result) {
//       var verifiedDevice = _verifyDevice(result.device);
//       log('> device-name: ${result.device.name}', name: fn);
//       if (verifiedDevice != null) {
//         /// Roaster
//         final machine = SerialRoasterMachine(
//             device: verifiedDevice,
//             modelId: verifiedDevice.name!,
//             productionId: '0000');
//
//         _machineController.sink.add(machine);
//       }
//     }).onDone(() {
//       log('> scanning-finished', name: fn);
//       _sinkBluetoothState(latestBluetoothState.copyWith(
//           hardwareStatus: BluetoothHardwareStatus.on));
//     });
//   }
//
//   @override
//   Future<void> stopScan() async {
//     log('[stop-scan-started]', name: fn);
//
//     if (latestBluetoothState.isOff) {
//       const errorCode = 'bluetooth-is-off';
//       log('> $errorCode', name: fn, level: 500);
//
//       final error = CustomError(code: errorCode, message: errorCode);
//
//       _sinkBluetoothState(latestBluetoothState.toError(
//           error: error,
//           hardwareStatus: BluetoothHardwareStatus.off,
//           connectionStatus: BluetoothConnectionStatus.idle));
//
//       return;
//     }
//
//     try {
//       await serial.cancelDiscovery();
//       _sinkBluetoothState(latestBluetoothState.copyWith(
//           hardwareStatus: BluetoothHardwareStatus.on));
//     } catch (error) {
//       log(error.toString(), name: fn);
//     }
//
//     log('> stop-scan-success', name: fn);
//   }
//
//   @override
//   Future<bool> get bluetoothEnabledStatus async =>
//       await serial.isEnabled ?? false;
//
//   @override
//   void _sinkBluetoothState(LakoneBluetoothState state) {
//     _latestBluetoothState = state;
//     _bluetoothController.sink.add(state);
//   }
//
//   @override
//   SerialRoasterMachine _createMachine(device) {
//     // TODO: implement _createMachine
//     throw UnimplementedError();
//   }
//
//   @override
//   serial_api.BluetoothDevice? _verifyDevice(device) {
//     if (device.name == null) {
//       return null;
//     } else {
//       if (device.name!.substring(0, 2).toLowerCase() != 'hc' &&
//           device.name!.substring(0, 3).toLowerCase() != 'lkn') {
//         return null;
//       } else {
//         return device;
//       }
//     }
//
//     if (device.name!.substring(0, 3).toLowerCase() == 'lkn') {
//       return device;
//     }
//   }
// }
