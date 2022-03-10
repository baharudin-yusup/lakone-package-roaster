part of 'insight.dart';

class Record extends Insight {
  final Environment environment;
  final Control control;

  final bool showRor;

  const Record({
    required this.environment,
    required this.control,
    this.showRor = true,
  });

  factory Record.fromLocal(List<dynamic> list) {
    /// CSV Structure
    /// 0   : Time
    /// 1   : ET
    /// 2   : BT
    /// 3   : isStarted
    /// 4   : ROR
    /// 5   : Heater
    /// 6   : Airflow
    /// 7   : Status charge (ON/OFF)
    /// 8   : Status drum (ON/OFF)
    /// 9   : Status first crack (ON/OFF)
    /// 10  : Status discharge (ON/OFF)
    /// 11  : Status cooling (ON/OFF)
    /// 12  : RoR status
    /// 13  : Dry End
    final time = list[0] is double ? list[0] : double.parse(list[0]);
    final et = list[1] is double ? list[1] : double.parse(list[1]);
    final bt = list[2] is double ? list[2] : double.parse(list[2]);
    final start = list[3] == '1';
    final ror = list[4] is double ? list[4] : double.parse(list[4]);
    final heater = list[5] is int ? list[5] : int.parse(list[5]);
    final airflow = list[6] is int ? list[6] : int.parse(list[6]);
    final charge = list[7] == '1';
    final drum = list[8] == '1';
    final firstCrack = list[9] == '1';
    final discharge = list[10] == '1';
    final cooling = list[11] == '1';
    final rorStatus = list.length >= 14 ? list[12] == '1' : true;
    final dryEnd = list.length >= 14 ? list[13] == '1' : list[12] == '1';

    return Record(
      environment: Environment(
        time: time,
        et: et,
        bt: bt,
        btRor: ror,
      ),
      control: Control(
        start: start,
        heater: heater,
        airflow: airflow,
        charge: charge,
        drum: drum,
        firstCrack: firstCrack,
        discharge: discharge,
        cooling: cooling,
        dryEnd: dryEnd,
      ),
      showRor: rorStatus,
    );
  }

  factory Record.fromRoaster(List<String> list, bool showRor) {
    /// CSV Structure
    /// 0   : Time
    /// 1   : ET
    /// 2   : BT
    /// 3   : isStarted
    /// 4   : ROR
    /// 5   : Heater
    /// 6   : Airflow
    /// 7   : Status charge (ON/OFF)
    /// 8   : Status drum (ON/OFF)
    /// 9   : Status first crack (ON/OFF)
    /// 10  : Status discharge (ON/OFF)
    /// 11  : Status cooling (ON/OFF)
    /// 12  : RoR status
    /// 13  : Dry End
    final time = double.parse(list[0]);
    final et = double.parse(list[1]);
    final bt = double.parse(list[2]);
    final start = list[3] == '1';
    final ror = double.parse(list[4]);
    final heater = int.parse(list[5]);
    final airflow = int.parse(list[6]);
    final charge = list[7] == '1';
    final drum = list[8] == '1';
    final firstCrack = list[9] == '1';
    final discharge = list[10] == '1';
    final cooling = list[11] == '1';
    final rorStatus = list[12] == '1';
    final dryEnd = list[13] == '1';

    return Record(
      environment: Environment(
        time: time,
        et: et,
        bt: bt,
        btRor: ror,
      ),
      control: Control(
        start: start,
        heater: heater,
        airflow: airflow,
        charge: charge,
        drum: drum,
        firstCrack: firstCrack,
        discharge: discharge,
        cooling: cooling,
        dryEnd: dryEnd,
      ),
      showRor: rorStatus || showRor,
    );
  }

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
    var isStarted = control.start ? '1' : '0';
    var btRor = environment.btRor.toString();
    var heater = control.heater.toString();
    var airflow = control.airflow.toString();
    var charge = control.charge ? '1' : '0';
    var drum = control.drum ? '1' : '0';
    var firstCrack = control.firstCrack ? '1' : '0';
    var discharge = control.discharge ? '1' : '0';
    var cooling = control.cooling ? '1' : '0';
    var rorStatus = showRor ? '1' : '0';
    var dryEnd = control.dryEnd ? '1' : '0';
    return '$time,$et,$bt,$isStarted,$btRor,$heater,$airflow,$charge,$drum,$firstCrack,$discharge,$cooling,$rorStatus,$dryEnd';
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
