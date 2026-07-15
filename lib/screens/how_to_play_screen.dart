import 'package:chaos_wheel/providers/game_provider.dart';
import 'package:chaos_wheel/util/drinking_mode.dart';
import 'package:chaos_wheel/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const routeName = '/how-to-play';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
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
                    provider.l('howChaosWorks'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFF3EEFF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                provider.l('howChaosIntro'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFFF3EEFF),
                  fontWeight: FontWeight.w800,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.l('howChaosSubtitle'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.58),
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(provider.l('flow')),
              const SizedBox(height: 10),
              _RuleGrid(
                items: [
                  _RuleItem(
                    icon: Icons.group_add_rounded,
                    title: provider.l('addPlayers'),
                    text: provider.l('addPlayersRule'),
                    color: Color(0xFF62D8FF),
                  ),
                  _RuleItem(
                    icon: Icons.nightlife_rounded,
                    title: provider.l('pickYourVibe'),
                    text: provider.l('pickYourVibeRule'),
                    color: Color(0xFFFF5D98),
                  ),
                  _RuleItem(
                    icon: Icons.cyclone_rounded,
                    title: provider.l('spin'),
                    text: provider.l('spinTheWheelRule'),
                    color: Color(0xFFA85BFF),
                  ),
                  _RuleItem(
                    icon: Icons.bolt_rounded,
                    title: provider.l('truthOrDare'),
                    text: provider.l('truthOrDareRule'),
                    color: Color(0xFFFFC44D),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(provider.l('specialRules')),
              const SizedBox(height: 10),
              _RuleGrid(
                items: [
                  _RuleItem(
                    icon: Icons.gps_fixed_rounded,
                    title: provider.l('target').toUpperCase(),
                    text: provider.l('targetRule'),
                    color: Color(0xFFFF5D98),
                  ),
                  _RuleItem(
                    icon: shotIcon(provider.drinkingModeEnabled),
                    title: provider.l('shot').toUpperCase(),
                    text: provider.l('shotRule'),
                    color: Color(0xFF62D8FF),
                  ),
                  _RuleItem(
                    icon: Icons.link_off_rounded,
                    title: provider.l('noEscape'),
                    text: provider.l('noEscapeRule'),
                    color: Color(0xFFFF3D81),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(provider.l('vibes')),
              const SizedBox(height: 10),
              _InfoCard(
                children: [
                  _VibeRow(
                    title: provider.l('cozy'),
                    text: provider.l('cozyVibeRule'),
                    color: Color(0xFF62D8FF),
                  ),
                  _VibeRow(
                    title: provider.l('spicy'),
                    text: provider.l('spicyVibeRule'),
                    color: Color(0xFFFF5D98),
                  ),
                  _VibeRow(
                    title: provider.l('unhinged'),
                    text: provider.l('unhingedVibeRule'),
                    color: Color(0xFFA85BFF),
                  ),
                  _VibeRow(
                    title: provider.l('evil'),
                    text: provider.l('evilVibeRule'),
                    color: Color(0xFFFFC44D),
                  ),
                ],
              ),
            ],
          ),
        ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.42),
        fontWeight: FontWeight.w900,
        letterSpacing: 3.2,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withValues(alpha: 0.045),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(children: children),
    );
  }
}

class _RuleItem {
  const _RuleItem({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;
}

class _RuleGrid extends StatelessWidget {
  const _RuleGrid({required this.items});

  final List<_RuleItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RuleCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.item});

  final _RuleItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: item.color.withValues(alpha: 0.08),
        border: Border.all(color: item.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.color.withValues(alpha: 0.14),
            ),
            child: Icon(item.icon, color: item.color, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFF3EEFF),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.58),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VibeRow extends StatelessWidget {
  const _VibeRow({
    required this.title,
    required this.text,
    required this.color,
  });

  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
