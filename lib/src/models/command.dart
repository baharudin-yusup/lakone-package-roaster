part of 'insight.dart';

enum CommandCode {
  st,
  ch,
  dr,
  cr,
  dc,
  cl,
  ht,
  af,
  ic,
  md,
  at,
  uk,

  /// New Code
  de,
  nc,
}

enum ModeType { manual, auto, unknown }

abstract class Command extends Insight {
  final CommandCode code;

  const Command(this.code, {InsightStatus? status})
      : super(status: status ?? const InsightStatus());
}

/// Client Command

abstract class ClientCommand extends Command {
  const ClientCommand(CommandCode code, {InsightStatus? status})
      : super(code, status: status ?? const InsightStatus());

  String get send;
}

abstract class FeedbackCommand extends Command {
  const FeedbackCommand(CommandCode code, {InsightStatus? status})
      : super(code, status: status ?? const InsightStatus());
}

class StartCommand extends ClientCommand {
  final bool value;
  final double? lastIndex;
  final int? slotId;

  const StartCommand({required this.value, InsightStatus? status, this.lastIndex, this.slotId})
      : super(CommandCode.st, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value, slotId];

  @override
  String get send {
    final String code = EnumToString.convertToString(this.code).toUpperCase();
    final String value = this.value ? '1' : '0';
    final String slotId = this.slotId != null ? this.slotId!.toString() : '';
    return '{$code:$value$slotId}';
  }
}

class ResetCommand extends ClientCommand {
  final double value;

  const ResetCommand({InsightStatus? status, required this.value})
      : super(CommandCode.st, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:2}';
}

class ChargeCommand extends ClientCommand {
  final bool value;

  const ChargeCommand({required this.value, InsightStatus? status})
      : super(CommandCode.ch, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:${value ? '1' : '0'}}';
}

class DrumCommand extends ClientCommand {
  final bool value;

  const DrumCommand({required this.value, InsightStatus? status})
      : super(CommandCode.dr, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:${value ? '1' : '0'}}';
}

class CrackCommand extends ClientCommand {
  final bool value;

  const CrackCommand({required this.value, InsightStatus? status})
      : super(CommandCode.cr, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:${value ? '1' : '0'}}';
}

class DryEndCommand extends ClientCommand {
  final bool value;

  const DryEndCommand({required this.value, InsightStatus? status})
      : super(CommandCode.de, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:${value ? '1' : '0'}}';
}

class DischargeCommand extends ClientCommand {
  final bool value;

  const DischargeCommand({required this.value, InsightStatus? status})
      : super(CommandCode.dc, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:${value ? '1' : '0'}}';
}

class CoolingCommand extends ClientCommand {
  final bool value;

  const CoolingCommand({required this.value, InsightStatus? status})
      : super(CommandCode.cl, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:${value ? '1' : '0'}}';
}

class HeaterCommand extends ClientCommand {
  final int value;

  const HeaterCommand({required this.value, InsightStatus? status})
      : super(CommandCode.ht, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:$value}';
}

class AirflowCommand extends ClientCommand {
  final int value;

  const AirflowCommand({required this.value, InsightStatus? status})
      : super(CommandCode.af, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];

  @override
  String get send => '{${EnumToString.convertToString(code).toUpperCase()}:$value}';
}

class InitialConditionCommand extends ClientCommand {
  final double et;
  final double bt;
  final double btRor;

  const InitialConditionCommand(
      {required this.et, required this.bt, required this.btRor, InsightStatus? status})
      : super(CommandCode.ic, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, et, bt, btRor];

  @override
  String get send {
    var output = '';

    /// ET & BT: 300.0 => 5
    /// ROR: -99.0 => 5
    /// Total Length: 15
    var et = this.et.toStringAsFixed(1).padLeft(5, ' ');
    output += et;
    var bt = this.bt.toStringAsFixed(1).padLeft(5, ' ');
    output += bt;
    var ror60 = btRor.toStringAsFixed(1).padLeft(5, ' ');
    output += ror60;
    return '{${EnumToString.convertToString(code).toUpperCase()}:$output}';
  }
}

class ModeCommand extends ClientCommand {
  final ModeType type;

  const ModeCommand({required this.type, InsightStatus? status})
      : super(CommandCode.md, status: status ?? const InsightStatus());

  @override
  String get send {
    late int index;

    for (int i = 0; i < ModeType.values.length; i++) {
      if (type == ModeType.values[i]) {
        index = i;
        break;
      }
    }

    return '{${EnumToString.convertToString(code).toUpperCase()}:$index}';
  }

  @override
  List<Object?> get props => [...super.props, type];
}

class AutoCommand extends ClientCommand {
  final Record record;

  const AutoCommand({required this.record, InsightStatus? status})
      : super(CommandCode.at, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, record];

  @override
  String get send {
    /// 300 | 3 | 0 - 2
    late final String bt;
    if (record.environment.bt > 999) {
      bt = '999';
    } else {
      bt = record.environment.bt.toStringAsFixed(0).padLeft(3, ' ');
    }

    /// -80.0 | 5 | 3 - 7
    late final String btRor;
    if (record.environment.btRor > 99) {
      btRor = ' 99.0';
    } else if (record.environment.btRor < -99) {
      btRor = '-99.0';
    } else {
      btRor = record.environment.btRor.toStringAsFixed(1).padLeft(5, ' ');
    }

    /// 100 | 3 | 8 - 10
    final heater = record.control.heater.toString().padLeft(3, ' ');

    /// 100 | 3 | 11 - 13
    final airflow = record.control.airflow.toString().padLeft(3, ' ');

    /// 1 | 1 | 14 - 14
    final charge = record.control.charge ? '1' : '0';

    /// 1 | 1 | 15 - 15
    final drum = record.control.drum ? '1' : '0';

    /// 1 | 1 | 16 - 16
    final firstCrack = record.control.firstCrack ? '1' : '0';

    /// 1 | 1 | 17 - 17
    final discharge = record.control.discharge ? '1' : '0';

    /// 1 | 1 | 18 - 18
    final cooling = record.control.cooling ? '1' : '0';

    /// 1 | 1 | 19 - 19
    final dryEnd = record.control.dryEnd ? '1' : '0';

    final output = '$bt$btRor$heater$airflow$charge$drum$firstCrack$discharge$cooling$dryEnd';

    return '{${EnumToString.convertToString(code).toUpperCase()}:$output}';
  }
}

class NotifyCommand extends ClientCommand {
  final CommandCode notifyCode;

  const NotifyCommand({required this.notifyCode, InsightStatus? status})
      : super(CommandCode.at, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, notifyCode];

  @override
  String get send {
    late String id;

    switch (notifyCode) {
      case CommandCode.ic:
        id = '1';
        break;
      default:
        id = '0';
        break;
    }

    return '{NC:$id}';
  }
}

/// Feedback Command

class ErrorCommand extends FeedbackCommand {
  final dynamic value;

  ErrorCommand({required CommandCode commandCode, required errorCode, this.value})
      : super(commandCode, status: InsightStatus(code: errorCode));
}

class FeedbackStartCommand extends FeedbackCommand {
  final bool value;

  const FeedbackStartCommand({required this.value, InsightStatus? status})
      : super(CommandCode.st, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackResetCommand extends FeedbackCommand {
  final bool value;

  const FeedbackResetCommand({required this.value, InsightStatus? status})
      : super(CommandCode.st, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackChargeCommand extends FeedbackCommand {
  final bool value;

  const FeedbackChargeCommand({required this.value, InsightStatus? status})
      : super(CommandCode.ch, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackDrumCommand extends FeedbackCommand {
  final bool value;

  const FeedbackDrumCommand({required this.value, InsightStatus? status})
      : super(CommandCode.dr, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackCrackCommand extends FeedbackCommand {
  final bool value;

  const FeedbackCrackCommand({required this.value, InsightStatus? status})
      : super(CommandCode.cr, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackDryEndCommand extends FeedbackCommand {
  final bool value;

  const FeedbackDryEndCommand({required this.value, InsightStatus? status})
      : super(CommandCode.de, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackDischargeCommand extends FeedbackCommand {
  final bool value;

  const FeedbackDischargeCommand({required this.value, InsightStatus? status})
      : super(CommandCode.dc, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackCoolingCommand extends FeedbackCommand {
  final bool value;

  const FeedbackCoolingCommand({required this.value, InsightStatus? status})
      : super(CommandCode.cl, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackHeaterCommand extends FeedbackCommand {
  final int value;

  const FeedbackHeaterCommand({required this.value, InsightStatus? status})
      : super(CommandCode.ht, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackAirflowCommand extends FeedbackCommand {
  final int value;

  const FeedbackAirflowCommand({required this.value, InsightStatus? status})
      : super(CommandCode.af, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackInitialConditionCommand extends FeedbackCommand {
  final bool value;

  const FeedbackInitialConditionCommand({required this.value, InsightStatus? status})
      : super(CommandCode.ic, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, value];
}

class FeedbackModeCommand extends FeedbackCommand {
  final ModeType type;

  const FeedbackModeCommand({required this.type, InsightStatus? status})
      : super(CommandCode.md, status: status ?? const InsightStatus());

  @override
  List<Object?> get props => [...super.props, type];
}

class FeedbackAutoCommand extends FeedbackCommand {
  const FeedbackAutoCommand({InsightStatus? status})
      : super(CommandCode.at, status: status ?? const InsightStatus());
}

class FeedbackNotifyCommand extends FeedbackCommand {
  final dynamic data;

  const FeedbackNotifyCommand({required this.data, InsightStatus? status}) : super(CommandCode.nc);
}
