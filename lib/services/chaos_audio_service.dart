import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

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
  ChaosAudioService._() {
    _initVibrator();
  }

  static final ChaosAudioService instance = ChaosAudioService._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Whether the device has a real vibrator. When true we drive it directly
  // (bypassing the system "touch vibration" setting that mutes HapticFeedback);
  // otherwise we fall back to HapticFeedback.
  bool _hasVibrator = false;

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

  // Whether the current screen actually wants music playing. The game screen
  // calls [stopMusic] on entry to clear this, so toggling sound/haptics there
  // (which re-runs [configure]) never restarts background music.
  bool _wantsMusic = true;

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

    // Only (re)start music if the active screen actually wants it. Settings
    // toggles must not kick off music on screens that intentionally muted it.
    if (_musicStarted || !_wantsMusic) {
      return;
    }

    await _startMusic(_desiredMusicAsset, _desiredMusicVolume);
  }

  Future<void> playHomeMusic() async {
    _wantsMusic = true;
    _desiredMusicAsset = 'audio/home_music.mp3';
    _desiredMusicVolume = 0.10;
    if (!_backgroundMusicEnabled) return;
    if (_currentMusicAsset == _desiredMusicAsset && _musicStarted) return;
    await _startMusic(_desiredMusicAsset, _desiredMusicVolume);
  }

  Future<void> playNoEscapeMusic() async {
    _wantsMusic = true;
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
    _wantsMusic = false;
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

  /// Immediately stops any one-shot sound effect (e.g. so the No Escape sting
  /// does not bleed into the next turn).
  Future<void> stopSfx() async {
    try {
      await _sfxPlayer.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
    _musicStarted = false;
    _currentMusicAsset = null;
  }

  Future<void> _initVibrator() async {
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (_) {
      _hasVibrator = false;
    }
  }

  /// Fires only the haptic for [sfx] (no sound), respecting the haptics
  /// setting. Used for moments that need a buzz but no extra sound, e.g.
  /// changing the current question.
  void haptic(ChaosSfx sfx) {
    if (_hapticsEnabled) {
      _triggerHaptic(sfx);
    }
  }

  void _triggerHaptic(ChaosSfx sfx) {
    // (duration ms, amplitude 1-255) per event intensity.
    final (ms, amp) = switch (sfx) {
      ChaosSfx.buttonTap => (14, 90),
      ChaosSfx.truthSelected ||
      ChaosSfx.dareSelected ||
      ChaosSfx.wheelSpinStart ||
      ChaosSfx.targetUsed ||
      ChaosSfx.shotTaken ||
      ChaosSfx.premiumLocked ||
      ChaosSfx.revengeAvailable => (35, 180),
      ChaosSfx.wheelStop ||
      ChaosSfx.targetedReveal ||
      ChaosSfx.noEscape ||
      ChaosSfx.evilActivated ||
      ChaosSfx.evilReveal ||
      ChaosSfx.revengeActivated => (60, 255),
    };

    if (_hasVibrator) {
      // Drive the vibrator directly so it fires regardless of the system
      // "touch vibration" setting that mutes HapticFeedback.
      try {
        Vibration.vibrate(duration: ms, amplitude: amp);
        return;
      } catch (_) {
        // Fall through to platform haptics.
      }
    }

    if (amp >= 255) {
      HapticFeedback.heavyImpact();
    } else if (amp >= 180) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
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
      ChaosSfx.noEscape => 'audio/evil_activated_real.mp3',
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
