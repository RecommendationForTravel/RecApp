import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: Colors.transparent, // 앱바 배경 투명
        elevation: 0, // 앱바 그림자 제거
        iconTheme: IconThemeData(color: Colors.black), // 뒤로가기 버튼 색상
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold), // 제목 스타일
      ),
      body: SingleChildScrollView( // 내용이 길어질 경우 스크롤 가능하도록
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 40),
              Text(
                '회원가입',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  hintText: '아이디를 입력하세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 아이디 중복 확인 로직
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('아이디 중복 확인 기능 (구현 필요)')),
                  );
                },
                child: Text('아이디 중복 확인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black54,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordConfirmController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  hintText: '비밀번호를 다시 입력하세요',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요.';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 회원가입 로직
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('회원가입 처리중... (구현 필요)')),
                      );
                      // 예: Navigator.pop(context); // 회원가입 성공 후 이전 화면으로
                    }
                  },
                  child: Text('회원가입'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
