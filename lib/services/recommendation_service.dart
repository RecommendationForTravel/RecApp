// lib/services/recommendation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rectrip/models/recommendation_models.dart';
import 'package:intl/intl.dart';

class RecommendationService {
  // 실제 백엔드 서버 주소로 변경해야 합니다.
  final String _baseUrl = "https://your-python-server.com/api";

  // 설문조사 결과를 서버로 보내고 추천 결과를 받는 함수
  Future<List<DailyItinerary>> getRecommendations({
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required String theme,
  }) async {
    // ---- 실제 서버 연동 시 아래 주석 해제 ----
    /*
    final response = await http.post(
      Uri.parse('$_baseUrl/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'location': location,
        'startDate': DateFormat('yyyy-MM-dd').format(startDate),
        'endDate': DateFormat('yyyy-MM-dd').format(endDate),
        'theme': theme,
      }),
    );

    if (response.statusCode == 200) {
      // 서버 응답 파싱 로직 (서버 데이터 구조에 맞게 수정 필요)
      // List<dynamic> data = jsonDecode(response.body)['itinerary'];
      // return data.map((item) => ...).toList();
    } else {
      throw Exception('Failed to load recommendations');
    }
    */

    // ---- Mock 데이터 (서버 개발 전 테스트용) ----
    await Future.delayed(Duration(seconds: 1)); // 통신 시간 흉내
    return [
      DailyItinerary(
        date: DateTime(2025, 5, 5),
        placesByCategory: {
          "카페": [Place(id: 'c1', name: '가상 카페 1호점', address: '서울시 강남구')],
          "명소": [Place(id: 'l1', name: '가상 명소', address: '서울시 강남구')],
          "식당": [Place(id: 'r1', name: '가상 식당', address: '서울시 강남구')],
        },
      ),
      DailyItinerary(
        date: DateTime(2025, 5, 6),
        placesByCategory: {
          "카페": [Place(id: 'c2', name: '가상 카페 2호점', address: '서울시 강남구')],
          "숙소": [Place(id: 'h1', name: '가상 호텔', address: '서울시 강남구')],
        },
      ),
    ];
  }

  // 장소 변동 사항을 서버에 알리는 함수
  Future<void> updateItinerary({
    required String action, // "add" or "remove"
    required DateTime date,
    required String category,
    required Place place,
  }) async {
    print("백엔드 업데이트: ${action}, ${date}, ${category}, ${place.name}");
    // ---- 실제 서버 연동 로직 ----
    /*
    await http.post(
      Uri.parse('$_baseUrl/update-itinerary'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({ ... }),
    );
    */
    await Future.delayed(Duration(milliseconds: 200));
  }
}