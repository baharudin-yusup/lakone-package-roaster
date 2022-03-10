part of 'lakone_base_api.dart';

class _BleAdditionalData {
  final String validLakoneId = 'lkn';
  late ble_api.BluetoothCharacteristic characteristic;
}

class BleAPI extends BluetoothBaseAPI<BleRoasterMachine, BleBluetoothDevice> {
  final ble = ble_api.FlutterBlue.instance;
  final String validServiceUuid = '0000FFE0-0000-1000-8000-00805F9B34FB';
  final String validCharacteristicUuid = '0000FFE1-0000-1000-8000-00805F9B34FB';

  final _BleAdditionalData _data = _BleAdditionalData();

  BleAPI() {
    ble.isOn.then((isOn) {
      final BluetoothHardwareStatus hardwareStatus =
          isOn ? BluetoothHardwareStatus.on : BluetoothHardwareStatus.off;
      log('>> change-bluetooth-state-to: ${isOn ? "on" : "off"}', name: fn);
      _sinkBluetoothState(
          latestBluetoothState.copyWith(hardwareStatus: hardwareStatus));
    });

    ble.state.listen((state) {
      final isOn = state == ble_api.BluetoothState.on;
      final BluetoothHardwareStatus hardwareStatus =
          isOn ? BluetoothHardwareStatus.on : BluetoothHardwareStatus.off;

      log('>> change-bluetooth-state-to: ${isOn ? "on" : "off"}', name: fn);
      _sinkBluetoothState(
          latestBluetoothState.copyWith(hardwareStatus: hardwareStatus));
    });
  }

  @override
  Future<BleRoasterMachine> connect(BleRoasterMachine rawMachine) async {
    log('[connect-started]', name: fn);
    log('> device: ${rawMachine.device.toString()}', name: fn);
    _sinkBluetoothState(latestBluetoothState.copyWith(
        connectionStatus: BluetoothConnectionStatus.connecting));

    /// Cek apakah mesin sudah terkoneksi sebelumnya
    /// jika sudah, maka putuskan sambungan
    /// terlebih dahulu
    log('> check-if-device-is-already-connected', name: fn);
    final bool isConnected = await rawMachine.isConnected;
    if (isConnected) {
      log('> device-already-connected: trying-to-disconnect',
          level: 100, name: fn);
      try {
        await rawMachine.device.disconnect();
        log('> disconnect-success', level: 100, name: fn);
      } catch (e) {
        const errorCode = 'disconnect-error';
        final message = e.toString();
        final error = CustomError(code: errorCode, message: message);
        log('> $errorCode: $message', level: 1000, name: fn);

        _sinkBluetoothState(latestBluetoothState.toError(
            error: error, connectionStatus: BluetoothConnectionStatus.idle));

        throw error;
      }
    }

    /// Lakukan koneksi dengan mesin
    else {
      log('> device-is-not-connected', name: fn);
      log('> trying-to-connect', name: fn);
      try {
        await rawMachine.device.connect(autoConnect: false).timeout(
          const Duration(seconds: 10),
          onTimeout: () async {
            log('trying-to-connect-error: timeout-exception', name: fn);
            throw 'timeout-exception';
          },
        ).onError((error, stackTrace) async {
          log('trying-to-connect-error: on-error', name: fn);
          throw error ?? 'unknown-error';
        });
        log('> connect-success', name: fn);
      } catch (e) {
        String errorCode = 'connect-error';
        String message = e.toString();
        log('> $errorCode: $message', name: fn, level: 1000);

        final error = CustomError(code: errorCode, message: message);

        _sinkBluetoothState(latestBluetoothState.toError(
            error: error, connectionStatus: BluetoothConnectionStatus.idle));
        throw error;
      }
    }

    log('> trying-get-characteristic', name: fn);
    late ble_api.BluetoothCharacteristic validCharacteristic;
    try {
      validCharacteristic = await _searchCharacteristic(rawMachine.device);
      log('> get-characteristic-success', name: fn);
    } on CustomError catch (error) {
      log('> get-characteristic-error', name: fn, level: 1000);
      log('> trying-to-disconnect', name: fn, level: 1000);
      try {
        await disconnect(machine: rawMachine);
        log('> disconnect-success', level: 100, name: fn);
      } catch (e) {
        const errorCode = 'disconnect-error';
        final message = e.toString();
        log('> $errorCode: $message', level: 1000, name: fn);
      }

      _sinkBluetoothState(latestBluetoothState.toError(
          error: error, connectionStatus: BluetoothConnectionStatus.idle));

      rethrow;
    } catch (e) {
      try {
        await rawMachine.device.disconnect();
        log('> disconnect-success', level: 100, name: fn);
      } catch (e) {
        const errorCode = 'disconnect-error';
        final message = e.toString();
        log('> $errorCode: $message', level: 1000, name: fn);

        final error = CustomError(code: errorCode, message: message);
        _sinkBluetoothState(latestBluetoothState.toError(
            error: error, connectionStatus: BluetoothConnectionStatus.idle));

        throw error;
      }

      rethrow;
    }

    if (Platform.isAndroid) {
      log('> trying-to-get-mtu', name: fn);
      try {
        var mtu = await rawMachine.device.mtu.first;
        log('> mtu-size: $mtu', name: fn);

        log('> request-mtu-size: 512', name: fn);
        await rawMachine.device.requestMtu(512);

        for (var i = 0; i < 10; i++) {
          if (mtu < 512) {
            log("> waiting-for-requested-mtu", name: fn);
            log("> current-mtu: $mtu target: 512", name: fn);
            await Future.delayed(const Duration(milliseconds: 500));
            mtu = await rawMachine.device.mtu.first;
          }
        }

        if (mtu >= 512) {
          log("> request-mtu-success: $mtu", name: fn);
        } else {
          log("> request-mtu-failed: $mtu", name: fn);
        }
      } catch (e) {
        const errorCode = 'get-mtu-error';
        final message = e.toString();
        log('> $errorCode: $message', name: fn);
      }
    }

    /// Semua pengecekan mesin sudah valid,
    /// maka lakukan streaming pesan
    await Future.delayed(const Duration(milliseconds: 500));
    await validCharacteristic.setNotifyValue(true);

    rawMachine.device.state.listen((state) {
      if (state == ble_api.BluetoothDeviceState.disconnected) {
        _sinkBluetoothState(latestBluetoothState.copyWith(
            connectionStatus: BluetoothConnectionStatus.disconnected));
      }
    });

    _rawDataController = validCharacteristic.value.listen((rawData) {
      final data = String.fromCharCodes(rawData).trim();
      // log('> raw-data-from-machine: $data', name: fn);
      _insightRawDataController.sink.add(data);
    });

    final validMachine = BleRoasterMachine(
      device: rawMachine.device,
      modelId: rawMachine.modelId,
      productionId: rawMachine.productionId,
    );

    _latestMachine = validMachine;
    _sinkBluetoothState(latestBluetoothState.copyWith(
        connectionStatus: BluetoothConnectionStatus.connected));

    return validMachine;
  }

  @override
  Future<BleRoasterMachine> disconnect({BleRoasterMachine? machine}) async {
    if (latestBluetoothState.isOff) {
      const code = 'bluetooth-is-off';
      log('> $code', name: fn);

      final error = CustomError(code: code, message: code);

      _sinkBluetoothState(_latestBluetoothState.toError(
          error: error,
          connectionStatus: BluetoothConnectionStatus.idle,
          hardwareStatus: BluetoothHardwareStatus.off));

      throw error;
    }

    log('[start-disconnect]', name: fn);
    _sinkBluetoothState(_latestBluetoothState.copyWith(
        connectionStatus: BluetoothConnectionStatus.disconnecting));

    late BleRoasterMachine verifiedMachine;

    try {
      if (machine != null) {
        log('> using-demanded-machine', name: fn);
        await machine.device.disconnect();
        verifiedMachine = machine;
      } else if (_latestMachine != null) {
        log('> using-latest-machine', name: fn);
        await _latestMachine!.device.disconnect();
        verifiedMachine = _latestMachine!;
      } else {
        throw 'no-machine';
      }
    } catch (e) {
      const errorCode = 'disconnect-error';
      final message = e.toString();
      final error = CustomError(code: errorCode, message: message);
      log('> $errorCode: $message', level: 1000, name: fn);

      _sinkBluetoothState(latestBluetoothState.toError(
          error: error, connectionStatus: BluetoothConnectionStatus.idle));

      throw error;
    }

    log('> trying-to-disconnect-subscription', name: fn);
    try {
      _rawDataController?.cancel();
      log('> disconnect-subscription-success', name: fn);
    } catch (e) {
      const errorCode = 'disconnect-subscription-error';
      final message = e.toString();
      final error = CustomError(code: errorCode, message: message);
      log('> $errorCode: $message', level: 1000, name: fn);

      _sinkBluetoothState(latestBluetoothState.toError(
          error: error, connectionStatus: BluetoothConnectionStatus.idle));

      throw error;
    }

    log('> disconnect-success', level: 100, name: fn);
    _sinkBluetoothState(_latestBluetoothState.copyWith(
        connectionStatus: BluetoothConnectionStatus.disconnected));
    return verifiedMachine;
  }

  Future<ble_api.BluetoothCharacteristic> _searchCharacteristic(
      ble_api.BluetoothDevice device) async {
    log('[search-characteristic-started]', name: fn);
    late List<ble_api.BluetoothService> services;

    log('> trying-to-discover-services', name: fn);
    try {
      services = await device
          .discoverServices()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        log('> discover-services-timeout', name: fn);
        throw 'discover-services-timeout';
      });
    } catch (e) {
      const code = 'discover-services-error';
      final message = e.toString();
      log('> $code: $message', name: fn);

      final error = CustomError(code: code, message: message);
      _sinkBluetoothState(latestBluetoothState.toError(
          error: error, connectionStatus: BluetoothConnectionStatus.idle));
      throw error;
    }
    log('> discover-services-success', name: fn);

    log('> trying-to-get-characteristic', name: fn);
    late ble_api.BluetoothCharacteristic validCharacteristic;
    var serviceOk = false;
    var characteristicOk = false;
    for (var service in services) {
      final serviceUuid = service.uuid.toString().toUpperCase();
      if (serviceUuid == validServiceUuid) {
        serviceOk = true;
        for (var characteristic in service.characteristics) {
          final characteristicUud =
              characteristic.uuid.toString().toUpperCase();
          if (characteristicUud == validCharacteristicUuid) {
            characteristicOk = true;
            validCharacteristic = characteristic;
          }
        }
      }
    }

    /// Jika UUI tidak dikenali maka putuskan sambungan
    if (!serviceOk || !characteristicOk) {
      const errorCode = 'machine-state-invalid';
      final message =
          '[service: $serviceOk] [characteristic: $characteristicOk]';
      log('> $errorCode: $message', level: 500, name: fn);
      log('> trying-to-disconnect', level: 100, name: fn);

      final error = CustomError(code: errorCode, message: message);

      throw error;
    } else {
      return validCharacteristic;
    }
  }

  @override
  Future<void> sendCommand(ClientCommand command) async {
    log('[send-command-started]', name: fn);

    if (_latestMachine == null) {
      const errorCode = 'latest-machine-is-null';
      const message = 'latest-machine-is-null';
      log('$errorCode: $message', name: fn, level: 1000);

      final error = CustomError(code: errorCode, message: message);

      throw error;
    }

    final character = await _searchCharacteristic(_latestMachine!.device);

    try {
      await character.write(utf8.encode('${command.send} \r\n'),
          withoutResponse: true);
    } catch (e) {
      const errorCode = 'latest-machine-is-null';
      final message = e.toString();
      log('$errorCode: $message', name: fn, level: 1000);

      final error = CustomError(code: errorCode, message: message);

      throw error;
    }
  }

  @override
  Future<void> startScan() async {
    if (latestBluetoothState.isOff) {
      const errorCode = 'bluetooth-is-off';
      final error = CustomError(code: errorCode, message: errorCode);

      log(errorCode, name: fn);

      _sinkBluetoothState(latestBluetoothState.toError(
          error: error,
          connectionStatus: BluetoothConnectionStatus.idle,
          hardwareStatus: BluetoothHardwareStatus.off));

      throw error;
    }

    log('[scan-machine-started]', name: fn);

    /// Cek apakah aplikasi sedang kondisi scanning
    /// Jika iya, maka berhentikan dulu agar tidak
    /// menimbulkan scanning tumpang tindih
    bool isScanning = await ble.isScanning.first;
    if (isScanning) {
      log('> scan-already-started', name: fn);
      await stopScan();
    }

    log('> no-scanning-condition: passed!', name: fn);

    /// Beritahu aplikasi bahwa scanning sedang berjalan
    _sinkBluetoothState(latestBluetoothState.copyWith(
        hardwareStatus: BluetoothHardwareStatus.scanning));

    /// Cari device terkoneksi terlebih dahulu
    ///
    /// Ambil data Id bluetooth yang sudah terkoneksi
    /// untuk keperluan UI dan fungsi lainnya
    log('> add-connected-device', name: fn);
    final connectedDevices = (await ble.connectedDevices);
    final List<ble_api.BluetoothDevice> connectedVerifiedDevices = [];
    final connectedVerifiedIdDevices = <String>[];
    log('> connected-device: ${connectedDevices.length} founded', name: fn);
    for (var device in connectedDevices) {
      log('> connected-device: $device founded', name: fn);
      final verifiedDevice = _verifyDevice(device);

      if (verifiedDevice != null &&
          !connectedVerifiedIdDevices.contains(verifiedDevice.id.id)) {
        log('> verified-connected-device: $verifiedDevice', name: fn);
        connectedVerifiedDevices.add(verifiedDevice);
        final verifiedMachine = _createMachine(device);
        connectedVerifiedIdDevices.add(verifiedDevice.id.id);
        _machineController.sink.add(verifiedMachine);
      }
    }
    log('> connected-verified-device: ${connectedVerifiedDevices.length} founded',
        name: fn);

    log('> start-scanning', name: fn);

    /// Perintah scanning sedang dijalankan
    ble.scan(timeout: const Duration(seconds: 15)).listen((r) {
      final device = r.device;
      log('> device-found: ${device.toString()}', name: fn);

      if (connectedVerifiedIdDevices.contains(device.id.id) == false) {
        connectedVerifiedIdDevices.add(device.id.id);
        final verifiedDevice = _verifyDevice(r.device);
        if (verifiedDevice != null) {
          final verifiedMachine = _createMachine(device);
          connectedVerifiedDevices.add(verifiedDevice);
          _machineController.sink.add(verifiedMachine);
        }
      }
    }, onDone: () {
      log('> scanning-finished', name: fn);
      _sinkBluetoothState(latestBluetoothState.copyWith(
          hardwareStatus: BluetoothHardwareStatus.on));
    });
  }

  @override
  BleRoasterMachine _createMachine(ble_api.BluetoothDevice device) {
    /// Asumsikan ID model dan ID Produksi
    /// Sudah sesuai dengan ketentuan
    final modelId = device.name.substring(3, 7).toLowerCase();
    final productionId = device.name.substring(7, 12).toLowerCase();

    /// Buat model mesin yang sudah diverifikasi
    /// dan beritahu aplikasi agar melakukan
    /// pembaharuan pada sisi UI
    final verifiedMachine = BleRoasterMachine(
        device: device, modelId: modelId, productionId: productionId);
    _machineController.sink.add(verifiedMachine);

    return verifiedMachine;
  }

  @override
  Future<void> stopScan() async {
    log('[stop-scan-started]', name: fn);

    if (latestBluetoothState.isOff) {
      const errorCode = 'bluetooth-is-off';
      log('> $errorCode', name: fn, level: 500);

      final error = CustomError(code: errorCode, message: errorCode);

      _sinkBluetoothState(latestBluetoothState.toError(
          error: error,
          hardwareStatus: BluetoothHardwareStatus.off,
          connectionStatus: BluetoothConnectionStatus.idle));

      return;
    }

    try {
      await ble.stopScan();
      _sinkBluetoothState(latestBluetoothState.copyWith(
          hardwareStatus: BluetoothHardwareStatus.on));
    } catch (error) {
      log(error.toString(), name: fn);
    }
    log('> stop-scan-success', name: fn);
  }

  @override
  Future<bool> get bluetoothEnabledStatus async => await ble.isOn;

  @override
  void _sinkBluetoothState(LakoneBluetoothState state) {
    super._sinkBluetoothState(state);
    _bluetoothController.sink.add(state);
  }

  @override
  ble_api.BluetoothDevice? _verifyDevice(ble_api.BluetoothDevice device) {
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
    if (lakoneId != _data.validLakoneId) {
      log('> invalid-lakone-id: $lakoneId', name: fn);
      return null;
    }

    return device;
  }
}
