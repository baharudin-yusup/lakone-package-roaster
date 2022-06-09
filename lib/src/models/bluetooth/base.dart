import 'package:flutter_blue/flutter_blue.dart';

import '../../../roaster_repository.dart';

class BluetoothBaseAPI {
  static const BluetoothBaseAPI instance = BluetoothBaseAPI._();
  const BluetoothBaseAPI._();

  Future<BluetoothHardwareStatus> get isActive async {
    final isOn = await FlutterBlue.instance.isOn;
    return isOn ? BluetoothHardwareStatus.on : BluetoothHardwareStatus.off;
  }

  Stream<BluetoothHardwareStatus> get activeStatus async* {
    await for (BluetoothState state in FlutterBlue.instance.state) {
      final isOn = state == BluetoothState.on;
      final BluetoothHardwareStatus hardwareStatus =
          isOn ? BluetoothHardwareStatus.on : BluetoothHardwareStatus.off;

      yield hardwareStatus;
    }
  }
}
