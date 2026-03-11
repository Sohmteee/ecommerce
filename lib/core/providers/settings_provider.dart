import 'package:flutter_riverpod/legacy.dart';

/// Represents the state of application settings.
class SettingsState {
  /// Whether the "liquid glass" visual effect is enabled globally.
  final bool liquidGlassEnabled;

  SettingsState({this.liquidGlassEnabled = true});

  /// Creates a copy of this state with the given fields replaced.
  SettingsState copyWith({bool? liquidGlassEnabled}) {
    return SettingsState(
      liquidGlassEnabled: liquidGlassEnabled ?? this.liquidGlassEnabled,
    );
  }
}

/// Notifier responsible for managing and updating [SettingsState].
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  /// Toggles the liquid glass effect on or off.
  void toggleLiquidGlass() {
    state = state.copyWith(liquidGlassEnabled: !state.liquidGlassEnabled);
  }
}

/// Provider for accessing and listening to [SettingsState].
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
