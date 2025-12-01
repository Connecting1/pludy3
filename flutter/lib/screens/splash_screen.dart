import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/auth_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../services/auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화 (2초)
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // 페이드 인 애니메이션 (0 → 1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // 스케일 애니메이션 (0.5 → 1.0)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // 애니메이션 시작
    _animationController.forward();

    // 3초 후 로그인 상태 확인 및 화면 전환
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // 3초 대기 (애니메이션 표시)
    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;

    // 로그인 상태 확인
    final isLoggedIn = await AuthService.isLoggedIn();

    print('🔍 스플래시: 로그인 상태 = $isLoggedIn');

    // 로그인된 경우 UserProvider 초기화
    if (isLoggedIn && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.initialize();
    }

    if (!mounted) return;

    // 로그인 상태에 따라 화면 전환
    if (isLoggedIn) {
      // 로그인되어 있으면 메인 화면으로 (AI 채팅 포함)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen()),
      );
    } else {
      // 로그인 안되어 있으면 로그인 화면으로
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 검은색 배경
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지 (다크/라이트 모드 대응)
              Image.asset(
                'assets/images/logo.png', // 사용자가 제공한 로고
                width: 200,
                height: 200,
                // 라이트 모드에서는 색상 반전 (선택사항)
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
              SizedBox(height: 24),
              // 앱 이름 (선택사항)
              Text(
                'Pludy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
