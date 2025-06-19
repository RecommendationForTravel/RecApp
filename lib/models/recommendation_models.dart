// lib/models/recommendation_models.dart
import 'package:flutter/foundation.dart';

// 장소 모델
class Place {
  final String id;
  final String name;
  final String address;
  // 위도, 경도 등 추가 정보 필요시 정의
  // final double latitude;
  // final double longitude;

  Place({required this.id, required this.name, required this.address});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}

// 일일 일정 모델
class DailyItinerary {
  final DateTime date;
  Map<String, List<Place>> placesByCategory; // "카페", "식당" 등 카테고리별 장소 리스트

  DailyItinerary({required this.date, required this.placesByCategory});
}