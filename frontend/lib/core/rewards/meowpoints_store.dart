import 'package:flutter/foundation.dart';

class MeowPointsStore extends ChangeNotifier {
  MeowPointsStore._();

  static final MeowPointsStore instance = MeowPointsStore._();

  static const moduleCompletionReward = 25;
  static const pickupCompostReward = 50;

  int _balance = 0;
  final Set<String> _awardedSources = <String>{};

  int get balance => _balance;

  String get balanceLabel => '${_format(balance)} XP';

  void setBalance(int value) {
    final normalized = value < 0 ? 0 : value;
    if (_balance == normalized) {
      return;
    }

    _balance = normalized;
    notifyListeners();
  }

  bool awardModuleCompletion(String moduleId, {int? points}) {
    return _awardOnce(
      sourceKey: 'module:$moduleId',
      points: points ?? moduleCompletionReward,
    );
  }

  bool awardPickupCompost(String orderId, {int? points}) {
    return _awardOnce(
      sourceKey: 'pickup_pupuk:$orderId',
      points: points ?? pickupCompostReward,
    );
  }

  bool _awardOnce({
    required String sourceKey,
    required int points,
  }) {
    if (points <= 0 || _awardedSources.contains(sourceKey)) {
      return false;
    }

    _awardedSources.add(sourceKey);
    _balance += points;
    notifyListeners();
    return true;
  }

  static String _format(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }
}
