// 메인 백엔드 서버와 통신하는 클래스
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/screens/feed_page.dart'; // FeedPost 모델

class MainBackendApiService {
  // 최종 장소 리스트를 보내고, 최적화된 경로(순서)를 받아옵니다.
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

  // 피드 목록을 서버에서 가져옵니다.
  Future<List<FeedPost>> getFeeds() async {
    /*
    // ===== 실제 서버 연동 시 주석 해제 =====
    final url = Uri.parse('YOUR_MAIN_BACKEND_URL/feeds');
    final response = await http.get(url);
    if (response.statusCode == 200) {
        // ... JSON 파싱 로직 ...
        return parsedFeeds;
    } else {
        throw Exception('피드 목록 로딩 실패');
    }
    */

    // --- 더미 데이터 반환 ---
    return [
      FeedPost(id: '1', userName: 'aodp', userLocation: '서울 특별시 용산구', imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2070&auto=format&fit=crop', title: '딱밤 여행', dateRange: '2025.05.05 - 2025.05.07', tags: ['#커플', '#낭만', '#성공적']),
      FeedPost(id: '2', userName: 'flutterdev', userLocation: '부산 광역시 해운대구', imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=2070&auto=format&fit=crop', title: '해변에서의 휴식', dateRange: '2025.06.10 - 2025.06.12', tags: ['#힐링', '#바다', '#여유']),
    ];
  }

  // 작성된 피드를 서버로 전송합니다.
  Future<void> uploadFeed(FeedPost newFeed) async {
    /*
    // ===== 실제 서버 연동 시 주석 해제 =====
    final url = Uri.parse('YOUR_MAIN_BACKEND_URL/feeds');
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newFeed.toJson()), // FeedPost 모델에 toJson() 구현 필요
    );
    if (response.statusCode != 201) {
        throw Exception('피드 업로드 실패');
    }
    */
    print("새로운 피드를 메인 백엔드로 전송 (시뮬레이션)");
  }

  // 저장할 여행(피드) 정보를 서버로 전송합니다.
  Future<void> saveTrip(String feedId) async {
    /*
    // ===== 실제 서버 연동 시 주석 해제 =====
    final url = Uri.parse('YOUR_MAIN_BACKEND_URL/saved-trips');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'feedId': feedId}),
    );
    if (response.statusCode != 200) {
        throw Exception('여행 저장 실패');
    }
    */
    print("피드 ID: $feedId 를 저장했다고 서버에 알림 (시뮬레이션)");
  }
}