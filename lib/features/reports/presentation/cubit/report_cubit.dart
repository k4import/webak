import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webak/features/reports/domain/models/report_model.dart';
import 'package:webak/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:webak/features/reports/domain/usecases/delete_report_usecase.dart';

import 'package:webak/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:webak/features/reports/domain/usecases/update_report_usecase.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final CreateReportUseCase _createReportUseCase;
  final DeleteReportUseCase _deleteReportUseCase;

  final GetReportsUseCase _getReportsUseCase;
  final UpdateReportUseCase _updateReportUseCase;

  ReportCubit({
    required CreateReportUseCase createReportUseCase,
    required DeleteReportUseCase deleteReportUseCase,

    required GetReportsUseCase getReportsUseCase,
    required UpdateReportUseCase updateReportUseCase,
  })
      : _createReportUseCase = createReportUseCase,
        _deleteReportUseCase = deleteReportUseCase,

        _getReportsUseCase = getReportsUseCase,
        _updateReportUseCase = updateReportUseCase,
        super(ReportInitial());

  Future<void> loadReports() async {
    emit(ReportLoading());
    try {
      final reports = await _getReportsUseCase();
      emit(ReportLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> loadReportsByType(String type) async {
    emit(ReportLoading());
    try {
      final reports = await _getReportsUseCase.getReportsByType(type);
      emit(ReportLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> loadReportsByDateRange(DateTime start, DateTime end) async {
    emit(ReportLoading());
    try {
      final reports = await _getReportsUseCase.getReportsByDateRange(start, end);
      emit(ReportLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> createReport(ReportModel report) async {
    emit(ReportLoading());
    try {
      final createdReport = await _createReportUseCase(report);
      emit(ReportCreated(createdReport));
      loadReports(); // Refresh the reports list
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }



  Future<void> updateReport(ReportModel report) async {
    emit(ReportLoading());
    try {
      final updatedReport = await _updateReportUseCase(report);
      emit(ReportUpdated(updatedReport));
      loadReports(); // Refresh the reports list
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> deleteReport(String id) async {
    emit(ReportLoading());
    try {
      await _deleteReportUseCase(id);
      emit(ReportDeleted(id));
      loadReports(); // Refresh the reports list
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> getReportById(String id) async {
    emit(ReportLoading());
    try {
      final report = await _getReportsUseCase.getReportById(id);
      if (report != null) {
        emit(ReportDetailLoaded(report));
      } else {
        emit(const ReportError('التقرير غير موجود'));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}