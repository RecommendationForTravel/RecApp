// lib/providers/recommendation_provider.dart
import 'package:flutter/material.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/services/recommendation_service.dart';

// 저장된 추천 여행 모델
class SavedTrip {
  final String title;
  final List<Place> route;
  SavedTrip({required this.title, required this.route});
}

class RecommendationProvider with ChangeNotifier {
  final RecommendationService _service = RecommendationService();

  // 현재 진행중인 추천 데이터
  Map<DateTime, List<Place>> _itinerary = {};
  bool _isLoading = false;

  // 최종 저장된 추천 여행 목록
  List<SavedTrip> _savedTrips = [];

  Map<DateTime, List<Place>> get itinerary => _itinerary;
  bool get isLoading => _isLoading;
  List<SavedTrip> get savedTrips => _savedTrips;

  // 서버로부터 추천 데이터를 가져와 상태를 업데이트
  Future<void> fetchRecommendations({
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required String theme,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // RecommendationService에서 반환된 맵을 직접 저장
      _itinerary = (await _service.getRecommendations(
        location: location,
        startDate: startDate,
        endDate: endDate,
        theme: theme,
      )).cast<DateTime, List<Place>>();
    } catch (e) {
      print(e);
      // 에러 처리 로직
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 최종 경로를 저장하는 함수
  void saveFinalTrip(String title, List<Place> route) {
    _savedTrips.add(SavedTrip(title: title, route: route));
    notifyListeners();
    print("'${title}' 여행이 저장되었습니다.");
  }

  // 상태 초기화
  void clear() {
    _itinerary = {};
    notifyListeners();
  }
}