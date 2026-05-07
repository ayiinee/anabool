import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/user_address.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_session.dart';
import '../widgets/address_card.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = profileSessionController..load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openAddressSheet([UserAddress? address]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddressEditorSheet(
          address: address,
          onSave: (nextAddress) async {
            final saved = await _controller.saveAddress(nextAddress);
            if (context.mounted && saved) {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      appBar: AppBar(
        backgroundColor: AnaboolColors.canvas,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Alamat',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddressSheet(),
        backgroundColor: AnaboolColors.brown,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Tambah',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final profile = _controller.profile;
            if (_controller.isLoading && profile == null) {
              return const Center(
                child: CircularProgressIndicator(color: AnaboolColors.brown),
              );
            }

            final addresses = profile?.addresses ?? const <UserAddress>[];
            if (addresses.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada alamat tersimpan.',
                  style: TextStyle(
                    color: AnaboolColors.brownDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return AddressCard(
                  address: address,
                  onEdit: () => _openAddressSheet(address),
                  onDelete: () => _controller.deleteAddress(address.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AddressEditorSheet extends StatefulWidget {
  const _AddressEditorSheet({
    required this.onSave,
    this.address,
  });

  final UserAddress? address;
  final Future<void> Function(UserAddress address) onSave;

  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _recipientController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _provinceController;
  late final TextEditingController _postalCodeController;
  late bool _isPrimary;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.label ?? 'Rumah');
    _recipientController =
        TextEditingController(text: address?.recipientName ?? '');
    _phoneController = TextEditingController(text: address?.phoneNumber ?? '');
    _addressController =
        TextEditingController(text: address?.fullAddress ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _provinceController = TextEditingController(text: address?.province ?? '');
    _postalCodeController =
        TextEditingController(text: address?.postalCode ?? '');
    _isPrimary = address?.isPrimary ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final id = widget.address?.id ??
        'address-${DateTime.now().millisecondsSinceEpoch}';
    await widget.onSave(
      UserAddress(
        id: id,
        label: _labelController.text.trim(),
        recipientName: _recipientController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        fullAddress: _addressController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        isPrimary: _isPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E5E4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.address == null ? 'Tambah Alamat' : 'Edit Alamat',
                    style: const TextStyle(
                      color: AnaboolColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AddressTextField(
                      controller: _labelController, label: 'Label'),
                  const SizedBox(height: 10),
                  _AddressTextField(
                    controller: _recipientController,
                    label: 'Nama penerima',
                  ),
                  const SizedBox(height: 10),
                  _AddressTextField(
                    controller: _phoneController,
                    label: 'Telepon',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _AddressTextField(
                    controller: _addressController,
                    label: 'Alamat lengkap',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _AddressTextField(
                          controller: _cityController,
                          label: 'Kota',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AddressTextField(
                          controller: _provinceController,
                          label: 'Provinsi',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _AddressTextField(
                    controller: _postalCodeController,
                    label: 'Kode pos',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isPrimary,
                    onChanged: (value) => setState(() {
                      _isPrimary = value;
                    }),
                    activeThumbColor: Colors.white,
                    activeTrackColor: AnaboolColors.brown,
                    title: const Text(
                      'Jadikan alamat utama',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AnaboolColors.brown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Simpan Alamat',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressTextField extends StatelessWidget {
  const _AddressTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFFBF8),
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
