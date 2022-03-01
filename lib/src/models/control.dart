part of 'insight.dart';

class Control extends Equatable {
  final bool start;

  /// Control
  final bool charge;
  final bool drum;
  final bool discharge;
  final bool firstCrack;
  final int heater;
  final int airflow;
  final bool cooling;

  final bool dryEnd;

  const Control({
    required this.dryEnd,
    required this.start,
    required this.charge,
    required this.drum,
    required this.discharge,
    required this.firstCrack,
    required this.heater,
    required this.airflow,
    required this.cooling,
  });

  const Control.zero()
      : start = false,
        charge = false,
        drum = false,
        discharge = false,
        firstCrack = false,
        heater = 0,
        airflow = 0,
        cooling = false,
        dryEnd = false;

  Control copyWith({
    bool? start,
    bool? charge,
    bool? drum,
    bool? discharge,
    bool? firstCrack,
    int? heater,
    int? airflow,
    bool? cooling,
    bool? dryEnd,
  }) {
    return Control(
        dryEnd: dryEnd ?? this.dryEnd,
        start: start ?? this.start,
        charge: charge ?? this.charge,
        drum: drum ?? this.drum,
        discharge: discharge ?? this.discharge,
        firstCrack: firstCrack ?? this.firstCrack,
        heater: heater ?? this.heater,
        airflow: airflow ?? this.airflow,
        cooling: cooling ?? this.cooling);
  }

  @override
  List<Object?> get props => [
        start,
        charge,
        drum,
        discharge,
        firstCrack,
        heater,
        airflow,
        cooling,
        dryEnd
      ];
}
