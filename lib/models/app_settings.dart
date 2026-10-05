class AppSettings {
  final String currencyCode;
  final String currencySymbol;
  final double defaultMonthlyBudget;
  final bool reducedMotion;
  final bool notificationsEnabled;
  final bool soundEnabled;

  AppSettings({
    this.currencyCode = 'INR',
    this.currencySymbol = '₹',
    this.defaultMonthlyBudget = 30000.0,
    this.reducedMotion = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });

  Map<String, String> toMap() {
    return {
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'default_monthly_budget': defaultMonthlyBudget.toString(),
      'reduced_motion': reducedMotion ? '1' : '0',
      'notifications_enabled': notificationsEnabled ? '1' : '0',
      'sound_enabled': soundEnabled ? '1' : '0',
    };
  }

  factory AppSettings.fromMap(Map<String, String> map) {
    return AppSettings(
      currencyCode: map['currency_code'] ?? 'INR',
      currencySymbol: map['currency_symbol'] ?? '₹',
      defaultMonthlyBudget: double.tryParse(map['default_monthly_budget'] ?? '30000') ?? 30000.0,
      reducedMotion: map['reduced_motion'] == '1',
      notificationsEnabled: map['notifications_enabled'] != '0',
      soundEnabled: map['sound_enabled'] != '0',
    );
  }

  AppSettings copyWith({
    String? currencyCode,
    String? currencySymbol,
    double? defaultMonthlyBudget,
    bool? reducedMotion,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return AppSettings(
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      defaultMonthlyBudget: defaultMonthlyBudget ?? this.defaultMonthlyBudget,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
