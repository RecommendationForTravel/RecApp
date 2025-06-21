// lib/services/naver_api_service.dart (신규 파일)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rectrip/models/place_model.dart';

class NaverApiService {
  // 중요: 1단계에서 발급받은 본인의 네이버 API 키를 여기에 입력하세요.
  static const String _clientId = 'YOUR_NAVER_CLIENT_ID';
  static const String _clientSecret = 'YOUR_NAVER_CLIENT_SECRET';
  static const String _baseUrl = 'https://openapi.naver.com/v1/search/local.json';

  Future<List<Place>> searchByKeyword(String query) async {
    if (_clientId == 'YOUR_NAVER_CLIENT_ID' || _clientSecret == 'YOUR_NAVER_CLIENT_SECRET') {
      // 개발자에게 API 키 설정을 상기시킵니다.
      throw Exception('Naver API 키(Client ID, Client Secret)를 설정해주세요.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}&display=5'), // 최대 5개까지 결과 표시
      headers: {
        'X-Naver-Client-Id': _clientId,
        'X-Naver-Client-Secret': _clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];

      // HTML 태그를 제거하는 정규식
      final RegExp htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

      return items.map((item) {
        // 네이버 API의 좌표(카텍)를 Place 모델의 x, y로 매핑합니다.
        // 실제 서비스에서는 좌표계 변환이 필요할 수 있습니다.
        return Place(
          placeName: item['title'].toString().replaceAll(htmlTagRegex, ''), // HTML 태그 제거
          roadAddressName: item['roadAddress'] ?? '',
          x: item['mapx'] ?? '0',
          y: item['mapy'] ?? '0',
        );
      }).toList();
    } else {
      // 에러 발생 시, 응답 본문을 출력하여 원인 파악을 돕습니다.
      print('네이버 API 에러: ${response.body}');
      throw Exception('장소 검색에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }
}
