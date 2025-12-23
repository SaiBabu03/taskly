import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Signup_Screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  // 1. Data to rotate through
  final List<Map<String, String>> onboardingData = [
    {
      "title": "Get things done.",
      "subtitle": "Just a click away from\nplanning your tasks.",
    },
    {
      "title": "Stay Organized.",
      "subtitle": "Categorize your work and\nnever miss a deadline.",
    },
    {
      "title": "Reach Goals.",
      "subtitle": "Track your progress and\nachieve your daily targets.",
    },
  ];

  @override
  void initState() {
    super.initState();
    // 2. Timer to auto-scroll every 3.5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (Timer timer) {
      if (_currentPage < onboardingData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Circle
          Positioned(
            bottom: -110,
            right: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFF7E7CF7),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                // --- CENTRAL SECTION WITH 12 DECORATIVE BALLS ---
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative Balls (Total 12)
                        _buildBall(
                          top: 0,
                          left: 50,
                          size: 14,
                          color: Colors.orange.withOpacity(0.3),
                        ),
                        _buildBall(
                          top: 30,
                          right: 40,
                          size: 8,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                        _buildBall(
                          top: 100,
                          left: 10,
                          size: 10,
                          color: Colors.pink.withOpacity(0.2),
                        ),
                        _buildBall(
                          top: 140,
                          right: 10,
                          size: 16,
                          color: Colors.green.withOpacity(0.2),
                        ),
                        _buildBall(
                          bottom: 20,
                          left: 60,
                          size: 12,
                          color: Colors.cyan.withOpacity(0.3),
                        ),
                        _buildBall(
                          bottom: 40,
                          right: 80,
                          size: 9,
                          color: Colors.amber.withOpacity(0.4),
                        ),
                        _buildBall(
                          top: 60,
                          left: 110,
                          size: 7,
                          color: Colors.purple.withOpacity(0.2),
                        ),
                        _buildBall(
                          bottom: 100,
                          right: 20,
                          size: 11,
                          color: Colors.teal.withOpacity(0.2),
                        ),
                        _buildBall(
                          top: 20,
                          left: 20,
                          size: 6,
                          color: Colors.red.withOpacity(0.2),
                        ),
                        _buildBall(
                          bottom: 10,
                          left: 100,
                          size: 15,
                          color: const Color(0xFF7E7CF7).withOpacity(0.2),
                        ),
                        _buildBall(
                          top: 180,
                          left: 30,
                          size: 8,
                          color: Colors.indigo.withOpacity(0.3),
                        ),
                        _buildBall(
                          bottom: 60,
                          left: 10,
                          size: 10,
                          color: Colors.deepOrange.withOpacity(0.2),
                        ),

                        // The Central Card
                        Container(
                          padding: const EdgeInsets.all(35),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E7CF7),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 80,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

SizedBox(height: 100,),
                // --- AUTO-SCROLLING TEXT (PageView) ---
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              onboardingData[index]["title"]!,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              onboardingData[index]["subtitle"]!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // --- THE ANIMATED DOTS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => _buildDot(isActive: _currentPage == index),
                    ),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),

          // Action Button
          Positioned(
            bottom: 50,
            right: 40,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                // 2. Set 'isFirstTime' to false
                await prefs.setBool('isFirstTime', false);
                // 3. Navigate to the next screen (Signup or Main Tasks)
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build positioned decorative balls
  Widget _buildBall({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  // Helper to build smooth animated dots
  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8, // Active dot stretches
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF7E7CF7) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
