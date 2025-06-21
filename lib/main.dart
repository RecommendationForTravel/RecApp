// lib/main.dart (지도 초기화 오류 수정)
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart'; // 네이버 지도 패키지 import
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:rectrip/providers/recommendation_provider.dart';
import 'package:rectrip/screens/feed/feed_create_page.dart';
import 'package:rectrip/screens/login_page.dart';
import 'package:rectrip/screens/my_page.dart';
import 'package:rectrip/screens/feed_page.dart';
import 'package:rectrip/screens/recommendation/survey_start_page.dart';
import 'package:rectrip/screens/saved_trips_page.dart';

void main() async {
  // Flutter 엔진과 위젯 바인딩을 보장합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 국제화(날짜 형식 등)를 위해 초기화합니다.
  await initializeDateFormatting('ko_KR', null);

  // --- 지도 SDK 초기화 코드 수정 ---
  // runApp()을 호출하기 전에 반드시 SDK를 초기화해야 합니다.
  await NaverMapSdk.instance.initialize(
    clientId: 'aer59x7hpo', // 네이버 클라우드 플랫폼에서 발급받은 클라이언트 ID를 입력하세요.
    onAuthFailed: (ex) {
      // 인증 실패 시 로그를 출력합니다. (디버깅용)
      print("********* 네이버맵 인증 오류 : $ex *********");
    },
  );
  // --- 초기화 코드 끝 ---

  runApp(
    ChangeNotifierProvider(
      create: (context) => RecommendationProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '여행 앱',
      theme: ThemeData(
        // ... (기존 테마 설정과 동일)
      ),
      home: LoginPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // FeedCreatePage는 Navigator.push로 별도 관리하므로 _widgetOptions에서 제거해도 됩니다.
  static final List<Widget> _widgetOptions = <Widget>[
    FeedPage(),
    SurveyStartPage(),
    Container(), // 등록 버튼용 Placeholder
    SavedTripsPage(),
    MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FeedCreatePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            activeIcon: Icon(Icons.star),
            label: '추천',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: '등록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border_outlined),
            activeIcon: Icon(Icons.bookmark),
            label: '저장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
