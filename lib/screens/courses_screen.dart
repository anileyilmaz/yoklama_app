import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/course_progress.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';
import 'course_sessions_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({
    super.key,
    required this.coursesFuture,
    required this.historyFuture,
    required this.onRefresh,
  });

  final Future<List<CourseProgress>> coursesFuture;
  final Future<List<AttendanceRecord>> historyFuture;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Derslerim')),
      body: SafeArea(
        child: FutureBuilder<List<CourseProgress>>(
          key: ValueKey(coursesFuture),
          future: coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _CoursesError(
                message: snapshot.error.toString(),
                onRetry: onRefresh,
              );
            }

            final courses = snapshot.data ?? const <CourseProgress>[];
            final atRiskCount = courses.where((c) => c.atRisk).length;

            return RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                children: [
                  atRiskCount > 0
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _RiskSummaryBanner(count: atRiskCount),
                        )
                      : const SizedBox.shrink(),
                  if (courses.isEmpty)
                    const _EmptyCourses()
                  else
                    Column(
                      children: [
                        for (final course in courses) ...[
                          _CourseTile(
                            course: course,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CourseSessionsScreen(
                                  courseId: course.courseId,
                                  courseName: course.course,
                                  historyFuture: historyFuture,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoursesError extends StatelessWidget {
  const _CoursesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SoftCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Text(
        'Henüz kayıtlı olduğun bir ders bulunmuyor.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedOf(context)),
      ),
    );
  }
}

class _RiskSummaryBanner extends StatelessWidget {
  const _RiskSummaryBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSoftOf(context),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1
                  ? '1 derste yoklama sınırına yaklaştın.'
                  : '$count derste yoklama sınırına yaklaştın.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course, required this.onTap});

  final CourseProgress course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasSessions = course.totalSessions > 0;
    final percent = course.percent ?? 0;
    final progressColor = course.atRisk
        ? AppColors.danger
        : AppColors.brandOf(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: SoftCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.course,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (hasSessions)
                        Text(
                          '%$percent',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        Text(
                          'Oturum yok',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedOf(context),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: hasSessions ? percent / 100 : 0,
                      minHeight: 7,
                      backgroundColor: AppColors.lineOf(context),
                      color: progressColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedOf(context),
            ),
          ],
        ),
      ),
    );
  }
}
