import 'package:flutter_riverpod/legacy.dart';

class SettingsState {
  final bool liquidGlassEnabled;

  SettingsState({this.liquidGlassEnabled = true});

  SettingsState copyWith({bool? liquidGlassEnabled}) {
    return SettingsState(
      liquidGlassEnabled: liquidGlassEnabled ?? this.liquidGlassEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void toggleLiquidGlass() {
    state = state.copyWith(liquidGlassEnabled: !state.liquidGlassEnabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
