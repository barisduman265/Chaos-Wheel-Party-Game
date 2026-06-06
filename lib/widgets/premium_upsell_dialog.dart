import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/widgets/premium_plan_cards.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows the in-game premium upsell as a centered, conversion-focused pop-up.
///
/// Returns when the dialog is dismissed (either the player unlocked premium or
/// tapped "maybe later"). Safe to call for premium users too — it simply does
/// nothing in that case.
Future<void> showPremiumUpsell(BuildContext context) {
  if (context.read<GameProvider>().isPremiumUser) {
    return Future.value();
  }
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.80),
    builder: (_) => const _PremiumUpsellDialog(),
  );
}

class _PremiumUpsellDialog extends StatefulWidget {
  const _PremiumUpsellDialog();

  @override
  State<_PremiumUpsellDialog> createState() => _PremiumUpsellDialogState();
}

class _PremiumUpsellDialogState extends State<_PremiumUpsellDialog> {
  PremiumPlan _plan = PremiumPlan.lifetime;

  // Lifetime is the only real store entitlement. Weekly is presented as an
  // option but currently maps to the same unified premium unlock.
  static const _lifetimeOldPrice = '\$29.99';
  static const _lifetimeNewPrice = '\$9.99';
  static const _weeklyPrice = '\$2.99';

  static const _features = [
    ('removeAds', null, Icons.block_rounded, Color(0xFF71D2FF)),
    (
      'evilModeLabel',
      'evilModeDesc',
      Icons.local_fire_department_rounded,
      Color(0xFFFF3D6E),
    ),
    (
      'spicyModeLabel',
      'spicyDesc',
      Icons.whatshot_rounded,
      Color(0xFFFF5D98),
    ),
    (
      'revengeModeLabel',
      'sendChaosBack',
      Icons.crisis_alert_rounded,
      Color(0xFFFF8A3D),
    ),
    (
      'customRulesLabel',
      'customRulesDesc',
      Icons.sports_esports_rounded,
      Color(0xFFA85BFF),
    ),
    ('exclusiveContent', null, Icons.diamond_rounded, Color(0xFFFFD66B)),
    ('unlimitedChanges', null, Icons.autorenew_rounded, Color(0xFF55F0B0)),
  ];

  Future<void> _purchase() async {
    final provider = context.read<GameProvider>();
    final message = await provider.purchasePremiumLifetime();
    if (!mounted) {
      return;
    }
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    // Close automatically the moment premium becomes active.
    if (provider.isPremiumUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    final lifetimeNow = provider.premiumPriceLabel ?? _lifetimeNewPrice;
    final maxHeight = MediaQuery.of(context).size.height * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF22063B), Color(0xFF2A0A2E), Color(0xFF0E0416)],
            ),
            border: Border.all(
              color: const Color(0xFFA85BFF).withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA85BFF).withValues(alpha: 0.32),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                const Positioned(
                  top: -60,
                  left: -40,
                  child: _GlowBlob(color: Color(0xFFFF3D81), size: 200),
                ),
                const Positioned(
                  top: -30,
                  right: -50,
                  child: _GlowBlob(color: Color(0xFF35E0FF), size: 180),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 44, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _PremiumBadge(),
                      const SizedBox(height: 12),
                      Text(
                        provider.l('unlockChaosPremium'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        provider.l('premiumNoAdsTagline'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ..._features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: _FeatureGlassCard(
                            title: provider.l(f.$1),
                            description: f.$2 == null ? null : provider.l(f.$2!),
                            icon: f.$3,
                            color: f.$4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      PremiumLifetimeCard(
                        selected: _plan == PremiumPlan.lifetime,
                        oldPrice: _lifetimeOldPrice,
                        newPrice: lifetimeNow,
                        onTap: () =>
                            setState(() => _plan = PremiumPlan.lifetime),
                      ),
                      const SizedBox(height: 10),
                      PremiumWeeklyCard(
                        selected: _plan == PremiumPlan.weekly,
                        price: _weeklyPrice,
                        onTap: () => setState(() => _plan = PremiumPlan.weekly),
                      ),
                      const SizedBox(height: 16),
                      _PrimaryCta(
                        label: provider.premiumPurchaseInProgress
                            ? provider.l('unlockingPremium')
                            : provider.l(
                                _plan == PremiumPlan.lifetime
                                    ? 'unlockForever'
                                    : 'startWeeklyPlan',
                              ),
                        busy: provider.premiumPurchaseInProgress,
                        onTap: provider.premiumPurchaseInProgress
                            ? null
                            : _purchase,
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD66B),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            provider.l('mostPlayersLifetime'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.60),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _TrustRow(text: provider.l('trustOneTime')),
                      _TrustRow(text: provider.l('trustInstant')),
                      _TrustRow(text: provider.l('trustUpdates')),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          provider.l('maybeLater'),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _CloseButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white.withValues(alpha: 0.85),
          size: 20,
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB157FF), Color(0xFFFF3D81)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3D81).withValues(alpha: 0.55),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        color: Colors.white,
        size: 34,
      ),
    );
  }
}

class _FeatureGlassCard extends StatelessWidget {
  const _FeatureGlassCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.55),
                  color.withValues(alpha: 0.22),
                ],
              ),
              border: Border.all(color: color.withValues(alpha: 0.65)),
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.60),
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.onTap,
    required this.busy,
  });

  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFA85BFF), Color(0xFFD845D7), Color(0xFFFF3D81)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3D81).withValues(alpha: 0.48),
              blurRadius: 24,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF55F0B0),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.70),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.30), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
