import 'package:webak/core/config/database_config.dart';
import 'package:webak/features/reports/domain/models/report_model.dart';
import 'package:webak/features/reports/domain/repositories/report_repository.dart';
import 'package:webak/features/reports/data/services/report_service.dart';

class ReportRepositorySQLiteImpl implements ReportRepository {
  final ReportService _reportService;

  ReportRepositorySQLiteImpl() : _reportService = ReportService(DatabaseConfig.instance.databaseHelper);

  @override
  Future<List<ReportModel>> getReports() async {
    final userId = DatabaseConfig.instance.currentUserId;
    if (userId == null) return [];
    
    return _reportService.getReportsByUserId(userId);
  }

  @override
  Future<ReportModel?> getReportById(String id) async {
    return _reportService.getReportById(id);
  }

  @override
  Future<ReportModel> createReport(ReportModel report) async {
    final userId = DatabaseConfig.instance.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final reportWithUserId = report.copyWith(userId: userId);
    return _reportService.createReport(reportWithUserId);
  }

  @override
  Future<ReportModel> updateReport(ReportModel report) async {
    return _reportService.updateReport(report);
  }

  @override
  Future<void> deleteReport(String id) async {
    await _reportService.deleteReport(id);
  }

  @override
  Future<List<ReportModel>> getReportsByStatus(String status) async {
    final userId = DatabaseConfig.instance.currentUserId;
    if (userId == null) return [];
    
    return _reportService.getReportsByStatus(status, userId);
  }

  @override
  Future<List<ReportModel>> getReportsByType(String type) async {
    final userId = DatabaseConfig.instance.currentUserId;
    if (userId == null) return [];
    
    return _reportService.getReportsByType(type, userId);
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    return _reportService.getAllReports();
  }

  @override
  Future<List<ReportModel>> getReportsByDateRange(DateTime start, DateTime end) async {
    final userId = DatabaseConfig.instance.currentUserId;
    if (userId == null) return [];
    
    return _reportService.getReportsByDateRange(start, end, userId);
  }

  @override
  Stream<List<ReportModel>> reportsStream() {
    // For now, return an empty stream
    // In a real implementation, you might want to use a StreamController
    return Stream.value([]);
  }
}