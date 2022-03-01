part of 'insight.dart';

class Environment {
  /// Time
  final double time;

  /// Temperature
  final double et;
  final double bt;
  // final double ror1;
  final double btRor;

  const Environment(
      {required this.time,
      required this.et,
      required this.bt,
      // required this.ror1,
      required this.btRor});

  const Environment.zero()
      : time = 0,
        et = 0,
        bt = 0,
        // ror1 = 0,
        btRor = 0;

  Environment copyWith({
    double? time,
    double? et,
    double? bt,
    // double? ror1,
    double? btRor,
  }) {
    return Environment(
        time: time ?? this.time,
        et: et ?? this.et,
        bt: bt ?? this.bt,
        // ror1: ror1 ?? this.ror1,
        btRor: btRor ?? this.btRor);
  }

  String get timeUI {
    int hour = time ~/ 3600;
    int minute = (time.toInt() % 3600) ~/ 60;
    int second = time.toInt() % 60;

    return '$hour : ${minute.toString().padLeft(2, '0')} : ${second.toString().padLeft(2, '0')}';
  }
}
