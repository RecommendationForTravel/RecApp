// lib/services/naver_api_service.dart (수정)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rectrip/models/place_model.dart';

class NaverApiService {
  // 중요: 네이버 개발자 센터에서 발급받은 '검색' API용 키를 입력하세요.
  static const String _clientId = 'gvcRqGbazMQVxp6RpzON';
  static const String _clientSecret = 'x3kOD5Oc9l';
  static const String _baseUrl = 'https://openapi.naver.com/v1/search/local.json';

  Future<List<Place>> searchByKeyword(String query) async {
    if (_clientId == 'YOUR_NAVER_SEARCH_CLIENT_ID' || _clientSecret == 'YOUR_NAVER_SEARCH_CLIENT_SECRET') {
      throw Exception('Naver 검색 API 키(Client ID, Client Secret)를 설정해주세요.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}&display=10'), // 검색 결과 10개로 늘림
      headers: {
        'X-Naver-Client-Id': _clientId,
        'X-Naver-Client-Secret': _clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];

      return items.map((item) {
        // --- 에러 수정 부분 ---
        // Place.fromNaverSearch factory 생성자를 사용하여 객체를 생성합니다.
        // 이 생성자 안에서 문자열을 double로 변환하는 로직이 처리됩니다.
        return Place.fromNaverSearch(item);
      }).toList();
    } else {
      print('네이버 API 에러: ${response.body}');
      throw Exception('장소 검색에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }
}
