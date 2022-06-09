import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../bluetooth/serial.dart';
import 'base.dart';

class SerialRoasterMachine extends MachineBaseAPI<SerialBluetooth> {
  final BluetoothConnection? connection;

  const SerialRoasterMachine(
      {required BluetoothDevice device,
      // required bool isConnected,
      required String modelId,
      required String productionId,
      this.connection})
      : super(productionId: productionId, modelId: modelId, device: device);

  SerialRoasterMachine copyWith(
      {BluetoothDevice? device,
      BluetoothConnection? connection,
      String? modelId,
      String? productionId}) {
    return SerialRoasterMachine(
        modelId: modelId ?? this.modelId,
        productionId: productionId ?? this.productionId,
        device: device ?? this.device,
        connection: connection ?? this.connection);
  }

  @override
  Future<bool> get isConnected async => connection?.isConnected ?? false;

  Future<void> disconnect() async {
    if (connection != null) {
      await connection!.finish();
    }
  }

  @override
  String get address => device.address;
}
