import 'package:webak/features/reports/domain/repositories/report_repository.dart';

class DeleteReportUseCase {
  final ReportRepository _reportRepository;

  DeleteReportUseCase(this._reportRepository);

  Future<void> call(String id) async {
    await _reportRepository.deleteReport(id);
  }
}