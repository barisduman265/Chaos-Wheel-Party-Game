import 'package:chaos_wheel/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Premium purchase plans shown across the upsell pop-up and the premium screen.
enum PremiumPlan { lifetime, weekly }

/// Dominant lifetime plan card (discounted, "best value", selected by default).
class PremiumLifetimeCard extends StatelessWidget {
  const PremiumLifetimeCard({
    super.key,
    required this.selected,
    required this.oldPrice,
    required this.newPrice,
    required this.onTap,
  });

  final bool selected;
  final String oldPrice;
  final String newPrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected
                    ? [
                        const Color(0xFFA85BFF).withValues(alpha: 0.45),
                        const Color(0xFFFF3D81).withValues(alpha: 0.32),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.02),
                      ],
              ),
              border: Border.all(
                color: selected
                    ? const Color(0xFFFF6AB0)
                    : Colors.white.withValues(alpha: 0.16),
                width: selected ? 2.2 : 1.4,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF3D81).withValues(alpha: 0.40),
                        blurRadius: 26,
                        offset: const Offset(0, 11),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      provider.l('lifetimePremium'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    PremiumSelectDot(selected: selected),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      newPrice,
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        oldPrice,
                        style: GoogleFonts.nunitoSans(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(0xFFFF6AB0),
                          decorationThickness: 2.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: const Color(0xFF55F0B0).withValues(alpha: 0.22),
                        border: Border.all(
                          color: const Color(0xFF55F0B0).withValues(alpha: 0.7),
                        ),
                      ),
                      child: Text(
                        provider.l('discountBadge'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF7DFFC8),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.l('onePaymentForever'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -10,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC44D), Color(0xFFFF7B4D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7B4D).withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.l('bestValue'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Smaller, lower-emphasis weekly plan card.
class PremiumWeeklyCard extends StatelessWidget {
  const PremiumWeeklyCard({
    super.key,
    required this.selected,
    required this.price,
    required this.onTap,
  });

  final bool selected;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? const Color(0xFF6D8BFF).withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.035),
          border: Border.all(
            color: selected
                ? const Color(0xFF6D8BFF)
                : Colors.white.withValues(alpha: 0.12),
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            PremiumSelectDot(selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.l('weeklyPremium'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    provider.l('weeklyPlanDesc'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: provider.l('perWeek'),
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

class PremiumSelectDot extends StatelessWidget {
  const PremiumSelectDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFFFF6AB0) : Colors.transparent,
        border: Border.all(
          color: selected
              ? const Color(0xFFFF6AB0)
              : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }
}
