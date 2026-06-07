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
  String? _currentMusicAsset;

  // The track (and volume) the current screen wants playing. Music is gated
  // ONLY by [_backgroundMusicEnabled] — it is fully independent of the sound
  // effects toggle, so muting SFX never stops the music and vice versa.
  String _desiredMusicAsset = 'audio/home_music.mp3';
  double _desiredMusicVolume = 0.10;

  Future<void> configure({
    required bool soundEnabled,
    required bool hapticsEnabled,
    required bool backgroundMusicEnabled,
  }) async {
    _soundEnabled = soundEnabled;
    _hapticsEnabled = hapticsEnabled;
    _backgroundMusicEnabled = backgroundMusicEnabled;

    if (!_backgroundMusicEnabled) {
      await _musicPlayer.stop();
      _musicStarted = false;
      _currentMusicAsset = null;
      return;
    }

    if (_musicStarted) {
      return;
    }

    await _startMusic(_desiredMusicAsset, _desiredMusicVolume);
  }

  Future<void> playHomeMusic() async {
    _desiredMusicAsset = 'audio/home_music.mp3';
    _desiredMusicVolume = 0.10;
    if (!_backgroundMusicEnabled) return;
    if (_currentMusicAsset == _desiredMusicAsset && _musicStarted) return;
    await _startMusic(_desiredMusicAsset, _desiredMusicVolume);
  }

  Future<void> playNoEscapeMusic() async {
    _desiredMusicAsset = 'audio/noescape_music.mp3';
    _desiredMusicVolume = 0.13;
    if (!_backgroundMusicEnabled) return;
    if (_currentMusicAsset == _desiredMusicAsset && _musicStarted) return;
    await _startMusic(_desiredMusicAsset, _desiredMusicVolume);
  }

  Future<void> _startMusic(String asset, double volume) async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(volume);
      await _musicPlayer.play(AssetSource(asset));
      _currentMusicAsset = asset;
      _musicStarted = true;
    } catch (_) {
      _musicStarted = false;
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _musicStarted = false;
    _currentMusicAsset = null;
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
    _musicStarted = false;
    _currentMusicAsset = null;
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
