import 'package:flutter/material.dart';
// 회원가입 페이지를 import 합니다.
// import 'signup_page.dart'; // SignUpPage 경로에 맞게 수정

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('로그인')), // 디자인에 따라 앱바 유무 결정
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.15), // 화면 상단 여백
              Text(
                '로그인',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  hintText: '아이디를 입력하세요',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 로그인 로직
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인 시도... (구현 필요)')),
                      );
                      // 예: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
                    }
                  },
                  child: Text('로그인'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  )
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // 회원가입 페이지로 이동
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('회원가입 페이지로 이동 (구현 필요)')),
                  );
                },
                child: Text(
                  '회원가입',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
