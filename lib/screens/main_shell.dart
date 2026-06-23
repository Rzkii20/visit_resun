import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'home_screen.dart';
import 'wisata_tab.dart';
import 'homestay_screen.dart';
import 'suvenir_screen.dart';
import 'profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => MainNavigationShellState();
}

class MainNavigationShellState extends State<MainNavigationShell>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final List<AnimationController> _tapControllers;
  late final List<Animation<double>> _tapAnimations;

  void setTabIndex(int index) {
    if (index >= 0 && index < _pages.length) {
      _onTabTapped(index);
    }
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const WisataTab(),
      const HomestayScreen(),
      const SuvenirScreen(),
      const ProfileScreen(),
    ];

    // Create tap bounce animation controllers for each tab
    _tapControllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        reverseDuration: const Duration(milliseconds: 200),
      );
    });

    _tapAnimations = _tapControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var c in _tapControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    // Play bounce animation
    _tapControllers[index].forward().then((_) {
      _tapControllers[index].reverse();
    });

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final icons = [
                Icons.home_rounded,
                Icons.forest_rounded,
                Icons.holiday_village_rounded,
                Icons.card_giftcard_rounded,
                Icons.person_rounded,
              ];
              final labels = [
                'Beranda',
                'Wisata',
                'Homestay',
                'Suvenir',
                'Profil',
              ];
              return _buildNavItem(index, icons[index], labels[index]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return ScaleTransition(
      scale: _tapAnimations[index],
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppConfig.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon with size & color transition
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isSelected ? 20 : 22,
                  end: isSelected ? 22 : 20,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, size, child) {
                  return Icon(
                    icon,
                    color: isSelected
                        ? AppConfig.primaryColor
                        : Colors.grey.shade400,
                    size: size,
                  );
                },
              ),
              // Animated text appearance
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.3, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              label,
                              key: ValueKey<String>('label_$index'),
                              style: const TextStyle(
                                color: AppConfig.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
