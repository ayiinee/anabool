import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/user_address.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    this.onEdit,
    this.onDelete,
  });

  final UserAddress address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0C7B4)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  address.label,
                  style: const TextStyle(
                    color: AnaboolColors.brown,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (address.isPrimary) ...[
                const SizedBox(width: 7),
                const Text(
                  'Utama',
                  style: TextStyle(
                    color: AnaboolColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              const Spacer(),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit alamat',
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.edit_location_alt_rounded,
                    color: AnaboolColors.brown,
                    size: 20,
                  ),
                ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Hapus alamat',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AnaboolColors.red,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.recipientName,
            style: const TextStyle(
              color: AnaboolColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            address.phoneNumber,
            style: const TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${address.fullAddress}, ${address.city}, ${address.province} ${address.postalCode}',
            style: const TextStyle(
              color: AnaboolColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.28,
            ),
          ),
        ],
      ),
    );
  }
}
