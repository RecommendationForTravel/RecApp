// lib/models/place_model.dart
import 'package:flutter_naver_map/flutter_naver_map.dart';

class Place {
  final String placeName;
  final String roadAddressName;
  final double x; // 경도 (longitude)
  final double y; // 위도 (latitude)

  Place({
    required this.placeName,
    required this.roadAddressName,
    required this.x,
    required this.y,
  });

  // Naver Map SDK에서 사용하는 NLatLng 형태로 변환하는 getter
  NLatLng get latLng => NLatLng(y, x);

  // 네이버 지역 검색 API의 응답(JSON)으로부터 Place 객체를 생성하는 factory 생성자
  factory Place.fromNaverSearch(Map<String, dynamic> json) {
    // HTML 태그를 제거하는 정규식
    final RegExp htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

    // mapx, mapy는 WGS84 좌표계의 위경도 값을 1e7배한 정수 문자열로 제공됨
    final double longitude = (double.tryParse(json['mapx'] ?? '0') ?? 0.0) / 1e7;
    final double latitude = (double.tryParse(json['mapy'] ?? '0') ?? 0.0) / 1e7;

    return Place(
      placeName: json['title'].toString().replaceAll(htmlTagRegex, ''),
      roadAddressName: json['roadAddress'] ?? '',
      x: longitude,
      y: latitude,
    );
  }
}
