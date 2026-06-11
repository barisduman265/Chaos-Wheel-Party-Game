import 'package:chaos_wheel/providers/game_provider.dart';
import 'package:chaos_wheel/services/share_service.dart';
import 'package:chaos_wheel/widgets/chaos_background.dart';
import 'package:chaos_wheel/widgets/premium_plan_cards.dart';
import 'package:chaos_wheel/widgets/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  static const routeName = '/premium';

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  PremiumPlan _plan = PremiumPlan.lifetime;

  // Lifetime is the only real store entitlement. Weekly is presented as an
  // option but currently maps to the same unified premium unlock.
  static const _lifetimeOldPrice = '\$29.99';
  static const _lifetimeNewPrice = '\$9.99';
  static const _weeklyPrice = '\$2.99';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final isPremium = provider.isPremiumUser;
    final lifetimeNow = provider.premiumPriceLabel ?? _lifetimeNewPrice;

    return Scaffold(
      body: ChaosBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            children: [
              Row(
                children: [
                  _BackBubble(onTap: () => Navigator.maybePop(context)),
                  const Spacer(),
                  Text(
                    provider.l(
                      isPremium ? 'premiumUnlockedTitle' : 'unlockPremiumTitle',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFF3EEFF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 20),
              _HeroPremiumCard(isPremium: isPremium),
              const SizedBox(height: 16),
              _SectionLabel(provider.l('whatYouUnlock')),
              const SizedBox(height: 10),
              _UnlockGrid(isPremium: isPremium),
              const SizedBox(height: 16),
              _SectionLabel(provider.l('livePreview')),
              const SizedBox(height: 10),
              const _PremiumPreview(),
              const SizedBox(height: 18),
              if (!isPremium) ...[
                PremiumLifetimeCard(
                  selected: _plan == PremiumPlan.lifetime,
                  oldPrice: _lifetimeOldPrice,
                  newPrice: lifetimeNow,
                  onTap: () => setState(() => _plan = PremiumPlan.lifetime),
                ),
                const SizedBox(height: 10),
                PremiumWeeklyCard(
                  selected: _plan == PremiumPlan.weekly,
                  price: _weeklyPrice,
                  onTap: () => setState(() => _plan = PremiumPlan.weekly),
                ),
                const SizedBox(height: 14),
              ],
              _PremiumCta(isPremium: isPremium, plan: _plan),
              const SizedBox(height: 12),
              _InviteFriendsButton(
                onTap: () => const ChaosShareService().shareInvite(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPremiumCard extends StatelessWidget {
  const _HeroPremiumCard({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFC44D).withValues(alpha: 0.16),
            const Color(0xFFFF3D81).withValues(alpha: 0.12),
            const Color(0xFFA85BFF).withValues(alpha: 0.13),
            const Color(0xFF12051E).withValues(alpha: 0.78),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFC44D).withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFC44D).withValues(alpha: 0.13),
              border: Border.all(
                color: const Color(0xFFFFC44D).withValues(alpha: 0.38),
              ),
            ),
            child: Icon(
              isPremium ? Icons.workspace_premium_rounded : Icons.lock_rounded,
              color: const Color(0xFFFFC44D),
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            provider.l(isPremium ? 'chaosPremiumYours' : 'unlockChaosPremium'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFF3EEFF),
              fontWeight: FontWeight.w900,
              height: 0.96,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.l(isPremium ? 'premiumLiveSubtitle' : 'premiumTagline'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.62),
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockGrid extends StatelessWidget {
  const _UnlockGrid({required this.isPremium});

  final bool isPremium;

  static const items = [
    ('spicyModeLabel', Icons.whatshot_rounded),
    ('evilModeLabel', Icons.warning_amber_rounded),
    ('customGameLabel', Icons.tune_rounded),
    ('revengeModeLabel', Icons.crisis_alert_rounded),
    ('premiumPromptPacks', Icons.auto_awesome_rounded),
    ('extremeTruthPrompts', Icons.visibility_rounded),
    ('extremeDarePrompts', Icons.bolt_rounded),
    ('extraPromptChanges', Icons.auto_fix_high_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return _PremiumChip(
          label: provider.l(item.$1),
          icon: item.$2,
          unlocked: isPremium,
        );
      }).toList(),
    );
  }
}

class _PremiumPreview extends StatelessWidget {
  const _PremiumPreview();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    return Column(
      children: [
        _PreviewCard(
          title: provider.l('spicyModeLabel'),
          text: provider.l('spicyDesc'),
          icon: Icons.whatshot_rounded,
          color: const Color(0xFFFF5D98),
        ),
        const SizedBox(height: 10),
        _PreviewCard(
          title: provider.l('evilTruthTitle'),
          text: provider.l('evilTruthPreview'),
          icon: Icons.visibility_rounded,
          color: const Color(0xFFFF8A3D),
        ),
        const SizedBox(height: 10),
        _PreviewCard(
          title: provider.l('evilDareTitle'),
          text: provider.l('evilDarePreview'),
          icon: Icons.bolt_rounded,
          color: const Color(0xFFA85BFF),
        ),
        const SizedBox(height: 10),
        _PreviewCard(
          title: provider.l('revengeModeTitle'),
          text: provider.l('revengePreview'),
          icon: Icons.crisis_alert_rounded,
          color: const Color(0xFFFF3D6E),
        ),
      ],
    );
  }
}

class _PremiumCta extends StatelessWidget {
  const _PremiumCta({required this.isPremium, required this.plan});

  final bool isPremium;
  final PremiumPlan plan;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    return PressableScale(
      enabled: !isPremium && !provider.premiumPurchaseInProgress,
      onTap: () async {
        final message = await context
            .read<GameProvider>()
            .purchasePremiumLifetime();
        if (!context.mounted) {
          return;
        }
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          return;
        }
        if (!context.read<GameProvider>().isPremiumUser) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.l('premiumPurchaseStarted'))),
          );
          return;
        }
        await showDialog<void>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.62),
          builder: (_) => const _PremiumSuccessDialog(),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: isPremium
                ? const [Color(0xFF3A2B55), Color(0xFF251637)]
                : const [Color(0xFFFFC44D), Color(0xFFFF3D81)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Icon(
              isPremium ? Icons.check_circle_rounded : Icons.lock_open_rounded,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium
                        ? provider.l('lifetimePremiumActive')
                        : provider.premiumPurchaseInProgress
                        ? provider.l('unlockingPremium')
                        : provider.l(
                            plan == PremiumPlan.lifetime
                                ? 'unlockForever'
                                : 'startWeeklyPlan',
                          ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isPremium
                        ? provider.l('everythingStaysUnlocked')
                        : plan == PremiumPlan.lifetime
                        ? provider.lf('oncePriceForever', {
                            'price': provider.premiumPriceLabel ?? '\$9.99',
                          })
                        : provider.l('weeklyPlanDesc'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumSuccessDialog extends StatelessWidget {
  const _PremiumSuccessDialog();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFF2C143A), Color(0xFF12051E)],
          ),
          border: Border.all(
            color: const Color(0xFFFFC44D).withValues(alpha: 0.38),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.72, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFFFC44D),
                size: 72,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              provider.l('premiumUnlockedDialog'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.l('premiumNowLive'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(provider.l('letChaosIn')),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteFriendsButton extends StatelessWidget {
  const _InviteFriendsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withValues(alpha: 0.055),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(
          context.read<GameProvider>().l('inviteFriends'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.82),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.text,
    required this.icon,
    required this.color,
  });

  final String title;
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.62),
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_rounded, color: color.withValues(alpha: 0.70)),
        ],
      ),
    );
  }
}

class _PremiumChip extends StatelessWidget {
  const _PremiumChip({
    required this.label,
    required this.icon,
    required this.unlocked,
  });

  final String label;
  final IconData icon;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? const Color(0xFF62D8FF) : const Color(0xFFFFC44D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.09),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(unlocked ? Icons.check_rounded : icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.42),
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }
}

class _BackBubble extends StatelessWidget {
  const _BackBubble({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: const Icon(Icons.chevron_left_rounded, color: Colors.white),
      ),
    );
  }
}
