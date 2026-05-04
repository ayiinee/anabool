import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../models/home_dashboard_model.dart';

class HomeDashboardMockData {
  const HomeDashboardMockData._();

  static const user = UserSummary(
    name: 'Ana',
    meowPoints: '1.250',
    initials: 'A',
  );

  static const cats = [
    CatStatus(
      name: 'Milo',
      avatarColor: Color(0xFFFFB56F),
      peeCount: 3,
      poopCount: 1,
    ),
    CatStatus(
      name: 'Luna',
      avatarColor: Color(0xFF9DD6B4),
      peeCount: 1,
      poopCount: 0,
      missedActivity: 'Belum pup',
    ),
    CatStatus(
      name: 'Oyen',
      avatarColor: Color(0xFFFFD06B),
      peeCount: 4,
      poopCount: 2,
    ),
  ];

  static const checklist = [
    ChecklistItem(
      title: 'Gunakan Sarung Tangan',
      subtitle: 'Kurangi kontak langsung saat membersihkan pasir.',
    ),
    ChecklistItem(
      title: 'Pakai Kantong Tertutup',
      subtitle: 'Pisahkan limbah anabul dari sampah dapur.',
    ),
    ChecklistItem(
      title: 'Cuci Tangan',
      subtitle: 'Gunakan sabun setelah mengganti pasir.',
    ),
  ];

  static const quickActions = [
    QuickAction(label: 'Catat Aktivitas', icon: Icons.edit_note_rounded),
    QuickAction(label: 'Upload Foto', icon: Icons.add_a_photo_rounded),
    QuickAction(label: 'Jadwalkan Pick-up', icon: Icons.local_shipping_rounded),
  ];

  static const impactMetrics = [
    ImpactMetric(
      value: '12,4 kg',
      label: 'Limbah dikelola',
      icon: Icons.compost_rounded,
    ),
    ImpactMetric(
      value: '18x',
      label: 'Checklist selesai',
      icon: Icons.task_alt_rounded,
    ),
  ];

  static const abnormalAlert = 'Pola tidak normal terdeteksi pada Luna';
  static const educationTitle = 'Kenali Risiko Toksoplasmosis';
  static const educationDescription =
      'Selesaikan modul kebersihan aman dan dapatkan reward hari ini.';
  static const litterStatus = 'Perlu dibersihkan malam ini';
  static const impactNote =
      'Kontribusimu membantu pengelolaan limbah anabul yang lebih aman.';
  static const Color educationAccent = AnaboolColors.orange;
}
