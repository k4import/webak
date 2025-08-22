import 'package:webak/features/reports/domain/models/report_model.dart';
import 'package:webak/features/reports/domain/repositories/report_repository.dart';

class CreateReportUseCase {
  final ReportRepository _reportRepository;

  CreateReportUseCase(this._reportRepository);

  Future<ReportModel> call(ReportModel report) async {
    return await _reportRepository.createReport(report);
  }
}