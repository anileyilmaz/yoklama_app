import 'package:flutter/material.dart';

import '../models/attendance_report.dart';
import '../models/teacher_course.dart';
import '../services/attendance_report_service.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';

class TeacherReportScreen extends StatefulWidget {
  const TeacherReportScreen({super.key, required this.coursesFuture});

  final Future<List<TeacherCourse>> coursesFuture;

  @override
  State<TeacherReportScreen> createState() => _TeacherReportScreenState();
}

class _TeacherReportScreenState extends State<TeacherReportScreen> {
  final _reportService = const AttendanceReportService();
  int? _selectedCourseId;
  Future<AttendanceReport>? _reportFuture;

  void _selectCourse(int? courseId) {
    setState(() {
      _selectedCourseId = courseId;
      _reportFuture = courseId == null
          ? null
          : _reportService.fetchReport(courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devamsızlık Raporu')),
      body: SafeArea(
        child: FutureBuilder<List<TeacherCourse>>(
          future: widget.coursesFuture,
          builder: (context, snapshot) {
            final courses = snapshot.data ?? const <TeacherCourse>[];

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCourseId,
                      decoration: const InputDecoration(labelText: 'Ders'),
                      items: [
                        for (final course in courses)
                          DropdownMenuItem(
                            value: course.id,
                            child: Text(course.name),
                          ),
                      ],
                      onChanged: _selectCourse,
                    ),
                    const SizedBox(height: 18),
                    if (_reportFuture != null)
                      FutureBuilder<AttendanceReport>(
                        future: _reportFuture,
                        builder: (context, reportSnapshot) {
                          if (reportSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (reportSnapshot.hasError) {
                            return SoftCard(
                              child: Text('${reportSnapshot.error}'),
                            );
                          }
                          final report = reportSnapshot.data;
                          if (report == null || report.students.isEmpty) {
                            return const SoftCard(
                              child: Text('Bu derse kayıtlı öğrenci yok.'),
                            );
                          }
                          return Column(
                            children: [
                              for (final row in report.students) ...[
                                SoftCard(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(row.name),
                                            Text(
                                              row.studentNumber,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppColors.mutedOf(
                                                      context,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${row.attended} / ${report.totalSessions}',
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        row.percent == null
                                            ? '—'
                                            : '%${row.percent}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: row.atRisk
                                              ? AppColors.danger
                                              : AppColors.textOf(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
