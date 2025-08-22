part of 'report_cubit.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<ReportModel> reports;

  const ReportLoaded(this.reports);

  @override
  List<Object> get props => [reports];
}

class ReportDetailLoaded extends ReportState {
  final ReportModel report;

  const ReportDetailLoaded(this.report);

  @override
  List<Object> get props => [report];
}

class ReportCreated extends ReportState {
  final ReportModel report;

  const ReportCreated(this.report);

  @override
  List<Object> get props => [report];
}

class ReportUpdated extends ReportState {
  final ReportModel report;

  const ReportUpdated(this.report);

  @override
  List<Object> get props => [report];
}

class ReportDeleted extends ReportState {
  final String id;

  const ReportDeleted(this.id);

  @override
  List<Object> get props => [id];
}



class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object> get props => [message];
}