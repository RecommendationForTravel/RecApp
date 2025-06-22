import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class TagService {
  static List<String>? _cachedTags;

  // assets 폴더의 CSV 파일에서 태그 목록을 불러오는 함수
  static Future<List<String>> loadTags() async {
    // 이미 로드된 태그가 있으면 캐시된 데이터를 반환하여 성능 향상
    if (_cachedTags != null) {
      return _cachedTags!;
    }

    try {
      // 1. pubspec.yaml에 등록된 CSV 파일을 문자열로 읽어옵니다.
      final rawCsv = await rootBundle.loadString('assets/travel_tags.csv');

      // 2. CSV 문자열을 리스트 형태로 변환합니다.
      final List<List<dynamic>> listData = const CsvToListConverter().convert(rawCsv);

      if (listData.isEmpty) {
        return [];
      }

      // 3. 2차원 리스트를 1차원 문자열 리스트로 변환하고, 데이터를 정제합니다.
      final tags = listData
          .skip(1) // 첫 번째 행(헤더)을 건너뜁니다.
          .expand((row) => row) // 각 행을 하나의 리스트로 펼침
          .map((tag) => tag.toString().trim()) // 각 태그의 공백 제거
      // 비어있지 않고, 숫자만으로 이루어지지 않은 태그만 필터링
          .where((tag) => tag.isNotEmpty && !RegExp(r'^\d+$').hasMatch(tag))
          .toSet() // 중복 제거
          .toList(); // 다시 리스트로 변환

      _cachedTags = tags; // 결과를 캐시에 저장
      return tags;
    } catch (e) {
      print("CSV 태그 로딩 중 오류 발생: $e");
      // 파일 로딩 실패 시 기본 태그 목록 반환
      return ['힐링', '맛집', '가족여행', '커플', '자연'];
    }
  }
}
