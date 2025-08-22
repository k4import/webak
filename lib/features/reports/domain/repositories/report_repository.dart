import 'package:webak/features/reports/domain/models/report_model.dart';

abstract class ReportRepository {
  /// Get all reports for the current user
  Future<List<ReportModel>> getReports();
  
  /// Get a specific report by ID
  Future<ReportModel?> getReportById(String id);
  
  /// Create a new report
  Future<ReportModel> createReport(ReportModel report);
  
  /// Update an existing report
  Future<ReportModel> updateReport(ReportModel report);
  
  /// Delete a report
  Future<void> deleteReport(String id);
  

  
  /// Get reports by type (daily, weekly, monthly, custom)
  Future<List<ReportModel>> getReportsByType(String type);
  
  /// Get reports for a specific date range
  Future<List<ReportModel>> getReportsByDateRange(DateTime start, DateTime end);
  
  /// Stream of reports for real-time updates
  Stream<List<ReportModel>> reportsStream();
}