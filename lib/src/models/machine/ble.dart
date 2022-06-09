import 'package:flutter_blue/flutter_blue.dart';

import '../bluetooth/ble.dart';
import 'base.dart';

class BleMachine extends MachineBaseAPI<BleBluetooth> {
  @override
  Future<bool> get isConnected async =>
      (await device.state.first) == BluetoothDeviceState.connected;

  const BleMachine(
      {required BluetoothDevice device, required String modelId, required String productionId})
      : super(
          device: device,
          modelId: modelId,
          productionId: productionId,
        );

  @override
  List<Object?> get props => [...super.props, device];

  BleMachine copyWith(
      {String? name,
      String? address,
      bool? isConnected,
      BluetoothDevice? device,
      bool? isBonded,
      String? modelId,
      String? productionId}) {
    return BleMachine(
      modelId: modelId ?? this.modelId,
      productionId: productionId ?? this.productionId,
      // isConnected: isConnected ?? this.isConnected,
      device: device ?? this.device,
    );
  }

  @override
  String get address => device.id.id;
}
