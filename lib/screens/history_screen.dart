import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../theme/app_theme.dart';
import '../widgets/attendance_record_tile.dart';
import '../widgets/soft_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.historyFuture,
    required this.onRefresh,
  });

  final Future<List<AttendanceRecord>> historyFuture;
  final VoidCallback onRefresh;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Yoklamalar'),
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
          key: ValueKey(widget.historyFuture),
          future: widget.historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _HistoryError(
                message: snapshot.error.toString(),
                onRetry: widget.onRefresh,
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
              onRefresh: () async => widget.onRefresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                children: [
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Tümü')),
                      ButtonSegment(value: 1, label: Text('Katıldım')),
                      ButtonSegment(value: 2, label: Text('Katılmadım')),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (value) =>
                        setState(() => _filter = value.first),
                  ),
                  const SizedBox(height: 16),
                  // Filtre değiştikçe (_filter) kayıt sayısı, historyFuture'ın kendisi
                  // değişmeden değişir — bu listeyi doğrudan ListView'ın children'ına
                  // koymak, Flutter'ın sliver child reconciliation'ında çökmeye yol
                  // açıyordu (bkz. dashboard'daki aynı düzeltme notu). Tek bir Column
                  // içine alarak ListView'ın kendi eleman sayısını sabit tutuyoruz.
                  if (records.isEmpty)
                    const _EmptyHistory()
                  else
                    Column(
                      children: [
                        for (final record in records) ...[
                          AttendanceRecordTile(record: record),
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
