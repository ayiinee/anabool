import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/cat_activity.dart';
import '../controllers/cat_controller.dart';

class RecordActivityPage extends StatefulWidget {
  const RecordActivityPage({
    super.key,
    required this.catId,
  });

  final String catId;

  @override
  State<RecordActivityPage> createState() => _RecordActivityPageState();
}

class _RecordActivityPageState extends State<RecordActivityPage> {
  final _notesController = TextEditingController();
  late final CatController _controller;
  CatActivityType _type = CatActivityType.pee;

  @override
  void initState() {
    super.initState();
    _controller = CatController.create()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await _controller.recordActivity(
      catId: widget.catId,
      type: _type,
      notes: _notesController.text,
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
          'Catat Aktivitas',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final profile = _controller.findCat(widget.catId);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile == null
                        ? 'Aktivitas Anabul'
                        : 'Aktivitas ${profile.cat.name}',
                    style: const TextStyle(
                      color: AnaboolColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActivityChoice(
                        label: 'Pipis',
                        icon: Icons.water_drop_outlined,
                        selected: _type == CatActivityType.pee,
                        onTap: () =>
                            setState(() => _type = CatActivityType.pee),
                      ),
                      _ActivityChoice(
                        label: 'Pup',
                        icon: Icons.pets_rounded,
                        selected: _type == CatActivityType.poop,
                        onTap: () =>
                            setState(() => _type = CatActivityType.poop),
                      ),
                      _ActivityChoice(
                        label: 'Bersihkan',
                        icon: Icons.cleaning_services_outlined,
                        selected: _type == CatActivityType.clean,
                        onTap: () =>
                            setState(() => _type = CatActivityType.clean),
                      ),
                      _ActivityChoice(
                        label: 'Catatan',
                        icon: Icons.edit_note_rounded,
                        selected: _type == CatActivityType.note,
                        onTap: () =>
                            setState(() => _type = CatActivityType.note),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    cursorColor: AnaboolColors.brown,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
                      hintText: 'Tambahkan detail jika perlu...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF0C7B4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AnaboolColors.brown,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
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
            );
          },
        ),
      ),
    );
  }
}

class _ActivityChoice extends StatelessWidget {
  const _ActivityChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : AnaboolColors.brown,
      ),
      label: Text(label),
      selectedColor: AnaboolColors.brown,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AnaboolColors.brownDark,
        fontWeight: FontWeight.w900,
      ),
      side: const BorderSide(color: Color(0xFFF0C7B4)),
    );
  }
}
