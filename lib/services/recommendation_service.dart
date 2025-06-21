// lib/services/recommendation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rectrip/models/place_model.dart';
import 'package:intl/intl.dart';

class RecommendationService {
  // 실제 백엔드 서버 주소로 변경해야 합니다.
  final String _baseUrl = "https://your-python-server.com/api";

  // 설문조사 결과를 보내고 일자별 추천 장소 목록을 받는 함수
  Future<Map<DateTime, List<Place>>> getRecommendations({
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
    print("백엔드로 추천 요청 전송 (시뮬레이션)");
    await Future.delayed(Duration(seconds: 1)); // 통신 시간 흉내
    print("백엔드로부터 추천 데이터 수신 (시뮬레이션)");

    // 날짜별로 장소 목록을 생성
    final Map<DateTime, List<Place>> recommendations = {};
    int totalDays = endDate.difference(startDate).inDays + 1;

    for (int i = 0; i < totalDays; i++) {
      final date = startDate.add(Duration(days: i));
      recommendations[date] = [
        Place(placeName: '${location}의 명소 ${i+1}', roadAddressName: '추천 주소 ${i+1}-1', x: '127.0', y: '37.5'),
        Place(placeName: '${theme} 맛집 ${i+1}', roadAddressName: '추천 주소 ${i+1}-2', x: '127.1', y: '37.6'),
        Place(placeName: '추천 카페 ${i+1}', roadAddressName: '추천 주소 ${i+1}-3', x: '127.2', y: '37.7'),
      ];
    }
    return recommendations;
  }

  // 장소 변동 사항을 서버에 알리는 함수
  Future<void> updateItinerary({
    required String action, // "add" or "remove"
    required DateTime date,
    required String category,
    required Place place,
  }) async {
    //print("백엔드 업데이트: ${action}, ${date}, ${category}, ${place.name}");
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