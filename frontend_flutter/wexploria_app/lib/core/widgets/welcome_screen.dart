import 'package:flutter/material.dart';
import '../../features/auth/auth_page.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<String> _backgroundImages = [
    'assets/images/welcome1.jpg',
    'assets/images/welcome2.jpg',
    'assets/images/welcome3.jpg',
  ];
  
  int _currentImageIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    debugPrint("DEBUG: WelcomeScreen LOADED - Version with Blue Text");
    _startImageCarousel();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startImageCarousel() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
      });
    });
  }

  void _navigateToAuthPage({bool isSignUp = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthPage(initialIsLogin: !isSignUp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Section image de fond avec dégradé et logo
          Expanded(
            flex: 6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Image de fond animée avec effet de fondu
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey<String>(_backgroundImages[_currentImageIndex]),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_backgroundImages[_currentImageIndex]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                // Dégradé professionnel amélioré
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.0, 0.2, 0.5, 1.0],
                    ),
                  ),
                ),
                
                // Logo et texte au centre
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo avec effet de brillance
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/wexploria_logo2.png',
                          width: 180,
                          height: 180,
                          color: Colors.white,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Texte d'accueil avec animation
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: 1.0,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Live Your Adventure',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicateurs de page
                Positioned(
                  bottom: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_backgroundImages.length, (index) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.5),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          // Section contenu en dessous
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Texte de bienvenue
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: 40, 
                          height: 4, 
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            height: 1.2,
                            fontFamily: 'Inter', // Ensuring font consistency if global theme isn't set
                          ),
                          children: [
                            TextSpan(
                              text: 'Explore. Fly.\n',
                              style: TextStyle(color: Color(0xFF3D8361)), // Palette Green
                            ),
                            TextSpan(
                              text: 'Feel Free.',
                              style: TextStyle(color: Color(0xFF00B4D8)), // Palette Blue
                            ),
                          ],
                        ),
                      ),
                       // Hack to color "Feel Free" blue if not splitting text widgets. 
                       // Better approach: RichText or separate Texts.
                       // Re-implementing with RichText for "Feel Free" color in next iteration if needed, 
                       // or simpler: Just use Green as requested for "Marhba" elsewhere, but here image suggests mixed.
                       // Prompt image show "Explore. Fly." in Green and "Feel Free." in Blue/Cyan.
                       // Let's match the image provided in prompt "Explore. Fly. Feel Free."
                    ],
                  ),
                  
                  Column(
                    children: [
                      const Text(
                        'Discover thrilling outdoor adventures with Wexploria. Your journey to unforgettable experiences starts here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // Boutons d'action
                  Column(
                    children: [
                      // Bouton Start Your Journey
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D5D), // Green
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          onPressed: () => _navigateToAuthPage(isSignUp: false),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Start Your Journey',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    ],
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