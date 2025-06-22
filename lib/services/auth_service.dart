// lib/services/auth_service.dart (신규 파일)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // TODO: 실제 실행 환경에 맞는 백엔드 서버 주소로 변경해주세요.
  //final String _baseUrl = 'http://13.209.97.201:8081';
  final String _baseUrl = 'http://127.0.0.1:8081';
  final _storage = const FlutterSecureStorage();

  // 액세스 토큰을 안전하게 저장하는 함수
  Future<void> _saveAccessToken(String token) async {
    await _storage.write(key: 'accessToken', value: token);
  }

  // 저장된 액세스 토큰을 가져오는 함수
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // 저장된 모든 인증 정보를 삭제하는 함수 (로그아웃 시 사용)
  Future<void> _clearAuthData() async {
    await _storage.deleteAll();
  }

  // 로그인 API 호출
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // 응답 헤더에서 access 토큰 추출
        final accessToken = response.headers['access'];
        if (accessToken != null) {
          await _saveAccessToken(accessToken);
          print("로그인 성공, 토큰 저장 완료: $accessToken");
          return true;
        }
        return false;
      } else {
        print("로그인 실패: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      print("로그인 중 에러 발생: $e");
      return false;
    }
  }

// 회원가입 API 호출 (백엔드 SignUpDto에 맞게 수정)
  Future<bool> signup({
    required String email,
    required String password,
    required String username,
    required String nickname, // nickname 파라미터 추가
  }) async {
    try {
      // TODO: 백엔드의 실제 회원가입 경로로 변경해야 합니다.
      final response = await http.post(
        Uri.parse('$_baseUrl/user/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'nickname': nickname,
          'roles': ['USER'], // 'USER' 역할을 리스트에 담아 전송
        }),
      );

      // 성공 응답 코드 (201, 200 등)를 확인합니다.
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("회원가입 성공");
        return true;
      } else {
        print("회원가입 실패: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      print("회원가입 중 에러 발생: $e");
      return false;
    }
  }

  // 로그아웃 API 호출
  Future<void> logout() async {
    try {
      final token = await getAccessToken();
      // TODO: 실제 로그아웃 API 구현에 따라 수정 필요
      // 백엔드 CustomLogoutFilter는 쿠키의 refresh 토큰을 사용하므로,
      // 클라이언트에서 특별히 보낼 것은 없을 수 있습니다.
      // 하지만 명시적으로 서버에 알리는 것이 좋습니다.
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 인증된 요청임을 알림
        },
      );
    } catch (e) {
      print("로그아웃 중 에러 발생: $e");
    } finally {
      // 성공 여부와 관계없이 클라이언트의 저장된 데이터는 삭제
      await _clearAuthData();
      print("클라이언트 데이터 삭제 완료 (로그아웃)");
    }
  }
}
