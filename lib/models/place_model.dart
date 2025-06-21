// lib/models/place_model.dart (수정)
import 'package:flutter_naver_map/flutter_naver_map.dart';

class Place {
  final String placeName;
  final String roadAddressName;
  final double x; // 경도(longitude)
  final double y; // 위도(latitude)

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

    // 네이버 API의 좌표(카텍)는 정수형 문자열로 오므로, double로 파싱해야 합니다.
    // 10,000,000으로 나누어 실제 위경도 값으로 변환하는 로직이 필요할 수 있으나,
    // 네이버 지도 SDK는 카텍 좌표를 직접 사용하지 않으므로, TM128 좌표를 WGS84로 변환해야 합니다.
    // 여기서는 예시로, 네이버 지역검색 API의 mapx, mapy가 경위도 좌표라고 가정하고 진행합니다.
    // 실제 서비스에서는 정확한 좌표계 변환이 필요합니다.// lib/models/place_model.dart (타입 변환 수정)
    // import 'package:flutter_naver_map/flutter_naver_map.dart';
    //
    // class Place {
    //   final String placeName;
    //   final String roadAddressName;
    //   final double x; // 경도(longitude)
    //   final double y; // 위도(latitude)
    //
    //   Place({
    //     required this.placeName,
    //     required this.roadAddressName,
    //     required this.x,
    //     required this.y,
    //   });
    //
    //   NLatLng get latLng => NLatLng(y, x);
    //
    //   // 네이버 지역 검색 API의 응답(JSON)으로부터 Place 객체를 생성하는 factory 생성자
    //   factory Place.fromNaverSearch(Map<String, dynamic> json) {
    //     final RegExp htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    //
    //     // 네이버 검색 API의 좌표는 TM128 좌표계의 문자열로 제공됩니다.
    //     // NaverMap SDK는 위경도(WGS84) 좌표계를 사용하므로, 변환이 필요합니다.
    //     // NLatLng.fromNaverGeocoding(x, y)를 사용하여 변환할 수 있으나,
    //     // 여기서는 우선 API에서 받은 값을 double로 파싱하여 저장합니다.
    //     // 실제 서비스에서는 정확한 좌표계 변환을 고려해야 합니다.
    //     final tm128 = NLatLng(
    //       double.tryParse(json['mapy'] ?? '0') ?? 0.0,
    //       double.tryParse(json['mapx'] ?? '0') ?? 0.0
    //     );
    //
    //     // TM128 좌표를 위경도(WGS84)로 변환합니다.
    //     // (이 예제에서는 변환 로직을 가정하고 tm128 값을 그대로 사용합니다.
    //     // 실제로는 toWGS84()와 같은 변환 메서드가 필요할 수 있습니다.)
    //     final wgs84 = tm128; // TODO: 실제 좌표계 변환 로직 적용 필요
    //
    //     return Place(
    //       placeName: json['title'].toString().replaceAll(htmlTagRegex, ''),
    //       roadAddressName: json['roadAddress'] ?? '',
    //       x: wgs84.longitude, // 변환된 경도 값
    //       y: wgs84.latitude,  // 변환된 위도 값
    //     );
    //   }
    // }
    return Place(
      placeName: json['title'].toString().replaceAll(htmlTagRegex, ''),
      roadAddressName: json['roadAddress'] ?? '',
      // 문자열 좌표를 double로 안전하게 파싱
      x: double.tryParse(json['mapx'] ?? '0') ?? 0.0,
      y: double.tryParse(json['mapy'] ?? '0') ?? 0.0,
    );
  }
}
