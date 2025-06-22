// lib/screens/splash_screen.dart (신규 파일)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rectrip/screens/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후에 로그인 페이지로 이동합니다.
    Timer(const Duration(seconds: 3), () {
      if (mounted) { // 위젯이 여전히 마운트 상태인지 확인
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // 앱의 메인 색상과 통일
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 아이콘
            Icon(
              Icons.map_outlined,
              size: 100.0,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            // 앱 이름
            Text(
              '어디가담',
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                // GmarketSans 폰트가 적용되면 더 예쁘게 보입니다. (아래 3단계 참고)
              ),
            ),
            const SizedBox(height: 12),
            // 앱 슬로건
            Text(
              'AI와 함께 떠나는 똑똑한 여행',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white.withOpacity(0.8),
              ),
            )
          ],
        ),
      ),
    );
  }
}
