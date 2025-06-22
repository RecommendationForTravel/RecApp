import 'package:flutter/material.dart';
import 'package:rectrip/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  void _handleSignUp() async {
    // 모든 validation을 통과하면
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // AuthService를 통해 서버에 회원가입 요청
      final success = await _authService.signup(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        nickname: _nicknameController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) { // 위젯이 여전히 화면에 있는지 확인
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입이 완료되었습니다! 로그인해주세요.')),
          );
          Navigator.pop(context); // 회원가입 성공 시 로그인 화면으로 복귀
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입에 실패했습니다. 입력 정보를 확인해주세요.')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _usernameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 사용자 이름 (실명)
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '사용자 이름',
                  hintText: '실명을 입력하세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '사용자 이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 닉네임
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '앱에서 사용할 별명을 입력하세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 이메일
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일 (아이디)',
                  hintText: '이메일 주소를 입력하세요',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return '올바른 이메일 형식을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // TODO: 이메일 중복 확인 기능 구현
              // OutlinedButton(
              //   onPressed: _checkEmailDuplicate,
              //   child: const Text('이메일 중복 확인'),
              // ),
              const SizedBox(height: 16),

              // 비밀번호
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 비밀번호 확인
              TextFormField(
                controller: _passwordConfirmController,
                decoration: const InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // 회원가입 버튼
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
