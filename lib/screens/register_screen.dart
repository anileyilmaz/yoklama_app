import 'package:flutter/material.dart';

import '../models/department.dart';
import '../models/faculty.dart';
import '../services/register_service.dart';
import '../services/unified_login_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/domain_suffix_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/soft_card.dart';

/// Bölüm açılır listesindeki "Listede yok / elle yaz" seçeneğinin sentinel değeri —
/// gerçek bir bölüm adıyla asla çakışmaz.
const _manualDepartmentSentinel = '__manual__';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.registerService = const RegisterService(),
  });

  final RegisterService registerService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  List<Faculty> _faculties = [];
  int? _selectedFacultyId;
  bool _facultiesLoading = true;
  String? _facultiesError;

  List<Department> _departments = [];
  String? _selectedDepartmentName;
  bool _departmentsLoading = false;
  String? _departmentsError;
  bool _manualDepartmentEntry = false;

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  Future<void> _loadFaculties() async {
    setState(() {
      _facultiesLoading = true;
      _facultiesError = null;
    });
    try {
      final faculties = await widget.registerService.fetchFaculties();
      if (!mounted) return;
      setState(() => _faculties = faculties);
    } on RegisterException catch (error) {
      if (mounted) setState(() => _facultiesError = error.message);
    } on Object catch (error) {
      if (mounted) setState(() => _facultiesError = error.toString());
    }
    if (mounted) setState(() => _facultiesLoading = false);
  }

  void _onFacultyChanged(int? facultyId) {
    setState(() {
      _selectedFacultyId = facultyId;
      _selectedDepartmentName = null;
      _manualDepartmentEntry = false;
      _departmentController.clear();
      _departments = [];
      _departmentsError = null;
    });
    if (facultyId != null) _loadDepartments(facultyId);
  }

  Future<void> _loadDepartments(int facultyId) async {
    setState(() {
      _departmentsLoading = true;
      _departmentsError = null;
    });
    try {
      final departments = await widget.registerService.fetchDepartments(facultyId);
      if (!mounted) return;
      setState(() => _departments = departments);
    } on RegisterException catch (error) {
      if (mounted) setState(() => _departmentsError = error.message);
    } on Object catch (error) {
      if (mounted) setState(() => _departmentsError = error.toString());
    }
    if (mounted) setState(() => _departmentsLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: _submitted ? _buildPendingNotice(context) : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 380 ? 18.0 : 24.0;
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              24,
            ),
            child: Column(
              children: [
                const AppLogo(size: 68),
                const SizedBox(height: 24),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Öğrenci kaydı',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bilgilerini gönderdikten sonra yönetici onayı beklenecek.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.mutedOf(context)),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        enabled: !_submitting,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: TextFormField(
                              controller: _numberController,
                              enabled: !_submitting,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Öğrenci Numarası',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: _required,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: DomainSuffixField(
                              value: kStudentLoginDomain,
                              options: const [kStudentLoginDomain],
                              enabled: !_submitting,
                              onChanged: null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildFacultyField(),
                      const SizedBox(height: 14),
                      _buildDepartmentField(),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_submitting,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre (en az 6 karakter)',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Şifre en az 6 karakter olmalı';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !_submitting,
                        obscureText: _obscureConfirmPassword,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Şifre (tekrar)',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Kayıt Ol',
                        icon: Icons.how_to_reg_outlined,
                        onPressed: _submit,
                        enabled: !_submitting,
                        loading: _submitting,
                        loadingLabel: 'Gönderiliyor...',
                        height: 54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingNotice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 28),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Kaydınız alındı',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Yönetici onayından sonra bu öğrenci numarası ve şifreyle giriş yapabileceksiniz.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedOf(context)),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Girişe Dön',
            icon: Icons.login_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyField() {
    if (_facultiesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }
    if (_facultiesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_facultiesError!, style: TextStyle(color: AppColors.danger)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loadFaculties,
            child: const Text('Tekrar dene'),
          ),
        ],
      );
    }
    return DropdownButtonFormField<int>(
      initialValue: _selectedFacultyId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Fakülte',
        prefixIcon: Icon(Icons.account_balance_outlined),
      ),
      items: _faculties
          .map(
            (f) => DropdownMenuItem(
              value: f.id,
              child: Text(f.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: _submitting ? null : _onFacultyChanged,
      validator: (value) => value == null ? 'Fakülte seçimi zorunlu' : null,
    );
  }

  Widget _buildDepartmentField() {
    if (_selectedFacultyId == null) {
      return InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Bölüm',
          prefixIcon: Icon(Icons.school_outlined),
          enabled: false,
        ),
        child: Text(
          'Önce fakülte seçin',
          style: TextStyle(color: AppColors.mutedOf(context)),
        ),
      );
    }
    if (_departmentsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }
    if (_departmentsError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_departmentsError!, style: TextStyle(color: AppColors.danger)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _loadDepartments(_selectedFacultyId!),
            child: const Text('Tekrar dene'),
          ),
        ],
      );
    }
    if (_manualDepartmentEntry) {
      return TextFormField(
        controller: _departmentController,
        enabled: !_submitting,
        decoration: InputDecoration(
          labelText: 'Bölüm (elle yazın)',
          prefixIcon: const Icon(Icons.school_outlined),
          suffixIcon: TextButton(
            onPressed: _submitting
                ? null
                : () => setState(() {
                    _manualDepartmentEntry = false;
                    _departmentController.clear();
                  }),
            child: const Text('Listeden seç'),
          ),
        ),
        validator: _required,
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: _selectedDepartmentName,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Bölüm',
        prefixIcon: Icon(Icons.school_outlined),
      ),
      items: [
        ..._departments.map(
          (d) => DropdownMenuItem(
            value: d.name,
            child: Text(d.name, overflow: TextOverflow.ellipsis),
          ),
        ),
        const DropdownMenuItem(
          value: _manualDepartmentSentinel,
          child: Text('Listede yok / elle yaz'),
        ),
      ],
      onChanged: _submitting
          ? null
          : (value) => setState(() {
              if (value == _manualDepartmentSentinel) {
                _manualDepartmentEntry = true;
                _selectedDepartmentName = null;
              } else {
                _selectedDepartmentName = value;
              }
            }),
      validator: (value) => value == null ? 'Bölüm seçimi zorunlu' : null,
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunlu';
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await widget.registerService.register(
        name: _nameController.text,
        studentNumber: _numberController.text,
        department: _manualDepartmentEntry
            ? _departmentController.text
            : (_selectedDepartmentName ?? ''),
        password: _passwordController.text,
        facultyId: _selectedFacultyId!,
      );
      if (mounted) setState(() => _submitted = true);
    } on RegisterException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }

    if (mounted) setState(() => _submitting = false);
  }
}
