import 'package:equatable/equatable.dart';

abstract class MachineBaseAPI<T> extends Equatable {
  String get fullName => 'Lakone $modelId@$productionId';

  final T device;

  // final String address;

  // final bool isConnected;
  final bool isBonded;

  final String modelId;
  final String productionId;

  Future<bool> get isConnected;
  String get address;

  const MachineBaseAPI(
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
