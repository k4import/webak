import 'package:uuid/uuid.dart';
import 'package:webak/core/database/database_helper.dart';
import 'package:webak/features/reports/domain/models/report_model.dart';

class ReportService {
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();
  final String _tableName = 'reports';

  ReportService(this._databaseHelper);

  Future<List<ReportModel>> getReports() async {
    final db = await _databaseHelper.database;
    final reports = await db.query('reports');
    return reports.map((report) => ReportModel.fromSQLite(report)).toList();
  }

  Future<ReportModel?> getReportById(String id) async {
    final db = await _databaseHelper.database;
    final reports = await db.query('reports', where: 'id = ?', whereArgs: [id]);
    if (reports.isEmpty) return null;
    return ReportModel.fromSQLite(reports.first);
  }

  Future<List<ReportModel>> getReportsByUserId(String userId) async {
    final db = await _databaseHelper.database;
    final reports = await db.query('reports', where: 'user_id = ?', whereArgs: [userId]);
    return reports.map((report) => ReportModel.fromSQLite(report)).toList();
  }



  Future<ReportModel> createReport(ReportModel report) async {
    final db = await _databaseHelper.database;
    final reportWithId = report.copyWith(id: _uuid.v4());
    final reportMap = reportWithId.toSQLite();
    await db.insert('reports', reportMap);
    return reportWithId;
  }

  Future<ReportModel> updateReport(ReportModel report) async {
    final db = await _databaseHelper.database;
    final reportMap = report.toSQLite();
    await db.update('reports', reportMap, where: 'id = ?', whereArgs: [report.id]);
    return report;
  }

  Future<void> deleteReport(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ReportModel>> getReportsByDateRange(DateTime startDate, DateTime endDate, String userId) async {
    final db = await _databaseHelper.database;
    final reports = await db.query(
      _tableName,
      where: 'start_date >= ? AND end_date <= ? AND user_id = ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String(), userId],
    );
    return reports.map((report) => ReportModel.fromSQLite(report)).toList();
  }

  Future<List<ReportModel>> getReportsByStatus(String status, String userId) async {
    final db = await _databaseHelper.database;
    final reports = await db.query(
      _tableName,
      where: 'status = ? AND user_id = ?',
      whereArgs: [status, userId],
      orderBy: 'created_at DESC',
    );
    return reports.map((report) => ReportModel.fromSQLite(report)).toList();
  }

  Future<List<ReportModel>> getReportsByType(String type, String userId) async {
    final db = await _databaseHelper.database;
    final reports = await db.query(
      _tableName,
      where: 'type = ? AND user_id = ?',
      whereArgs: [type, userId],
      orderBy: 'created_at DESC',
    );
    return reports.map((report) => ReportModel.fromSQLite(report)).toList();
  }



  Future<List<ReportModel>> getAllReports() async {
    final db = await _databaseHelper.database;
    final reports = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );
    return reports.map((report) => ReportModel.fromSQLite(report)).toList();
  }

}