import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class MessageComposer extends StatelessWidget {
  const MessageComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: const InputDecoration(
                  hintText: 'Enter your message...',
                  hintStyle: TextStyle(
                    color: Color(0xFFCFC4BE),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: AnaboolColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 46,
              height: 46,
              child: IconButton.filled(
                tooltip: 'Kirim pesan',
                onPressed: enabled && !sending ? onSend : null,
                style: IconButton.styleFrom(
                  backgroundColor: AnaboolColors.brown,
                  disabledBackgroundColor: AnaboolColors.brownSoft,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.near_me_rounded, size: 24),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
