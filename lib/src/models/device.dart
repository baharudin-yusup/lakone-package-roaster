import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart' as ble_api;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    as serial_api;

typedef SerialBluetoothDevice = serial_api.BluetoothDevice;
typedef BleBluetoothDevice = ble_api.BluetoothDevice;

abstract class RoasterMachine<T> extends Equatable {
  String get fullName => 'Lakone $modelId@$productionId';

  final T device;

  // final String address;

  // final bool isConnected;
  final bool isBonded;

  final String modelId;
  final String productionId;

  Future<bool> get isConnected;
  String get address;

  const RoasterMachine(
      {required this.device,
      // this.address = '',
      // required this.isConnected,
      this.isBonded = false,
      required this.modelId,
      required this.productionId});

  String get name => 'Lakone $modelId';

  @override
  List<Object?> get props => [device, productionId, modelId];

// factory RoasterMachine.modify(RoasterMachine device,
//     {String? name,
//     String? address,
//     bool? isConnected,
//     bool? isBonded,
//     String? modelId,
//     String? productionId}) {
//   return RoasterMachine(
//       modelId: modelId ?? device.modelId,
//       productionId: productionId ?? device.productionId,
//       name: name ?? device.name,
//       address: address ?? device.address,
//       isConnected: isConnected ?? device.isConnected,
//       isBonded: isBonded ?? device.isBonded);
// }

}

class SerialRoasterMachine extends RoasterMachine<SerialBluetoothDevice> {
  final serial_api.BluetoothConnection? connection;

  const SerialRoasterMachine(
      {required serial_api.BluetoothDevice device,
      // required bool isConnected,
      required String modelId,
      required String productionId,
      this.connection})
      : super(productionId: productionId, modelId: modelId, device: device);

  SerialRoasterMachine copyWith(
      {serial_api.BluetoothDevice? device,
      serial_api.BluetoothConnection? connection,
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

class BleRoasterMachine extends RoasterMachine<BleBluetoothDevice> {
  @override
  Future<bool> get isConnected async =>
      (await device.state.first) == ble_api.BluetoothDeviceState.connected;

  const BleRoasterMachine(
      {required ble_api.BluetoothDevice device,
      required String modelId,
      required String productionId})
      : super(
          device: device,
          modelId: modelId,
          productionId: productionId,
        );

  @override
  List<Object?> get props => [...super.props, device];

  BleRoasterMachine copyWith(
      {String? name,
      String? address,
      bool? isConnected,
      ble_api.BluetoothDevice? device,
      bool? isBonded,
      String? modelId,
      String? productionId}) {
    return BleRoasterMachine(
      modelId: modelId ?? this.modelId,
      productionId: productionId ?? this.productionId,
      // isConnected: isConnected ?? this.isConnected,
      device: device ?? this.device,
    );
  }

  @override
  String get address => device.id.id;
}
