// lib/services/kakao_api_service.dart (신규 파일)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rectrip/models/place_model.dart';

class KakaoApiService {
  // 중요: 본인의 카카오 REST API 키를 여기에 입력하세요.
  static const String _apiKey = 'YOUR_KAKAO_REST_API_KEY';
  static const String _baseUrl = 'https://dapi.kakao.com/v2/local/search/keyword.json';

  Future<List<Place>> searchByKeyword(String query) async {
    if (_apiKey == 'YOUR_KAKAO_REST_API_KEY') {
      // 개발자에게 API 키 설정을 상기시킵니다.
      throw Exception('Kakao REST API 키를 설정해주세요.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}'),
      headers: {'Authorization': 'KakaoAK $_apiKey'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> documents = data['documents'];
      return documents.map((doc) => Place.fromJson(doc)).toList();
    } else {
      throw Exception('장소 검색에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }
}