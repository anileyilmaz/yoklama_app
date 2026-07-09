import 'package:flutter/material.dart';

import '../models/active_session.dart';
import '../models/attendance_record.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'qr_scan_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({
    super.key,
    required this.student,
    required this.historyFuture,
    required this.onAttendanceUpdated,
    this.activeSessions = const [],
  });

  final Student student;
  final Future<List<AttendanceRecord>> historyFuture;
  final List<ActiveSession> activeSessions;

  /// QR akışından dönüldüğünde (`HomeShell`'in paylaşılan geçmişini) yeniden
  /// çekmesi için çağrılır — Dashboard ve Geçmiş sekmesi aynı veriyi görsün diye.
  final VoidCallback onAttendanceUpdated;

  Future<void> _openScanner(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QrScanScreen()));
    if (!context.mounted) return;
    onAttendanceUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final nameParts = student.name.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isEmpty ? '' : nameParts.first;
    final greetingName = firstName.isEmpty ? 'Öğrenci' : firstName;
    final avatarLetter = greetingName.characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 18.0 : 24.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                28,
                horizontalPadding,
                24,
              ),
              children: [
                _DashboardHeader(name: greetingName, avatarLetter: avatarLetter),
                const SizedBox(height: 24),
                // ListView'in children listesi HER zaman sabit sayida ve sabit
                // sirada eleman icermeli. Aktif oturum sayisina gore bu listeye
                // kosullu eleman eklenip cikarilirsa, ValueKey kullanan diger
                // kardeslerin index'i kaydigi icin Flutter'in sliver child
                // reconciliation'i coker (RenderSliverList assertion). Bu yuzden
                // banner alani HER zaman tek bir sabit widget olarak burada
                // durur, icerde bossa SizedBox.shrink() doner.
                _LiveSessionBannerArea(
                  sessions: activeSessions,
                  onTap: () => _openScanner(context),
                ),
                _AttendanceStatusCard(
                  key: ValueKey('attendanceStatus-${identityHashCode(historyFuture)}'),
                  historyFuture: historyFuture,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'QR ile Yoklama Ver',
                  icon: Icons.qr_code_2_rounded,
                  height: 58,
                  fontSize: 16,
                  onPressed: () => _openScanner(context),
                ),
                const SizedBox(height: 20),
                _LastAttendanceCard(
                  key: ValueKey('lastAttendance-${identityHashCode(historyFuture)}'),
                  historyFuture: historyFuture,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LiveSessionBannerArea extends StatelessWidget {
  const _LiveSessionBannerArea({required this.sessions, required this.onTap});

  final List<ActiveSession> sessions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          for (final session in sessions) ...[
            _LiveSessionBanner(
              key: ValueKey(session.sessionId),
              session: session,
              onTap: onTap,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _LiveSessionBanner extends StatelessWidget {
  const _LiveSessionBanner({
    super.key,
    required this.session,
    required this.onTap,
  });

  final ActiveSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.brandOf(context),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Icon(
              Icons.wifi_tethering_rounded,
              color: AppColors.onBrandOf(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.courseName} için yoklama açık',
                    style: TextStyle(
                      color: AppColors.onBrandOf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Şimdi katıl',
                    style: TextStyle(
                      color: AppColors.onBrandOf(
                        context,
                      ).withValues(alpha: 0.82),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onBrandOf(context),
            ),
          ],
        ),
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
      color: AppColors.textOf(context),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merhaba, $name', style: titleStyle),
              const SizedBox(height: 10),
              Text(
                'Bugünkü yoklama durumunu buradan takip edebilirsin.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedOf(context),
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
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoftOf(context),
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.brandOf(context),
        ),
      ),
    );
  }
}

class _AttendanceStatusCard extends StatelessWidget {
  const _AttendanceStatusCard({super.key, required this.historyFuture});

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
                const SizedBox(height: 14),
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedOf(context),
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
                  tone: _PillTone.pending,
                );
              }
              if (latest?.joined == true) {
                return const _StatusPill(
                  label: 'Katıldı',
                  tone: _PillTone.positive,
                  icon: Icons.check_rounded,
                );
              }
              return const _StatusPill(
                label: 'Beklemede',
                tone: _PillTone.pending,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LastAttendanceCard extends StatelessWidget {
  const _LastAttendanceCard({super.key, required this.historyFuture});

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
                    const SizedBox(height: 18),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      Text(
                        'Yükleniyor...',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.mutedOf(context)),
                      )
                    else if (latest == null)
                      Text(
                        'Henüz yoklama kaydı bulunmuyor.',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.mutedOf(context)),
                      )
                    else ...[
                      Text(
                        latest.lesson,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      _StatusPill(
                        label: latest.joined ? 'Katıldı' : 'Katılmadı',
                        tone: latest.joined
                            ? _PillTone.positive
                            : _PillTone.negative,
                        icon: latest.joined
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                      ),
                      const SizedBox(height: 14),
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
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.lineOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textOf(
              context,
            ).withValues(alpha: AppColors.isDark(context) ? 0.14 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
    final brand = AppColors.brandOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: brand, size: 22),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: brand),
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
        Icon(icon, color: AppColors.mutedOf(context), size: 20),
        const SizedBox(width: 8),
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

enum _PillTone { positive, pending, negative }

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.tone, this.icon});

  final String label;
  final _PillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color foreground;
    final Color background;
    switch (tone) {
      case _PillTone.positive:
        foreground = AppColors.brandOf(context);
        background = AppColors.primarySoftOf(context);
      case _PillTone.pending:
        foreground = AppColors.mutedOf(context);
        background = AppColors.lineOf(context);
      case _PillTone.negative:
        foreground = AppColors.danger;
        background = AppColors.dangerSoftOf(context);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 14 : 10, 8, 14, 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftIconBadge extends StatelessWidget {
  const _SoftIconBadge({required this.icon});

  final IconData icon;
  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: AppColors.primarySoftOf(context),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.brandOf(context), size: _size * 0.42),
    );
  }
}
