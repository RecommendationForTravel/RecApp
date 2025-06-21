// lib/providers/recommendation_provider.dart
import 'package:flutter/material.dart';
import 'package:rectrip/models/recommendation_models.dart';
import 'package:rectrip/services/recommendation_service.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService _service = RecommendationService();

  // DateTime? _selectedDay;
  // Map<DateTime, List<String>> _events = {};
  //
  // DateTime? get selectedDay => _selectedDay;
  // Map<DateTime, List<String>> get events => _events;
  //
  // void setSelectedDay(DateTime day) {
  //   _selectedDay = day;
  //   notifyListeners();
  // }
  //
  // void addEvent(DateTime day, String event) {
  //   if (_events[day] != null) {
  //     _events[day]!.add(event);
  //   } else {
  //     _events[day] = [event];
  //   }
  //   notifyListeners();
  // }

  List<DailyItinerary> _itineraries = [];
  bool _isLoading = false;

  List<DailyItinerary> get itineraries => _itineraries;
  bool get isLoading => _isLoading;

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
      _itineraries = await _service.getRecommendations(
        location: location,
        startDate: startDate,
        endDate: endDate,
        theme: theme,
      );
    } catch (e) {
      print(e);
      // 에러 처리 로직
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 장소 추가
  void addPlace(DateTime date, String category, Place place) {
    final day = _itineraries.firstWhere((it) => it.date == date);
    if (day.placesByCategory.containsKey(category)) {
      day.placesByCategory[category]!.add(place);
    } else {
      day.placesByCategory[category] = [place];
    }
    _service.updateItinerary(action: 'add', date: date, category: category, place: place);
    notifyListeners();
  }

  // 장소 삭제
  void removePlace(DateTime date, String category, Place place) {
    final day = _itineraries.firstWhere((it) => it.date == date);
    day.placesByCategory[category]?.remove(place);
    _service.updateItinerary(action: 'remove', date: date, category: category, place: place);
    notifyListeners();
  }

  // 상태 초기화
  void clear() {
    _itineraries = [];
    notifyListeners();
  }
}