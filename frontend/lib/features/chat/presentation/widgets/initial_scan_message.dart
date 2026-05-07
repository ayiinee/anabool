import 'package:flutter/material.dart';

import '../../../scan/domain/entities/scan_image_file.dart';
import '../../../scan/domain/entities/scan_session.dart';
import '../../domain/entities/chat_message.dart';
import 'chat_bubble.dart';
import 'image_bubble.dart';

class InitialScanMessage extends StatelessWidget {
  const InitialScanMessage({
    super.key,
    required this.scanSession,
    required this.imageFile,
  });

  final ScanSession scanSession;
  final ScanImageFile imageFile;

  @override
  Widget build(BuildContext context) {
    final caption = ChatMessage(
      id: 'local_scan_caption_${scanSession.id}',
      role: 'user',
      messageType: 'text',
      content: _caption,
      createdAt: DateTime.now(),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          child: ImageBubble(imageProvider: MemoryImage(imageFile.bytes)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          child: ChatBubble(message: caption),
        ),
      ],
    );
  }

  String get _caption {
    final label = scanSession.wasteClass.displayName;
    final confidence = scanSession.confidencePercent;
    return 'Aku baru saja mengambil foto scan. Hasil klasifikasi: $label ($confidence%).';
  }
}
