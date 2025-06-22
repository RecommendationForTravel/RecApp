// lib/services/main_backend_api_service.dart (수정)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rectrip/screens/feed_page.dart'; // FeedPost 모델
import 'package:rectrip/services/auth_service.dart';

import '../models/place_model.dart'; // 토큰을 가져오기 위해 import

class MainBackendApiService {
  //final String _baseUrl = 'http://13.209.97.201:8081';
  final String _baseUrl = 'http://127.0.0.1:8081';
  final AuthService _authService = AuthService();

  // 공통 헤더를 생성하는 함수
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- getFeeds 함수 수정: POST 방식으로 변경 ---
  Future<List<FeedPost>> getFeeds({int page = 0, int size = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/post/list'),
        headers: headers,
        body: jsonEncode({
          'page': page,
          'size': size,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        // Spring Page 객체의 'content' 필드에서 게시물 목록을 추출
        final List<dynamic> content = body['content'];
        return content.map((json) => FeedPost.fromJson(json)).toList();
      } else {
        throw Exception(
            '피드 목록 로딩 실패: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print("getFeeds 에러: $e");
      throw Exception('피드 목록을 불러오는 중 오류가 발생했습니다.');
    }
  }

  // --- 2. 태그로 피드 검색하기 ---
  Future<List<FeedPost>> getFeedsByTag({required List<String> tags, int page = 0, int size = 10}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/post/getPostListByTag'),
      headers: headers,
      body: jsonEncode({'page': page, 'size': size, 'tags': tags}),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      // 백엔드 응답이 Page가 아닌 List<ArticleDto>이므로 직접 파싱
      return (body as List)
          .map((json) => FeedPost.fromJson(json))
          .toList();
    }
    throw Exception('태그 검색 실패: ${response.statusCode}');
  }

  // --- 상세 피드 정보를 가져오는 함수 수정 ---
  Future<List<DailyLog>> getFeedDetail(int postId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/post/getPostDetail'),
      headers: headers,
      body: jsonEncode({'postId': postId}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));

      // 백엔드 ArticleDetailDto의 각 List들을 조합하여 DailyLog 객체 리스트를 생성
      List<DailyLog> logs = [];
      final visitDates = List<String>.from(json['visitDateList'] ?? []);
      final placeNames = List<String>.from(json['placeList'] ?? []);
      final comments = List<String>.from(json['comment'] ?? []);
      final costs = List<int>.from(json['cost'] ?? []);
      final transportations = List<String>.from(json['transportationList'] ?? []);
      final locations = List<Map<String, dynamic>>.from(json['placeLocationList'] ?? []);

      for (int i = 0; i < visitDates.length; i++) {
        final placeName = placeNames.length > i ? placeNames[i] : '장소 정보 없음';
        final locationData = locations.length > i ? locations[i] : {'longitude': 0.0, 'latitude': 0.0};

        logs.add(DailyLog(
          date: visitDates[i],
          placeName: placeName,
          comment: comments.length > i ? comments[i] : '',
          cost: costs.length > i ? costs[i] : 0,
          transportation: transportations.length > i ? transportations[i] : 'ETC',
          location: Place(
            placeName: placeName,
            roadAddressName: '', // 상세 DTO에는 도로명 주소 정보가 없음
            x: (locationData['longitude'] ?? 0.0).toDouble(),
            y: (locationData['latitude'] ?? 0.0).toDouble(),
          ),
        ));
      }
      return logs;
    } else {
      throw Exception('상세 피드 로딩 실패: ${response.statusCode}');
    }
  }

  // --- 게시글 등록 기능 ---
  // Flutter UI에서 수집한 데이터를 PublishDto 형식에 맞게 전송
  Future<bool> publishPost(Map<String, dynamic> postData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/post/publish'),
        headers: headers,
        body: jsonEncode(postData),
      );
      if (response.statusCode == 200) {
        print("게시글 등록 성공: ${response.body}");
        return true;
      } else {
        print("게시글 등록 실패: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      print("publishPost 에러: $e");
      return false;
    }
  }

  // --- 3. 저장한(좋아요 누른) 피드 목록 가져오기 ---
  Future<List<FeedPost>> getLikedFeeds() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/post/likePostList'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return (body as List)
          .map((json) => FeedPost.fromJson(json))
          .toList();
    }
    throw Exception('저장된 피드 목록 로딩 실패: ${response.statusCode}');
  }

  // --- '좋아요' 기능 ---
  Future<bool> likePost(int postId, String title) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/post/like'),
        headers: headers,
        body: jsonEncode({
          'postId': postId,
          'title': title,
        }),
      );
      if (response.statusCode == 200) {
        print("Post $postId liked successfully.");
        return true;
      } else {
        print("Like post 실패: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      print("likePost 에러: $e");
      return false;
    }
  }

  //태그 목록 가져오기
  Future<List<String>> getTagList() async {
    try {
      final headers = await _getHeaders();
      // 이 API는 인증이 필요 없을 수 있으므로, 기본 헤더만 사용합니다.
      final response = await http.post(
        Uri.parse('$_baseUrl/post/getTagList'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

        // --- 핵심 수정 부분: null 값을 안전하게 처리 ---
        // 1. body 리스트의 각 요소를 순회합니다.
        // 2. 각 요소가 null이 아니면 toString()으로 문자열로 변환합니다.
        // 3. null인 요소는 이 과정에서 제외됩니다.
        return body
            .where((tag) => tag != null)
            .map((tag) => tag.toString())
            .toList();
      } else {
        throw Exception('태그 목록 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("getTagList 에러: $e");
      // API 호출 실패 시, 비상용 기본 태그 목록 반환
      return ['등산', '산책', '가족단위', '데이트코스', '자연'];
    }
  }

  // --- 내가 쓴 게시글 목록을 가져오는 함수 추가 ---
  Future<List<FeedPost>> getMyPosts() async {
    try {
      final headers = await _getHeaders();
      // 백엔드 명세에 따라 POST 방식으로 /myposts 호출
      final response = await http.post(
        Uri.parse('$_baseUrl/post/myposts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        // 응답받은 List<ArticleDto>를 List<FeedPost>로 변환
        return body.map((json) => FeedPost.fromJson(json)).toList();
      } else {
        throw Exception('내가 쓴 글 목록 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("getMyPosts 에러: $e");
      throw Exception('내가 쓴 글 목록을 불러오는 중 오류가 발생했습니다.');
    }
  }

  Future<List<Place>> getOptimizedRoute(List<Place> finalPlaces) async {
    /*
    // ===== 실제 서버 연동 시 주석 해제 =====
    final url = Uri.parse('YOUR_MAIN_BACKEND_URL/route');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'places': finalPlaces.map((p) => {
          'placeName': p.placeName,
          'roadAddressName': p.roadAddressName,
          'x': p.x,
          'y': p.y,
        }).toList(),
      }),
    );
    if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> documents = data['optimizedRoute'];
        return documents.map((doc) => Place.fromJson(doc)).toList();
    } else {
        throw Exception('최적화된 경로를 받아오는데 실패했습니다.');
    }
    */

    // --- 더미 데이터 반환 ---
    print("메인 백엔드로 최종 장소 리스트 전송 (시뮬레이션)");
    await Future.delayed(Duration(seconds: 1));
    print("메인 백엔드로부터 최적 경로 수신 (시뮬레이션)");

    // 서버가 경로를 재정렬했다고 가정 (서울역 -> N서울타워 순서)
    // 리스트의 순서가 서버가 정해준 경로가 됩니다.
    return finalPlaces.reversed.toList();
  }
}
