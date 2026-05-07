import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_event.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_state.dart';
import 'package:image_picker/image_picker.dart';

class ScoutRegisterPage extends StatefulWidget {
  const ScoutRegisterPage({super.key});

  @override
  State<ScoutRegisterPage> createState() => _ScoutRegisterPageState();
}

class _ScoutRegisterPageState extends State<ScoutRegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nationalIdFanNoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _countryController = TextEditingController(text: 'Ethiopia');
  final _yearsExperienceController = TextEditingController();

  final _picker = ImagePicker();
  String? _licencePhotoPath;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nationalIdFanNoController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _countryController.dispose();
    _yearsExperienceController.dispose();
    super.dispose();
  }

  Future<void> _pickLicencePhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    setState(() {
      _licencePhotoPath = x.path.isNotEmpty ? x.path : 'web:${x.name}';
    });
  }

  void _submit() {
    int? years;
    final y = _yearsExperienceController.text.trim();
    if (y.isNotEmpty) {
      years = int.tryParse(y);
    }

    context.read<AuthBloc>().add(
          CreateScoutAccountRequested(
            ScoutAccountRegistration(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              licencePhotoPath: _licencePhotoPath,
              nationalIdFanNo: _nationalIdFanNoController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              organizationName: _organizationController.text.trim(),
              country: _countryController.text.trim(),
              yearsExperience: years,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create scout account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Scout registration',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Provide your details and upload a clear photo of your scouting licence.',
                  style: TextStyle(
                    color: AppColors.gray.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                _field(_fullNameController, 'Full name', isDark),
                _field(_emailController, 'Email', isDark,
                    keyboard: TextInputType.emailAddress),
                _field(_passwordController, 'Password (min 6 characters)', isDark,
                    obscure: true),
                _field(_nationalIdFanNoController,
                    'National ID / FAN number', isDark),
                _field(_phoneController, 'Phone number', isDark,
                    keyboard: TextInputType.phone),
                _field(_organizationController,
                    'Organization / club (optional)', isDark),
                _field(_countryController, 'Country', isDark),
                _field(
                  _yearsExperienceController,
                  'Years of experience (optional)',
                  isDark,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text(
                  'Licence photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: loading ? null : _pickLicencePhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(
                    _licencePhotoPath == null
                        ? 'Upload licence photo'
                        : 'Change licence photo',
                  ),
                ),
                if (_licencePhotoPath != null) ...[
                  const SizedBox(height: 12),
                  if (!kIsWeb &&
                      _licencePhotoPath!.isNotEmpty &&
                      !_licencePhotoPath!.startsWith('web:'))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_licencePhotoPath!),
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Text(
                      'Photo selected',
                      style: TextStyle(
                        color: AppColors.primaryGreen.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('CREATE SCOUT ACCOUNT'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }




  Widget _field(
    TextEditingController c,
    String label,
    bool isDark, {
    bool obscure = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white60 : Colors.black45,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
