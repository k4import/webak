import 'package:webak/features/reports/domain/models/report_model.dart';
import 'package:webak/features/reports/domain/repositories/report_repository.dart';

class UpdateReportUseCase {
  final ReportRepository _reportRepository;

  UpdateReportUseCase(this._reportRepository);

  Future<ReportModel> call(ReportModel report) async {
    return await _reportRepository.updateReport(report);
  }
}