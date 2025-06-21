// recommendationfortravel/recapp/RecApp-2107ce38db758b02ee3cf415ae47987f7c68209a/lib/main.dart
import 'package:flutter/material.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
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
      home: LoginPage(), // 앱 시작 시 로그인 페이지를 먼저 보여줍니다.
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    FeedPage(),
    SurveyStartPage(), // 추천 시작 화면으로 변경
    Container(), // 등록 버튼은 별도 처리
    SavedTripsPage(), // 저장된 여행 화면
    MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // 등록 탭을 누르면, 새 게시물 작성 화면으로 이동 (Modal)
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