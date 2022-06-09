import '../bluetooth/dummy.dart';
import 'base.dart';

class DummyMachine extends MachineBaseAPI<DummyBluetooth> {
  const DummyMachine(
      {required DummyBluetooth device, required String modelId, required String productionId})
      : super(device: device, modelId: modelId, productionId: productionId);

  @override
  String get address => '0000000000';

  @override
  Future<bool> get isConnected async => device.isConnected;
}
