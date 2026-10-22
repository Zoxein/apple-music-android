import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphism_container.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Browse',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Featured banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFA2D48), Color(0xFF8B0000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEW MUSIC',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Today\'s Hits',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'The biggest songs right now',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Listen Now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Categories
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Top Categories',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildListDelegate(_buildCategoryItems()),
            ),
          ),

          // Apple Music Exclusives section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Editor\'s Picks',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _editorPicks.length,
                itemBuilder: (context, index) {
                  final pick = _editorPicks[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                pick['color'] as Color,
                                (pick['color'] as Color).withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              pick['icon'] as IconData,
                              size: 56,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pick['title'] as String,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryItems() {
    final categories = [
      {'label': 'Pop', 'color': const Color(0xFFE91E8C)},
      {'label': 'Hip-Hop', 'color': const Color(0xFFFF6B35)},
      {'label': 'Rock', 'color': const Color(0xFFD32F2F)},
      {'label': 'Electronic', 'color': const Color(0xFF1565C0)},
      {'label': 'R&B/Soul', 'color': const Color(0xFF6A1B9A)},
      {'label': 'Country', 'color': const Color(0xFF5D4037)},
      {'label': 'Jazz', 'color': const Color(0xFF00695C)},
      {'label': 'Classical', 'color': const Color(0xFF283593)},
    ];

    return categories.map((cat) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cat['color'] as Color,
              (cat['color'] as Color).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(14),
        child: Text(
          cat['label'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      );
    }).toList();
  }

  static final List<Map<String, dynamic>> _editorPicks = [
    {
      'title': 'Midnight Vibes',
      'color': const Color(0xFF1A237E),
      'icon': Icons.nightlight_round,
    },
    {
      'title': 'Morning Coffee',
      'color': const Color(0xFF795548),
      'icon': Icons.coffee_rounded,
    },
    {
      'title': 'Workout Beats',
      'color': const Color(0xFFD84315),
      'icon': Icons.fitness_center,
    },
    {
      'title': 'Focus Mode',
      'color': const Color(0xFF1B5E20),
      'icon': Icons.psychology_rounded,
    },
    {
      'title': 'Summer Hits',
      'color': const Color(0xFFF57F17),
      'icon': Icons.wb_sunny_rounded,
    },
  ];
}
