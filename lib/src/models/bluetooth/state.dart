import 'package:equatable/equatable.dart';
import 'package:roaster_repository/src/models/custom_error.dart';

// abstract class BluetoothConnectionState extends Equatable {
//   final bool isConnected;
//   final String connectedAddress;
//   final RoasterMachine? machine;
//
//   const BluetoothConnectionState(
//       {required this.isConnected,
//       required this.connectedAddress,
//       this.machine});
//
//   @override
//   List<Object> get props => [isConnected, connectedAddress];
// }
//
// class BluetoothConnectionOnIdle extends BluetoothConnectionState {
//   const BluetoothConnectionOnIdle()
//       : super(isConnected: false, connectedAddress: "");
// }
//
// class BluetoothConnectionOnSuccess extends BluetoothConnectionState {
//   BluetoothConnectionOnSuccess(RoasterMachine machine)
//       : super(
//             isConnected: true,
//             connectedAddress: machine.address,
//             machine: machine);
// }

enum BluetoothConnectionStatus {
  idle,
  connecting,
  connected,
  disconnecting,
  disconnected
}

enum BluetoothHardwareStatus {
  off,
  on,
  scanning,
}

abstract class LakoneBluetoothState extends Equatable {
  final BluetoothConnectionStatus connectionStatus;
  final BluetoothHardwareStatus hardwareStatus;

  const LakoneBluetoothState(
      {required this.connectionStatus, required this.hardwareStatus});

  bool get isOff => hardwareStatus == BluetoothHardwareStatus.off;

  bool get isScanning => hardwareStatus == BluetoothHardwareStatus.scanning;

  bool get isOn => hardwareStatus != BluetoothHardwareStatus.off;

  bool get isConnecting =>
      connectionStatus == BluetoothConnectionStatus.connecting;

  bool get isConnected =>
      connectionStatus == BluetoothConnectionStatus.connected;

  @override
  List<Object> get props => [connectionStatus, hardwareStatus];

  LakoneBluetoothOnNormal copyWith({
    BluetoothConnectionStatus? connectionStatus,
    BluetoothHardwareStatus? hardwareStatus,
  }) {
    return LakoneBluetoothOnNormal(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      hardwareStatus: hardwareStatus ?? this.hardwareStatus,
    );
  }

  LakoneBluetoothOnError toError({
    required CustomError error,
    BluetoothConnectionStatus? connectionStatus,
    BluetoothHardwareStatus? hardwareStatus,
  }) {
    return LakoneBluetoothOnError(
      error: error,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      hardwareStatus: hardwareStatus ?? this.hardwareStatus,
    );
  }
}

class LakoneBluetoothOnNormal extends LakoneBluetoothState {
  const LakoneBluetoothOnNormal({
    required BluetoothConnectionStatus connectionStatus,
    required BluetoothHardwareStatus hardwareStatus,
  }) : super(
            connectionStatus: connectionStatus, hardwareStatus: hardwareStatus);
}

class LakoneBluetoothOnError extends LakoneBluetoothState {
  final CustomError error;

  const LakoneBluetoothOnError({
    required this.error,
    required BluetoothConnectionStatus connectionStatus,
    required BluetoothHardwareStatus hardwareStatus,
  }) : super(
          hardwareStatus: hardwareStatus,
          connectionStatus: connectionStatus,
        );

  @override
  List<Object> get props => [...super.props, error];
}

class LakoneBluetoothInitial extends LakoneBluetoothState {
  const LakoneBluetoothInitial()
      : super(
            hardwareStatus: BluetoothHardwareStatus.off,
            connectionStatus: BluetoothConnectionStatus.idle);
}

// class BluetoothActiveOnIdle extends LakoneBluetoothState {
//   const BluetoothActiveOnIdle()
//       : super(isEnabled: true, connection: const BluetoothConnectionOnIdle());
// }
//
// class BluetoothActiveOnConnected extends LakoneBluetoothState {
//   const BluetoothActiveOnConnected(BluetoothConnectionOnSuccess connectionState)
//       : super(isEnabled: true, connection: connectionState);
// }
//
// class BluetoothActiveOnConnectedError extends LakoneBluetoothState {
//   final String message;
//
//   const BluetoothActiveOnConnectedError(this.message)
//       : super(isEnabled: true, connection: const BluetoothConnectionOnIdle());
// }
//
// class BluetoothActiveOnScanning extends LakoneBluetoothState {
//   const BluetoothActiveOnScanning({BluetoothConnectionState? connection})
//       : super(
//             connection: connection ?? const BluetoothConnectionOnIdle(),
//             isScanning: true,
//             isEnabled: true);
// }
