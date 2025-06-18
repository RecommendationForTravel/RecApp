import 'package:flutter/material.dart';
import 'package:rectrip/screens/my_page.dart';

import 'package:rectrip/screens/feed_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '여행 앱',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // 앱의 전체적인 테마 색상
        scaffoldBackgroundColor: Colors.white, // 기본 배경색
        textTheme: TextTheme( // 기본 텍스트 스타일
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // 버튼 스타일
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // 버튼 배경색
              foregroundColor: Colors.white, // 버튼 텍스트색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0)
          ),
        ),
        inputDecorationTheme: InputDecorationTheme( // 입력 필드 스타일
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
        ),
      ),
      home: MainScreen(),
      // 여기에 라우트 설정을 추가하여 다른 페이지로 이동할 수 있습니다.
      // 예: routes: { '/login': (context) => LoginPage(), ... }
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스

  // 각 탭에 해당하는 페이지 위젯 (임시로 Placeholder 사용)
  static List<Widget> _widgetOptions = <Widget>[
    FeedPage(), // 피드 조회 화면
    PlaceholderWidget(title: '추천'), // 추천 화면
    PlaceholderWidget(title: '등록'), // 글 작성 화면 (피드 작성 화면-1)
    PlaceholderWidget(title: '저장'), //저장 여행기 확인
    MyPageScreen(), // 마이 페이지
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // '등록' 탭 (인덱스 2)을 누르면 새 게시물 작성 화면으로 이동하는 로직 추가 가능
      if (index == 2) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => NewPostScreen()));
        // 현재는 PlaceholderWidget이 표시됩니다.
      }
    });
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
        selectedItemColor: Colors.teal, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        showUnselectedLabels: true, // 선택되지 않은 라벨도 표시
        type: BottomNavigationBarType.fixed, // 아이템이 많을 때 고정
        onTap: _onItemTapped,
      ),
    );
  }
}

// 임시 Placeholder 위젯
class PlaceholderWidget extends StatelessWidget {
  final String title;
  PlaceholderWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: TextStyle(fontSize: 24))),
    );
  }
}
