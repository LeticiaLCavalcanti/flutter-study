import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global notifier to control app theme mode during development.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

const _kThemePrefKey = 'preferredThemeMode';

Future<void> loadTheme() async {
	final prefs = await SharedPreferences.getInstance();
	final stored = prefs.getString(_kThemePrefKey);
	if (stored == 'dark') {
		themeNotifier.value = ThemeMode.dark;
	} else if (stored == 'light') {
		themeNotifier.value = ThemeMode.light;
	} else if (stored == 'system') {
		themeNotifier.value = ThemeMode.system;
	}
}

Future<void> saveTheme(ThemeMode mode) async {
	final prefs = await SharedPreferences.getInstance();
	final s = mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system';
	await prefs.setString(_kThemePrefKey, s);
}
