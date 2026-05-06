import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileController _controller;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _didFillFields = false;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController.create()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _fillFields() {
    final profile = _controller.profile;
    if (_didFillFields || profile == null) {
      return;
    }

    _didFillFields = true;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phoneNumber;
    _locationController.text = profile.location;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final saved = await _controller.saveProfile(
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      location: _locationController.text,
    );

    if (!mounted) {
      return;
    }

    if (saved) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      appBar: AppBar(
        backgroundColor: AnaboolColors.canvas,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            _fillFields();
            final profile = _controller.profile;

            if (_controller.isLoading && profile == null) {
              return const Center(
                child: CircularProgressIndicator(color: AnaboolColors.brown),
              );
            }

            if (profile == null) {
              return const Center(child: Text('Profil belum tersedia.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AnaboolColors.brown,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: DesignImage(
                          asset: profile.avatarAsset,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ProfileTextField(
                      controller: _nameController,
                      label: 'Nama',
                    ),
                    const SizedBox(height: 12),
                    _ProfileTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _ProfileTextField(
                      controller: _phoneController,
                      label: 'Telepon',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _ProfileTextField(
                      controller: _locationController,
                      label: 'Lokasi',
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _controller.isSaving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AnaboolColors.brown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _controller.isSaving ? 'Menyimpan...' : 'Simpan',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
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

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF0C7B4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF0C7B4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AnaboolColors.brown, width: 1.4),
        ),
      ),
    );
  }
}
