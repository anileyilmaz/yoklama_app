import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../services/attendance_history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = const AttendanceHistoryService();
  int _filter = 0;
  late Future<List<AttendanceRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _historyService.fetchHistory();
  }

  void _reload() {
    setState(() => _recordsFuture = _historyService.fetchHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gecmis Yoklamalar'),
        actions: [
          IconButton(
            tooltip: 'Filtrele',
            onPressed: () => setState(() => _filter = (_filter + 1) % 3),
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<AttendanceRecord>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _HistoryError(
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }

            final records = (snapshot.data ?? const <AttendanceRecord>[]).where(
              (record) {
                if (_filter == 1) return record.joined;
                if (_filter == 2) return !record.joined;
                return true;
              },
            ).toList();

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                children: [
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Tumu')),
                      ButtonSegment(value: 1, label: Text('Katildim')),
                      ButtonSegment(value: 2, label: Text('Katilmadim')),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (value) =>
                        setState(() => _filter = value.first),
                  ),
                  const SizedBox(height: 16),
                  if (records.isEmpty)
                    const _EmptyHistory()
                  else
                    for (final record in records) ...[
                      _RecordTile(record: record),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Text(
        'Henüz yoklama kaydı bulunmuyor.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedOf(context)),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final statusColor = record.joined ? AppColors.primary : AppColors.danger;
    final statusBg = record.joined
        ? AppColors.mintOf(context)
        : AppColors.dangerSoftOf(context);

    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              record.joined
                  ? Icons.event_available_outlined
                  : Icons.event_busy_outlined,
              color: statusColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.lesson,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.date} - ${record.time}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  record.joined ? Icons.check_rounded : Icons.close_rounded,
                  color: statusColor,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  record.joined ? 'Katildim' : 'Katilmadim',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
