import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/student.dart';
import '../services/attendance_history_service.dart';
import '../theme/app_theme.dart';
import 'qr_scan_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key, required this.student});

  final Student student;

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _historyService = const AttendanceHistoryService();
  late Future<List<AttendanceRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final nameParts = widget.student.name.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isEmpty ? '' : nameParts.first;
    final greetingName = firstName.isEmpty ? 'Öğrenci' : firstName;
    final avatarLetter = greetingName.characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: Stack(
        children: [
          const Positioned.fill(child: _DashboardBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 380
                    ? 18.0
                    : 24.0;

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    28,
                    horizontalPadding,
                    24,
                  ),
                  children: [
                    _DashboardHeader(
                      name: greetingName,
                      avatarLetter: avatarLetter,
                    ),
                    const SizedBox(height: 28),
                    const _TodayLessonCard(),
                    const SizedBox(height: 16),
                    _AttendanceStatusCard(historyFuture: _historyFuture),
                    const SizedBox(height: 22),
                    _QrAttendanceButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                QrScanScreen(student: widget.student),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    _LastAttendanceCard(historyFuture: _historyFuture),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.name, required this.avatarLetter});

  final String name;
  final String avatarLetter;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: AppColors.isDark(context)
          ? AppColors.darkText
          : const Color(0xff07351f),
      fontWeight: FontWeight.w900,
      height: 1.12,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merhaba, $name', style: titleStyle),
              const SizedBox(height: 12),
              Text(
                'Bugünkü yoklama durumunu buradan takip edebilirsin.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedOf(context),
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _StudentAvatar(letter: avatarLetter),
      ],
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.mintOf(context).withValues(alpha: 0.72),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        letter,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TodayLessonCard extends StatelessWidget {
  const _TodayLessonCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardTitle(
                  icon: Icons.calendar_month_rounded,
                  title: 'Bugünkü Ders',
                ),
                const SizedBox(height: 22),
                Text(
                  'Bugünkü ders bilgisi bulunmuyor.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 21,
                    height: 1.18,
                    color: AppColors.mutedOf(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const _SoftIconBadge(icon: Icons.menu_book_rounded, size: 86),
        ],
      ),
    );
  }
}

class _AttendanceStatusCard extends StatelessWidget {
  const _AttendanceStatusCard({required this.historyFuture});

  final Future<List<AttendanceRecord>> historyFuture;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardTitle(
                  icon: Icons.verified_user_outlined,
                  title: 'Yoklama Durumu',
                ),
                const SizedBox(height: 18),
                FutureBuilder<List<AttendanceRecord>>(
                  future: historyFuture,
                  builder: (context, snapshot) {
                    final latest = _latestRecord(snapshot.data);
                    final text = latest == null
                        ? 'Henüz yoklama kaydı bulunmuyor'
                        : latest.joined
                        ? 'Son yoklama başarılı'
                        : 'Son yoklama katılımı yok';

                    return Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? 'Yoklama durumu yükleniyor'
                          : text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.mutedOf(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FutureBuilder<List<AttendanceRecord>>(
            future: historyFuture,
            builder: (context, snapshot) {
              final latest = _latestRecord(snapshot.data);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _StatusPill(
                  label: 'Yükleniyor',
                  foreground: AppColors.amber,
                );
              }
              if (latest?.joined == true) {
                return const _StatusPill(
                  label: 'Katıldı',
                  foreground: AppColors.primary,
                  icon: Icons.check_rounded,
                );
              }
              return const _StatusPill(
                label: 'Beklemede',
                foreground: AppColors.amber,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QrAttendanceButton extends StatelessWidget {
  const _QrAttendanceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff07924f), Color(0xff2fc36f)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: const SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 32),
                SizedBox(width: 14),
                Flexible(
                  child: Text(
                    'QR ile Yoklama Ver',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LastAttendanceCard extends StatelessWidget {
  const _LastAttendanceCard({required this.historyFuture});

  final Future<List<AttendanceRecord>> historyFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttendanceRecord>>(
      future: historyFuture,
      builder: (context, snapshot) {
        final latest = _latestRecord(snapshot.data);

        return _DashboardCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardTitle(
                      icon: Icons.access_time_rounded,
                      title: 'Son Yoklama',
                    ),
                    const SizedBox(height: 22),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      Text(
                        'Yükleniyor...',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.mutedOf(context),
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    else if (latest == null)
                      Text(
                        'Henüz yoklama kaydı bulunmuyor.',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.mutedOf(context),
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    else ...[
                      Text(
                        latest.lesson,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 24,
                              height: 1.1,
                              color: AppColors.textOf(context),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _StatusPill(
                        label: latest.joined ? 'Katıldı' : 'Katılmadı',
                        foreground: latest.joined
                            ? AppColors.primary
                            : AppColors.danger,
                        icon: latest.joined
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                      ),
                      const SizedBox(height: 16),
                      _InfoLine(
                        icon: Icons.calendar_today_rounded,
                        text: _recordDateText(latest),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const _SoftIconBadge(icon: Icons.check_circle_outline_rounded),
            ],
          ),
        );
      },
    );
  }
}

AttendanceRecord? _latestRecord(List<AttendanceRecord>? records) {
  if (records == null || records.isEmpty) return null;
  return records.first;
}

String _recordDateText(AttendanceRecord record) {
  final parts = [
    if (record.date.trim().isNotEmpty) record.date.trim(),
    if (record.time.trim().isNotEmpty) record.time.trim(),
  ];
  return parts.isEmpty ? 'Tarih bilgisi yok' : parts.join(' • ');
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardOf(
          context,
        ).withValues(alpha: isDark ? 0.95 : 0.98),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.mutedOf(context), size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.mutedOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.foreground, this.icon});

  final String label;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isPositive = foreground == AppColors.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 14 : 10, 8, 14, 8),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.mintOf(context).withValues(alpha: 0.76)
            : AppColors.amberSoftOf(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftIconBadge extends StatelessWidget {
  const _SoftIconBadge({required this.icon, this.size = 76});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.mintOf(context).withValues(alpha: 0.68),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary, size: size * 0.42),
    );
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceOf(context),
      child: CustomPaint(
        painter: _DashboardBackgroundPainter(isDark: AppColors.isDark(context)),
      ),
    );
  }
}

class _DashboardBackgroundPainter extends CustomPainter {
  const _DashboardBackgroundPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final primary = isDark ? AppColors.accent : AppColors.primary;
    final linePaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.08 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final softFill = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.07 : 0.08)
      ..style = PaintingStyle.fill;

    final halo = Paint()
      ..shader =
          RadialGradient(
            colors: [
              primary.withValues(alpha: isDark ? 0.14 : 0.09),
              primary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.48, size.height * 0.16),
              radius: size.width * 0.48,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.16),
      size.width * 0.48,
      halo,
    );

    final hill = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.1,
        size.width,
        size.height * 0.22,
      )
      ..lineTo(size.width, size.height * 0.32)
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.24,
        0,
        size.height * 0.28,
      )
      ..close();
    canvas.drawPath(hill, softFill);

    _drawSchool(canvas, size, linePaint);
    _drawTrees(canvas, size, softFill);
    _drawDots(canvas, Offset(size.width * 0.83, size.height * 0.08), primary);
  }

  void _drawSchool(Canvas canvas, Size size, Paint paint) {
    final left = size.width * 0.08;
    final top = size.height * 0.09;
    final width = size.width * 0.24;
    final height = size.height * 0.12;

    final roof = Path()
      ..moveTo(left, top + height * 0.34)
      ..lineTo(left + width * 0.5, top)
      ..lineTo(left + width, top + height * 0.34);
    canvas.drawPath(roof, paint);
    canvas.drawRect(
      Rect.fromLTWH(
        left + width * 0.12,
        top + height * 0.34,
        width * 0.76,
        height * 0.5,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(left + width * 0.5, top),
      Offset(left + width * 0.5, top - height * 0.22),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left + width * 0.5, top - height * 0.22)
        ..lineTo(left + width * 0.65, top - height * 0.18)
        ..lineTo(left + width * 0.5, top - height * 0.14),
      paint,
    );

    for (var i = 0; i < 3; i++) {
      final x = left + width * (0.25 + i * 0.2);
      canvas.drawLine(
        Offset(x, top + height * 0.4),
        Offset(x, top + height * 0.82),
        paint,
      );
    }
  }

  void _drawTrees(Canvas canvas, Size size, Paint paint) {
    final baseY = size.height * 0.26;
    final xs = [size.width * 0.84, size.width * 0.92];

    for (final x in xs) {
      final tree = Path()
        ..moveTo(x, baseY - 64)
        ..lineTo(x - 22, baseY - 18)
        ..lineTo(x - 9, baseY - 18)
        ..lineTo(x - 27, baseY + 22)
        ..lineTo(x + 27, baseY + 22)
        ..lineTo(x + 9, baseY - 18)
        ..lineTo(x + 22, baseY - 18)
        ..close();
      canvas.drawPath(tree, paint);
    }
  }

  void _drawDots(Canvas canvas, Offset origin, Color color) {
    final dotPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.22 : 0.3);

    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 4; column++) {
        canvas.drawCircle(
          origin + Offset(column * 17, row * 17),
          2.1,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardBackgroundPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
