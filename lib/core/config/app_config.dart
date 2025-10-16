enum AppMode {
  real,
  mock,
}

class AppConfig {
  const AppConfig._(this.mode);

  static AppConfig instance = const AppConfig._(AppMode.mock);

  final AppMode mode;

  static void init(AppMode mode) {
    instance = AppConfig._(mode);
  }

  bool get isMock => mode == AppMode.mock;
}
