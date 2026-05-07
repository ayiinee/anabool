class ChatCtaCard {
  const ChatCtaCard({
    required this.cardType,
    required this.title,
    required this.description,
    required this.ctaLabel,
    this.targetRoute,
    this.payload = const {},
  });

  final String cardType;
  final String title;
  final String description;
  final String ctaLabel;
  final String? targetRoute;
  final Map<String, dynamic> payload;

  bool get opensRoute => targetRoute != null && targetRoute!.trim().isNotEmpty;
}
