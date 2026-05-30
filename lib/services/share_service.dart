import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/services/share_file_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ChaosShareService {
  const ChaosShareService();

  Future<void> shareInvite() {
    return SharePlus.instance.share(
      ShareParams(
        subject: 'Chaos Wheel',
        text:
            'Chaos Wheel is ready. Bring your group, spin the wheel, and survive the night.',
      ),
    );
  }

  Future<void> shareChaosReport({
    required List<Player> players,
    required int totalRounds,
    ScreenshotController? screenshotController,
  }) async {
    final text = _buildChaosReportText(
      players: players,
      totalRounds: totalRounds,
    );

    if (screenshotController != null) {
      try {
        final bytes = await screenshotController.capture(
          delay: const Duration(milliseconds: 40),
          pixelRatio: 3,
        );
        if (bytes != null && bytes.isNotEmpty) {
          final file = await createShareImageFile(
            bytes,
            'chaos_report_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await SharePlus.instance.share(
            ShareParams(
              subject: 'Chaos Wheel Report',
              text: text,
              files: [file],
            ),
          );
          return;
        }
      } catch (_) {
        // Fall back to text below. Sharing should never block the report screen.
      }
    }

    await SharePlus.instance.share(
      ShareParams(subject: 'Chaos Wheel Report', text: text),
    );
  }

  String _buildChaosReportText({
    required List<Player> players,
    required int totalRounds,
  }) {
    final targets = players.fold<int>(
      0,
      (total, player) => total + player.targetUsed,
    );
    final dares = players.fold<int>(
      0,
      (total, player) => total + player.dareCount,
    );
    final truths = players.fold<int>(
      0,
      (total, player) => total + player.truthCount,
    );
    final mvp = _winner(players, (player) => player.pickedCount);
    final mostTargeted = _winner(players, (player) => player.targetedCount);
    final dangerous = _winner(players, (player) => player.dareCount);

    return '''
Tonight got dangerous.
Chaos Wheel exposed everyone.

$totalRounds rounds
$targets targets
$dares dares
$truths truths

Chaos MVP: $mvp
Most targeted: $mostTargeted
Most dangerous: $dangerous

Think your group survives?
''';
  }

  static String _winner(
    List<Player> players,
    int Function(Player player) metric,
  ) {
    if (players.isEmpty) {
      return '-';
    }
    final top = players.reduce((a, b) => metric(a) >= metric(b) ? a : b);
    final value = metric(top);
    return value <= 0 ? '-' : '${top.name} x$value';
  }
}
