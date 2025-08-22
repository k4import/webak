import 'package:webak/features/reports/domain/models/report_model.dart';
import 'package:webak/features/reports/domain/repositories/report_repository.dart';

class GetReportsUseCase {
  final ReportRepository _reportRepository;

  GetReportsUseCase(this._reportRepository);

  Future<List<ReportModel>> call() async {
    return await _reportRepository.getReports();
  }
  
  Future<ReportModel?> getReportById(String id) async {
    return await _reportRepository.getReportById(id);
  }
  
  Future<List<ReportModel>> getReportsByType(String type) async {
    return await _reportRepository.getReportsByType(type);
  }
  
  Future<List<ReportModel>> getReportsByDateRange(DateTime start, DateTime end) async {
    return await _reportRepository.getReportsByDateRange(start, end);
  }
  
  Stream<List<ReportModel>> reportsStream() {
    return _reportRepository.reportsStream();
  }
}