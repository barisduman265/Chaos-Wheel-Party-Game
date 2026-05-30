import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum ChaosSfx {
  buttonTap,
  wheelSpinStart,
  wheelStop,
  truthSelected,
  dareSelected,
  shotTaken,
  targetUsed,
  targetedReveal,
  noEscape,
  premiumLocked,
  evilActivated,
  evilReveal,
  revengeAvailable,
  revengeActivated,
}

class ChaosAudioService {
  ChaosAudioService._();

  static final ChaosAudioService instance = ChaosAudioService._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _backgroundMusicEnabled = false;
  bool _musicStarted = false;

  Future<void> configure({
    required bool soundEnabled,
    required bool hapticsEnabled,
    required bool backgroundMusicEnabled,
  }) async {
    _soundEnabled = soundEnabled;
    _hapticsEnabled = hapticsEnabled;
    _backgroundMusicEnabled = backgroundMusicEnabled;

    if (!_backgroundMusicEnabled || !_soundEnabled) {
      await _musicPlayer.stop();
      _musicStarted = false;
      return;
    }

    if (_musicStarted) {
      return;
    }

    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.08);
      await _musicPlayer.play(AssetSource('audio/background_loop.wav'));
      _musicStarted = true;
    } catch (_) {
      _musicStarted = false;
    }
  }

  Future<void> play(ChaosSfx sfx) async {
    if (_hapticsEnabled) {
      _triggerHaptic(sfx);
    }

    if (!_soundEnabled) {
      return;
    }

    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(_volumeFor(sfx));
      await _sfxPlayer.play(AssetSource(_assetFor(sfx)));
    } catch (_) {
      // Audio should never block gameplay.
    }
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
  }

  void _triggerHaptic(ChaosSfx sfx) {
    switch (sfx) {
      case ChaosSfx.buttonTap:
      case ChaosSfx.truthSelected:
      case ChaosSfx.dareSelected:
        HapticFeedback.selectionClick();
      case ChaosSfx.wheelSpinStart:
      case ChaosSfx.targetUsed:
        HapticFeedback.mediumImpact();
      case ChaosSfx.wheelStop:
      case ChaosSfx.targetedReveal:
      case ChaosSfx.noEscape:
      case ChaosSfx.evilActivated:
      case ChaosSfx.evilReveal:
      case ChaosSfx.revengeActivated:
        HapticFeedback.heavyImpact();
      case ChaosSfx.shotTaken:
      case ChaosSfx.premiumLocked:
      case ChaosSfx.revengeAvailable:
        HapticFeedback.lightImpact();
    }
  }

  String _assetFor(ChaosSfx sfx) {
    return switch (sfx) {
      ChaosSfx.buttonTap => 'audio/button_tap_real.mp3',
      ChaosSfx.wheelSpinStart => 'audio/wheel_spin_real.mp3',
      ChaosSfx.wheelStop => 'audio/wheel_stop_real.mp3',
      ChaosSfx.truthSelected => 'audio/truth_real.mp3',
      ChaosSfx.dareSelected => 'audio/dare_real.mp3',
      ChaosSfx.shotTaken => 'audio/shot_real.mp3',
      ChaosSfx.targetUsed => 'audio/target_real.mp3',
      ChaosSfx.targetedReveal => 'audio/targeted_real.mp3',
      ChaosSfx.noEscape => 'audio/no_escape_real.mp3',
      ChaosSfx.premiumLocked => 'audio/premium_locked_real.mp3',
      ChaosSfx.evilActivated => 'audio/evil_activated_real.mp3',
      ChaosSfx.evilReveal => 'audio/evil_activated_real.mp3',
      ChaosSfx.revengeAvailable => 'audio/revenge_available.wav',
      ChaosSfx.revengeActivated => 'audio/revenge_real.mp3',
    };
  }

  double _volumeFor(ChaosSfx sfx) {
    return switch (sfx) {
      ChaosSfx.wheelSpinStart => 0.18,
      ChaosSfx.noEscape ||
      ChaosSfx.evilActivated ||
      ChaosSfx.evilReveal ||
      ChaosSfx.revengeActivated => 0.28,
      ChaosSfx.wheelStop || ChaosSfx.targetedReveal => 0.24,
      _ => 0.20,
    };
  }
}
