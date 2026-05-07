import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/repositories/cat_repository.dart';
import '../controllers/cat_controller.dart';

class AddCatPage extends StatefulWidget {
  const AddCatPage({super.key});

  @override
  State<AddCatPage> createState() => _AddCatPageState();
}

class _AddCatPageState extends State<AddCatPage> {
  static const _lifeStages = ['Kitten', 'Dewasa', 'Senior'];
  static const _genders = ['Jantan', 'Betina', 'Belum diisi'];
  static const _boxTypes = [
    'Bak terbuka',
    'Bak tertutup',
    'Top-entry',
    'Otomatis',
    'Lainnya',
  ];
  static const _litterTypes = [
    'Bentonite/Pasir Gumpal',
    'Tofu',
    'Crystal',
    'Pine/Recycled',
    'Lainnya',
  ];
  static const _locations = [
    'Kamar mandi',
    'Balkon',
    'Area laundry',
    'Kamar tidur',
    'Lainnya',
  ];
  static const _cleaningFrequencies = [
    'Setelah dipakai',
    'Sekali sehari',
    'Setiap dua hari',
    'Dua kali seminggu',
    'Mingguan',
  ];
  static const _lastCleanedOptions = [
    'Hari ini',
    'Kemarin',
    'Dua hari lalu',
    'Lebih dari dua hari',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _healthNotesController = TextEditingController();
  late final CatController _controller;

  String _lifeStage = _lifeStages[1];
  String _gender = _genders[2];
  String _boxType = _boxTypes[0];
  String _litterType = _litterTypes[0];
  String _location = _locations[0];
  String _cleaningFrequency = _cleaningFrequencies[1];
  String _lastCleaned = _lastCleanedOptions[0];
  int _boxCount = 1;
  int _peeFrequency = 3;
  int _poopFrequency = 1;

  @override
  void initState() {
    super.initState();
    _controller = CatController.create();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _healthNotesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final saved = await _controller.addCat(
      AddCatInput(
        name: _nameController.text,
        breed: _breedController.text,
        lifeStage: _lifeStage,
        gender: _gender,
        boxType: _boxType,
        litterType: _litterType,
        boxCount: _boxCount,
        locationLabel: _location,
        peeFrequencyPerDay: _peeFrequency,
        poopFrequencyPerDay: _poopFrequency,
        cleaningFrequency: _cleaningFrequency,
        lastCleanedLabel: _lastCleaned,
        healthNotes: _healthNotesController.text,
      ),
    );

    if (!mounted) {
      return;
    }

    if (saved) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Profil kucing berhasil disimpan.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      appBar: AppBar(
        backgroundColor: AnaboolColors.canvas,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Tambah Kucing',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(22, 8, 22, 20 + bottomInset),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const DesignImage(
                            asset: CatAssets.personalizationMascot,
                            width: 126,
                            height: 126,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Kenali Rutinitas Anabul',
                            style: TextStyle(
                              color: AnaboolColors.brown,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FormSection(
                            title: 'Profil Kucing',
                            children: [
                              _CatTextField(
                                key: const ValueKey('cat-name-field'),
                                controller: _nameController,
                                label: 'Nama Kucing',
                                hintText: 'Masukkan nama...',
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'Nama kucing wajib diisi.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              _CatTextField(
                                controller: _breedController,
                                label: 'Ras / Jenis Kucing',
                                hintText: 'Contoh: Persia mix',
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _CatDropdown(
                                      label: 'Usia',
                                      value: _lifeStage,
                                      items: _lifeStages,
                                      onChanged: (value) {
                                        setState(() => _lifeStage = value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CatDropdown(
                                      label: 'Gender',
                                      value: _gender,
                                      items: _genders,
                                      onChanged: (value) {
                                        setState(() => _gender = value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _FormSection(
                            title: 'Kotak Pasir',
                            children: [
                              _CatDropdown(
                                key: const ValueKey('cat-box-type-dropdown'),
                                label: 'Tipe Litter Box',
                                value: _boxType,
                                items: _boxTypes,
                                onChanged: (value) {
                                  setState(() => _boxType = value);
                                },
                              ),
                              const SizedBox(height: 10),
                              _CatDropdown(
                                key: const ValueKey('cat-litter-type-dropdown'),
                                label: 'Jenis Pasir',
                                value: _litterType,
                                items: _litterTypes,
                                onChanged: (value) {
                                  setState(() => _litterType = value);
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _CatCounter(
                                      label: 'Jumlah Box',
                                      value: _boxCount,
                                      min: 1,
                                      max: 6,
                                      onChanged: (value) {
                                        setState(() => _boxCount = value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CatDropdown(
                                      label: 'Lokasi',
                                      value: _location,
                                      items: _locations,
                                      onChanged: (value) {
                                        setState(() => _location = value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _FormSection(
                            title: 'Rutinitas Harian',
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _CatCounter(
                                      key: const ValueKey('cat-pee-counter'),
                                      label: 'Pipis / Hari',
                                      value: _peeFrequency,
                                      min: 0,
                                      max: 12,
                                      onChanged: (value) {
                                        setState(() => _peeFrequency = value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CatCounter(
                                      key: const ValueKey('cat-poop-counter'),
                                      label: 'Pup / Hari',
                                      value: _poopFrequency,
                                      min: 0,
                                      max: 8,
                                      onChanged: (value) {
                                        setState(() => _poopFrequency = value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _CatDropdown(
                                label: 'Kebiasaan Membersihkan',
                                value: _cleaningFrequency,
                                items: _cleaningFrequencies,
                                onChanged: (value) {
                                  setState(() => _cleaningFrequency = value);
                                },
                              ),
                              const SizedBox(height: 10),
                              _CatDropdown(
                                label: 'Terakhir Dibersihkan',
                                value: _lastCleaned,
                                items: _lastCleanedOptions,
                                onChanged: (value) {
                                  setState(() => _lastCleaned = value);
                                },
                              ),
                              const SizedBox(height: 10),
                              _CatTextField(
                                controller: _healthNotesController,
                                label: 'Catatan Kesehatan',
                                hintText:
                                    'Contoh: sensitif pasir, diare, sulit pipis',
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(22, 12, 22, 14 + bottomInset),
                  decoration: const BoxDecoration(
                    color: AnaboolColors.canvas,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      key: const ValueKey('cat-save-button'),
                      onPressed: _controller.isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AnaboolColors.brown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _controller.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Simpan Profil Kucing',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0C7B4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AnaboolColors.brownDark,
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CatTextField extends StatelessWidget {
  const _CatTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          cursorColor: AnaboolColors.brown,
          style: const TextStyle(
            color: AnaboolColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          decoration: _inputDecoration(hintText),
        ),
      ],
    );
  }
}

class _CatDropdown extends StatelessWidget {
  const _CatDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          decoration: _inputDecoration(null),
          style: const TextStyle(
            color: AnaboolColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}

class _CatCounter extends StatelessWidget {
  const _CatCounter({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        Container(
          height: 47,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1EB),
            border: Border.all(color: const Color(0xFFFFE1D4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                tooltip: 'Kurangi $label',
                onTap: value <= min ? null : () => onChanged(value - 1),
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AnaboolColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add_rounded,
                tooltip: 'Tambah $label',
                onTap: value >= max ? null : () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 47,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          icon,
          color: onTap == null ? AnaboolColors.border : AnaboolColors.brown,
          size: 18,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String? hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: AnaboolColors.border,
      fontSize: 12,
      fontWeight: FontWeight.w800,
    ),
    errorStyle: const TextStyle(
      color: AnaboolColors.red,
      fontSize: 10,
      fontWeight: FontWeight.w800,
    ),
    filled: true,
    fillColor: const Color(0xFFFFF1EB),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFFE1D4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFFE1D4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AnaboolColors.brown, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AnaboolColors.red, width: 1.1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AnaboolColors.red, width: 1.2),
    ),
  );
}
