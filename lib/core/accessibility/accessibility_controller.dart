import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/database/database_helper.dart';
import '../../data/services/local_session_service.dart';

class AccessibilityController extends ChangeNotifier {
  AccessibilityController._();

  static final AccessibilityController instance = AccessibilityController._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  StreamSubscription<User?>? _authSubscription;
  VoidCallback? _sessionListener;

  bool _darkMode = false;
  bool _highContrast = false;
  double _fontScale = 1;
  bool _musicEnabled = false;
  double _musicVolume = 0.45;
  String? _backgroundTrack;
  String? _scopeKey;
  bool _initialized = false;

  bool get darkMode => _darkMode;
  bool get highContrast => _highContrast;
  double get fontScale => _fontScale;
  bool get musicEnabled => _musicEnabled;
  double get musicVolume => _musicVolume;
  String? get backgroundTrack => _backgroundTrack;

  Future<void> init() async {
    if (_initialized) return;

    try {
      await _ensureTable();

      try {
        await _loadBackgroundTrack();
      } catch (e) {
        debugPrint('No se pudo cargar la musica de fondo: $e');
        _backgroundTrack = null;
      }

      _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen((
        user,
      ) {
        activateForUser(user);
      });

      _sessionListener ??= () {
        activateForLocalSession();
      };

      LocalSessionService.instance.addListener(_sessionListener!);

      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);

      await activateForUser(FirebaseAuth.instance.currentUser);

      if (FirebaseAuth.instance.currentUser == null) {
        await activateForLocalSession();
      }
    } catch (e) {
      debugPrint('No se pudo inicializar accesibilidad: $e');
    } finally {
      _initialized = true;
    }
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _saveSetting('darkMode', value ? '1' : '0');
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    await _saveSetting('highContrast', value ? '1' : '0');
  }

  Future<void> setFontScale(double value) async {
    _fontScale = value.clamp(0.9, 2.0);
    notifyListeners();
    await _saveSetting('fontScale', _fontScale.toString());
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    notifyListeners();
    await _saveSetting('musicEnabled', value ? '1' : '0');
    await _syncMusic();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0, 1);
    notifyListeners();
    await _musicPlayer.setVolume(_musicVolume);
    await _saveSetting('musicVolume', _musicVolume.toString());
  }

  Future<void> activateForUser(User? user) async {
    if (user == null && LocalSessionService.instance.hasUser) {
      await activateForLocalSession();
      return;
    }

    await _activateForScope(user?.email);
  }

  Future<void> activateForLocalSession() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return;
    }

    await _activateForScope(LocalSessionService.instance.email);
  }

  Future<void> _activateForScope(String? scope) async {
    final nextScope = scope?.trim().toLowerCase();

    if (nextScope == _scopeKey && _initialized) {
      return;
    }

    _scopeKey = nextScope;

    if (_scopeKey == null || _scopeKey!.isEmpty) {
      _resetToDefaults();
      await _syncMusic();
      notifyListeners();
      return;
    }

    await _loadSettings();
    notifyListeners();
    await _syncMusic();
  }

  Future<void> _ensureTable() async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _loadSettings() async {
    final scope = _scopeKey;

    if (scope == null || scope.isEmpty) {
      _resetToDefaults();
      return;
    }

    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'app_settings',
      where: 'key IN (?, ?, ?, ?, ?)',
      whereArgs: [
        _settingKey('darkMode'),
        _settingKey('highContrast'),
        _settingKey('fontScale'),
        _settingKey('musicEnabled'),
        _settingKey('musicVolume'),
      ],
    );
    final settings = {
      for (final row in rows) row['key'].toString(): row['value'].toString(),
    };

    _darkMode = settings[_settingKey('darkMode')] == '1';
    _highContrast = settings[_settingKey('highContrast')] == '1';
    _fontScale = double.tryParse(settings[_settingKey('fontScale')] ?? '') ?? 1;
    _musicEnabled = settings[_settingKey('musicEnabled')] == '1';
    _musicVolume =
        double.tryParse(settings[_settingKey('musicVolume')] ?? '') ?? 0.45;
  }

  Future<void> _saveSetting(String key, String value) async {
    if (_scopeKey == null || _scopeKey!.isEmpty) return;

    final db = await DatabaseHelper.instance.database;

    await db.insert('app_settings', {
      'key': _settingKey(key),
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String _settingKey(String key) {
    return 'accessibility.$_scopeKey.$key';
  }

  void _resetToDefaults() {
    _darkMode = false;
    _highContrast = false;
    _fontScale = 1;
    _musicEnabled = false;
    _musicVolume = 0.45;
  }

  Future<void> _loadBackgroundTrack() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final tracks =
        manifest
            .listAssets()
            .where(
              (asset) =>
                  asset.startsWith('assets/sounds/') &&
                  _isAudioFile(asset) &&
                  !_isEffectSound(asset),
            )
            .toList()
          ..sort();

    _backgroundTrack = tracks.isEmpty ? null : tracks.first;
  }

  bool _isAudioFile(String asset) {
    final lower = asset.toLowerCase();

    return lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.ogg') ||
        lower.endsWith('.m4a');
  }

  bool _isEffectSound(String asset) {
    final lower = asset.toLowerCase();

    return lower.endsWith('/success.mp3') || lower.endsWith('/error.mp3');
  }

  Future<void> _syncMusic() async {
    if (!_musicEnabled || _backgroundTrack == null) {
      await _musicPlayer.stop();
      return;
    }

    await _musicPlayer.play(
      AssetSource(_backgroundTrack!.replaceFirst('assets/', '')),
      volume: _musicVolume,
    );
  }
}
