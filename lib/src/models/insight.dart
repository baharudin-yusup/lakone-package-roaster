import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'command.dart';
part 'control.dart';
part 'environment.dart';
part 'record.dart';

enum HeaderType { record, command, recordWithRor, unknown }

abstract class Insight extends Equatable {
  final InsightStatus status;

  const Insight({this.status = const InsightStatus()});

  @override
  @mustCallSuper
  List<Object?> get props => [status];

  bool get isError => status.code < 0;
}

class InsightStatus {
  final int code;
  String get message {
    switch (code) {
      case 1:
        return 'waiting-for-success';
      case 0:
        return 'success';
      case -1:
        return 'invalid-value-from-roaster';
      case -3:
        return 'header-data-unknown';
      default:
        return 'unknown-status';
    }
  }

  const InsightStatus({this.code = 0});
}

class UnknownInsight extends Insight {
  final String header;

  const UnknownInsight(this.header);
}
