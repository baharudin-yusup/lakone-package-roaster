class DummyBluetooth {
  final String name;
  final bool isConnected;

  DummyBluetooth({required this.isConnected, required this.name});

  Future<void> connect() async {}
  Future<void> disconnect() async {}
}
