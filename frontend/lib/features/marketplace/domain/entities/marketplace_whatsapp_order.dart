import 'marketplace_product.dart';

class MarketplaceWhatsAppOrder {
  final String waNumber;
  final String templateMessage;
  final String waUrl;

  const MarketplaceWhatsAppOrder({
    required this.waNumber,
    required this.templateMessage,
    required this.waUrl,
  });

  factory MarketplaceWhatsAppOrder.fromMap(Map<String, dynamic> map) {
    return MarketplaceWhatsAppOrder(
      waNumber: map['wa_number'] as String? ?? '',
      templateMessage: map['template_message'] as String? ?? '',
      waUrl: map['wa_url'] as String? ?? '',
    );
  }

  factory MarketplaceWhatsAppOrder.fromProductFallback(
    MarketplaceProduct product,
  ) {
    final waNumber = _normalizeWhatsAppNumber(product.waNumber);
    final message = _formatTemplate(product.waTemplate, product);

    return MarketplaceWhatsAppOrder(
      waNumber: waNumber,
      templateMessage: message,
      waUrl: waNumber.isEmpty
          ? ''
          : 'https://wa.me/$waNumber?text=${Uri.encodeComponent(message)}',
    );
  }
}

String _normalizeWhatsAppNumber(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return '';
  }
  if (digits.startsWith('0')) {
    return '62${digits.substring(1)}';
  }
  if (digits.startsWith('8')) {
    return '62$digits';
  }
  return digits;
}

String _formatTemplate(String template, MarketplaceProduct product) {
  final message = template.trim().isEmpty
      ? 'Halo, saya tertarik dengan {product_name} di ANABOOL.'
      : template;

  return message
      .replaceAll('{product_id}', product.id)
      .replaceAll('{product_name}', product.name)
      .replaceAll('{price_idr}', product.priceIdr.toString())
      .replaceAll('{seller_name}', product.seller?.displayName ?? 'penjual')
      .trim();
}
