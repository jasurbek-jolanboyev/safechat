// home_page.dart — TEZLASHTIRILGAN animatsiyali Premium TabBar (2025 style)
import 'package:safechat/pages/home/tabs/ai_tab.dart';
import 'package:safechat/pages/home/tabs/chat_tab.dart';
import 'package:safechat/pages/home/tabs/explore_tab.dart';
import 'package:safechat/pages/home/tabs/reels_tab.dart';
import 'package:safechat/pages/home/tabs/user_tab.dart';
import 'package:safechat/shared/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int currentTab = 0;
  late PageController _pageController;

  final tabs = [
    const ExploreTab(),
    const ChatTab(),
    const AiTab(),
    const ReelsTab(),
    const ProfileTab(), // yoki
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void goToTab(int index) {
    setState(() => currentTab = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: tabs,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(32),
                border:
                    Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) => _buildNavItem(i)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isActive = currentTab == index;
    final List<IconData> icons = [
      Iconsax.home5,
      Iconsax.message5,
      Icons.smart_toy,
      Iconsax.play_circle,
      Iconsax.profile_circle,
    ];

    final Color activeColor =
        index == 2 ? Colors.deepPurple.shade400 : ColorConstants.primaryColor;

    return GestureDetector(
      onTap: () => goToTab(index),
      child: SizedBox(
        width: 70,
        height: 84,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // TEZ HARAKATLANUVCHI DOIRA (animatsiya 2 baravar tez!)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 380), // oldin 800 edi
              curve: Curves.fastOutSlowIn,
              top: isActive ? 12 : 50,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 420), // oldin 900 edi
                curve: Curves.easeOutCubic,
                width: isActive ? 56 : 0,
                height: isActive ? 56 : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(0.25),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.45),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ),

            // Qo‘shimcha glow (tezroq)
            if (isActive)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500), // oldin 1000 edi
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activeColor.withOpacity(0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

            // IKONKA — HAR DOIM JOYIDA, RANGI TEZ O‘ZGARADI
            AnimatedScale(
              scale: isActive ? 1.05 : 1.0, // kichik mikro-scale qo‘shildi
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icons[index],
                size: 28,
                color: isActive ? activeColor : Colors.white.withOpacity(0.7),
              ),
            ),

            // Kichik indikator nuqta (tez paydo bo‘ladi)
            if (isActive)
              Positioned(
                bottom: 14,
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
