import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const LifeBoardApp(),
    ),
  );
}

class LifeBoardApp extends StatelessWidget {
  const LifeBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeBoard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

// ─── SPLASH SCREEN ───────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2000));

    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)));

    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));

    _slide = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0x204FFFB0),
                    Color(0x107C6FFF),
                    AppTheme.bg,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        gradient: AppGradients.greenPurple,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.green.withOpacity(0.4),
                            blurRadius: 40, spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('⬡', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fade,
                    child: Transform.translate(
                      offset: Offset(0, _slide.value),
                      child: Column(children: [
                        ShaderMask(
                          shaderCallback: (r) => AppGradients.greenPurple.createShader(r),
                          child: Text('LifeBoard',
                            style: AppText.displayLarge.copyWith(
                              fontSize: 40, color: Colors.white)),
                        ),
                        const SizedBox(height: 8),
                        Text('Your Personal Life OS',
                          style: AppText.label.copyWith(
                            fontSize: 14, letterSpacing: 1.5)),
                        const SizedBox(height: 40),
                        // Loading dots
                        Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
                          final anim = Tween<double>(begin: 0.3, end: 1.0).animate(
                            CurvedAnimation(parent: _ctrl,
                              curve: Interval(0.6 + i * 0.1, 0.9 + i * 0.05,
                                  curve: Curves.easeInOut)));
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FadeTransition(
                              opacity: anim,
                              child: Container(
                                width: 6, height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.green, shape: BoxShape.circle),
                              ),
                            ),
                          );
                        })),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Version
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: FadeTransition(
              opacity: _fade,
              child: Text('v2.0.0 · National Hackathon Edition',
                textAlign: TextAlign.center,
                style: AppText.label.copyWith(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
