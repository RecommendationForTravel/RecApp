// lib/models/place_model.dart (신규 파일)
class Place {
  final String placeName;
  final String roadAddressName;
  final String x; // 경도(longitude)
  final String y; // 위도(latitude)

  Place({
    required this.placeName,
    required this.roadAddressName,
    required this.x,
    required this.y,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeName: json['place_name'] ?? '',
      roadAddressName: json['road_address_name'] ?? '',
      x: json['x'] ?? '',
      y: json['y'] ?? '',
    );
  }
}