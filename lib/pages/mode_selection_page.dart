import 'package:flutter/material.dart';

import '../app.dart';
import 'configured_dashboard_page.dart';
import 'configured_dashboard_page_v2.dart';

/// Launch screen — lets the user pick between the two chart rendering modes.
class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 56),

              // ── Logo / Title ────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'RFW Dashboard',
                      style: TextStyle(
                        color: Color(0xFFEFEFF4),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a chart rendering mode',
                      style: TextStyle(
                        color: Color(0xFF9A9AB0),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 56),

              // ── Mode Cards ──────────────────────────────────────────────────
              _ModeCard(
                icon: Icons.code_rounded,
                label: 'RFW Charts',
                description:
                    'Widget layout is served by the backend as rfwtxt and rendered via Remote Flutter Widgets.',
                gradientColors: const [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                glowColor: const Color(0xFF6C63FF),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardPage(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _ModeCard(
                icon: Icons.tune_rounded,
                label: 'Configured Charts',
                description:
                    'All chart properties (color, size, labels, curve, dots, etc.) are configured through the backend JSON — no RFW involved.',
                gradientColors: const [Color(0xFF03DAC6), Color(0xFF00897B)],
                glowColor: const Color(0xFF03DAC6),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfiguredDashboardPage(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _ModeCard(
                icon: Icons.auto_awesome_rounded,
                label: 'All 16 Chart Types (V2)',
                description:
                    'All chart types fully dynamic — pie, bar, stack, line, tier, step, dual-axis and more. Every property configured from the backend.',
                gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                glowColor: const Color(0xFFFF6B6B),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfiguredDashboardPageV2(),
                  ),
                ),
              ),

              const Spacer(),

              // ── Footer note ─────────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'All modes use the same backend & database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9A9AB0), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _ModeCard ─────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),

              const SizedBox(width: 18),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFFEFEFF4),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF9A9AB0),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: glowColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
