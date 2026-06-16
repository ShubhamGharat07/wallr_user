import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/onboarding_repository.dart';

abstract interface class OnboardingLocalDataSource {
  Future<bool> isOnboardingComplete();
  Future<void> markOnboardingComplete();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryDb = const {}; // Or just simple map
  static const _kOnboardingKey = 'onboarding_done';

  // We can use a simple map for fallback
  static final Map<String, bool> _fallbackPrefs = {};

  const OnboardingLocalDataSourceImpl(this._prefs);

  @override
  Future<bool> isOnboardingComplete() async {
    if (_prefs == null) {
      return _fallbackPrefs[_kOnboardingKey] ?? false;
    }
    return _prefs.getBool(_kOnboardingKey) ?? false;
  }

  @override
  Future<void> markOnboardingComplete() async {
    if (_prefs == null) {
      _fallbackPrefs[_kOnboardingKey] = true;
      return;
    }
    await _prefs.setBool(_kOnboardingKey, true);
  }
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _dataSource;
  const OnboardingRepositoryImpl(this._dataSource);

  @override
  Future<bool> isOnboardingComplete() => _dataSource.isOnboardingComplete();

  @override
  Future<void> markOnboardingComplete() => _dataSource.markOnboardingComplete();
}
