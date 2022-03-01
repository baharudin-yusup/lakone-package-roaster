part of 'insight.dart';

class Record extends Insight {
  final Environment environment;
  final Control control;

  /// Controller
  final bool showRor;

  const Record({
    required this.environment,
    required this.control,
    this.showRor = true,
  });

  factory Record.fromLocal(List<dynamic> list) {
    /// TODO: OPTIMIZE SHOW
    double time = list[0] is double ? list[0] : list[0].toDouble();
    double et = list[1] is double ? list[1] : list[1].toDouble();
    double bt = list[2] is double ? list[2] : list[2].toDouble();
    // double ror1 = list[3] is double ? list[3] : list[3].toDouble();
    double btRor = list[4] is double ? list[4] : list[4].toDouble();
    return Record(
      environment: Environment(
        time: time,
        et: et,
        bt: bt,
        // ror1: ror1,
        btRor: btRor,
      ),
      control: Control(
        start: list[3] == 1,
        heater: list[5],
        airflow: list[6],
        charge: list[7] == 1,
        drum: list[8] == 1,
        firstCrack: list[9] == 1,
        discharge: list[10] == 1,
        cooling: list[11] == 1,
        dryEnd: list.length >= 14 ? list[13] == 1 : false,
      ),
      showRor: list.length >= 13 ? list[12] == 1 : true,
    );
  }

  factory Record.fromRoaster(List<String> list, bool showRor) {
    return Record(
      environment: Environment(
        time: double.parse(list[0]),
        et: double.parse(list[1]),
        bt: double.parse(list[2]),
        btRor: double.parse(list[4]),
      ),
      control: Control(
        start: list[3] == '1',
        heater: int.parse(list[5]),
        airflow: int.parse(list[6]),
        charge: list[7] == '1',
        drum: list[8] == '1',
        firstCrack: list[9] == '1',
        discharge: list[10] == '1',
        cooling: list[11] == '1',
        dryEnd: list.length >= 14 ? list[13] == '1' : false,
      ),
      showRor: showRor
          ? showRor
          : list.length >= 13
              ? list[12] == '1' || list[0] == '0'
              : true,
    );
  }

  // factory Record.fromInsider({
  //   double et = 0.0,
  //   double bt = 0.0,
  //   double ror1 = 0.0,
  //   double btRor = 0.0,
  //   double time = 0.0,
  //   bool charge = false,
  //   bool drum = false,
  //   bool discharge = false,
  //   bool firstCrack = false,
  //   int heater = 0,
  //   int airflow = 0,
  //   bool cooling = false,
  // }) {
  //   return Record(
  //     time: time,
  //     charge: charge,
  //     drum: drum,
  //     discharge: discharge,
  //     firstCrack: firstCrack,
  //     heater: heater,
  //     airflow: airflow,
  //     et: et,
  //     ror1: ror1,
  //     bt: bt,
  //     btRor: btRor,
  //     cooling: cooling,
  //   );
  // }

  // static bool isValid(List<dynamic> data) {
  //   if (data[0] is! double) {
  //     return false;
  //   }
  //   if (data[0] is! double) {
  //     return false;
  //   }
  //   return true;
  // }

  // factory Record.neutral({
  //   double? bt,
  //   double? et,
  //   double? btRor,
  // }) {
  //   return Record(
  //     time: 0,
  //     charge: false,
  //     drum: false,
  //     discharge: false,
  //     firstCrack: false,
  //     heater: 0,
  //     airflow: 0,
  //     et: et ?? 0.0,
  //     bt: bt ?? 0.0,
  //     btRor: btRor ?? 0.0,
  //     cooling: false,
  //     ror1: 0.0,
  //   );
  // }

  Record copyWith({
    Environment? environment,
    Control? control,
    bool? showRor,
  }) {
    return Record(
        environment: environment ?? this.environment,
        control: control ?? this.control,
        showRor: showRor ?? this.showRor);
  }

  @override
  String toString() {
    var time = environment.time.toString();
    var et = environment.et.toString();
    var bt = environment.bt.toString();
    var isStarted = control.start ? '1' : 0;
    var btRor = environment.btRor.toString();
    var heater = control.heater.toString();
    var airflow = control.airflow.toString();
    var charge = control.charge ? '1' : '0';
    var drum = control.drum ? '1' : '0';
    var firstCrack = control.firstCrack ? '1' : '0';
    var discharge = control.discharge ? '1' : '0';
    var cooling = control.cooling ? '1' : '0';
    var dryEnd = control.dryEnd ? '1' : '0';
    return '$time,$et,$bt,$isStarted,$btRor,$heater,$airflow,$charge,$drum,$firstCrack,$discharge,$cooling,$dryEnd';
  }

  String toIC() {
    var output = '';
    var et = environment.et.toInt().toString().padLeft(3, ' ');
    output += et;
    var bt = environment.bt.toInt().toString().padLeft(3, ' ');
    output += bt;
    var ror60 = environment.btRor.toStringAsFixed(1).padLeft(5, ' ');
    output += ror60;

    return '{IC:$output}';
  }

  List<dynamic> toListOfString() {
    return [
      environment.time,
      environment.et,
      environment.bt,
      control.start ? 1 : 0,
      environment.btRor,
      control.heater,
      control.airflow,
      control.charge ? 1 : 0,
      control.drum ? 1 : 0,
      control.firstCrack ? 1 : 0,
      control.discharge ? 1 : 0,
      control.cooling ? 1 : 0,
    ];
  }

  @override
  List<Object?> get props => [
        ...super.props,
        environment,
        control,
      ];
}
