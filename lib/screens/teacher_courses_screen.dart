import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/teacher_course.dart';
import '../services/teacher_session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/soft_card.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({
    super.key,
    required this.coursesFuture,
    required this.onSessionStarted,
  });

  final Future<List<TeacherCourse>> coursesFuture;
  final ValueChanged<int> onSessionStarted;

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  final _sessionService = const TeacherSessionService();
  int? _selectedCourseId;
  bool _gpsEnabled = false;
  final _radiusController = TextEditingController(text: '100');
  bool _starting = false;

  @override
  void dispose() {
    _radiusController.dispose();
    super.dispose();
  }

  // Sınıf içi GPS doğrulaması isteğe bağlı — kapalıysa lat/lng hiç gönderilmez
  // (bkz. TeacherSessionService.startSession, backend GPS'siz oturumları da kabul
  // ediyor). Konum alınamazsa kullanıcıya net bir hata gösterilir; öğrenci
  // tarafındaki "sessizce null'a düş" davranışının aksine burada hoca bilinçli
  // olarak GPS'i açtığı için başarısızlık sessiz geçilmemeli.
  Future<({double lat, double lng})?> _readLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Konum servisi kapalı. Lütfen açıp tekrar deneyin.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni verilmedi.');
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return (lat: position.latitude, lng: position.longitude);
  }

  Future<void> _startSession() async {
    final courseId = _selectedCourseId;
    if (courseId == null || _starting) return;
    setState(() => _starting = true);

    try {
      double? lat;
      double? lng;
      int? radius;
      if (_gpsEnabled) {
        final location = await _readLocation();
        lat = location?.lat;
        lng = location?.lng;
        radius = int.tryParse(_radiusController.text) ?? 100;
      }
      final sessionId = await _sessionService.startSession(
        courseId: courseId,
        lat: lat,
        lng: lng,
        radius: radius,
      );
      widget.onSessionStarted(sessionId);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yoklama başlatılamadı: $error')));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Derslerim')),
      body: SafeArea(
        child: FutureBuilder<List<TeacherCourse>>(
          future: widget.coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SoftCard(
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final courses = snapshot.data ?? const <TeacherCourse>[];

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  children: [
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yeni yoklama başlat',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedCourseId,
                            decoration: const InputDecoration(
                              labelText: 'Ders',
                            ),
                            items: [
                              for (final course in courses)
                                DropdownMenuItem(
                                  value: course.id,
                                  child: Text(course.name),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedCourseId = value),
                          ),
                          const SizedBox(height: 12),
                          Material(
                            type: MaterialType.transparency,
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Konum doğrulaması iste'),
                              value: _gpsEnabled,
                              onChanged: (value) =>
                                  setState(() => _gpsEnabled = value),
                            ),
                          ),
                          if (_gpsEnabled)
                            TextField(
                              controller: _radiusController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'İzin verilen mesafe (metre)',
                              ),
                            ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: 'Yoklamayı Başlat',
                            icon: Icons.play_arrow_rounded,
                            onPressed: _selectedCourseId == null
                                ? null
                                : _startSession,
                            enabled: _selectedCourseId != null,
                            loading: _starting,
                            loadingLabel: 'Başlatılıyor...',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (courses.isEmpty)
                      SoftCard(
                        child: Text(
                          'Henüz size tanımlı bir ders bulunmuyor.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.mutedOf(context)),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (final course in courses) ...[
                            SoftCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      course.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    '${course.enrolled} öğrenci',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.mutedOf(context),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
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
