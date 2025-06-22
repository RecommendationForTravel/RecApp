import 'package:flutter/material.dart';

import 'login_page.dart';

class MyPageScreen extends StatelessWidget {

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaceholderScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이 페이지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 20),
          // 프로필 정보 섹션 (이미지에는 없지만 일반적으로 포함됨)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                  // backgroundImage: NetworkImage('사용자 프로필 이미지 URL'), // 실제 이미지 URL
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용자 이름', // 실제 사용자 이름
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'user_email@example.com', // 실제 사용자 이메일
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(),
          // ListTile(
          //   leading: Icon(Icons.edit_outlined, color: Colors.teal),
          //   title: Text('내 정보 수정'),
          //   trailing: Icon(Icons.chevron_right),
          //   onTap: () => _navigateToPlaceholder(context, '내 정보 수정'),
          // ),
          ListTile(
            leading: Icon(Icons.article_outlined, color: Colors.teal),
            title: Text('내가 쓴 피드'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _navigateToPlaceholder(context, '내가 쓴 피드'),
          ),
          // ListTile(
          //   leading: Icon(Icons.history_outlined, color: Colors.teal),
          //   title: Text('추천 받은 기록'),
          //   trailing: Icon(Icons.chevron_right),
          //   onTap: () => _navigateToPlaceholder(context, '추천 받은 기록'),
          // ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text('로그아웃'),
            onTap: () {
              // 로그아웃 처리
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('로그아웃'),
                    content: Text('정말로 로그아웃 하시겠습니까?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('취소'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
                        onPressed: () {
                          // 로그인 화면으로 이동하고 이전의 모든 화면을 스택에서 제거
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                                (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// 임시 페이지 위젯 (이 부분이 누락되었을 가능성이 있습니다)
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: TextStyle(fontSize: 24))),
    );
  }
}
