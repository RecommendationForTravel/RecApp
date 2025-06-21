import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed/feed_detail_page.dart';

import '../services/main_backend_api_service.dart';

class DailyLog {
  final String date;
  final List<Map<String, String>> route; // 예: [{'title': '맛집', 'details': '...'}, ...]
  //final List<String> photoUrls;
  final String comment;

  DailyLog({
    required this.date,
    required this.route,
    required this.comment,
    // required this.photoUrls, // 생성자에서 제거
  });
}

// 샘플 데이터 모델
class FeedPost {
  final String id;
  final String userName;
  final String userLocation;
  //final String imageUrl;
  final String title;
  final String dateRange;
  final List<String> tags;
  final List<DailyLog> dailyLogs; // 일자별 기록 추가

  FeedPost({
    required this.id,
    required this.userName,
    required this.userLocation,
    //required this.imageUrl,
    required this.title,
    required this.dateRange,
    required this.tags,
    required this.dailyLogs,
  });
}

class FeedPage extends StatelessWidget {
  // MainBackendApiService 인스턴스 생성
  final MainBackendApiService _apiService = MainBackendApiService();

  // ★★★★★ 여기 있던 샘플 데이터(feedPosts 리스트)는 삭제합니다. ★★★★★

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar는 동적으로 채울 필요가 크지 않으므로 일단 유지하거나,
        // FutureBuilder 내부에서 첫 번째 포스트 데이터로 채울 수 있습니다.
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person_outline, color: Colors.black54),
          ),
        ),
        title: Text("피드", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // 검색 기능 구현 (이전 답변의 필터 모달 호출 로직)
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      // FutureBuilder를 사용하여 비동기 데이터를 처리
      body: FutureBuilder<List<FeedPost>>(
        future: _apiService.getFeeds(), // 데이터를 가져올 Future를 지정
        builder: (context, snapshot) {
          // 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // 에러가 발생했을 때
          if (snapshot.hasError) {
            return Center(child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
          }
          // 데이터가 없거나 비어있을 때
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("표시할 피드가 없습니다."));
          }

          // 데이터 로딩 성공
          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedDetailPage(post: post),
                    ),
                  );
                },
                child: FeedItemWidget(post: post),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 게시물 작성 화면으로 이동
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class FeedItemWidget extends StatelessWidget {
  final FeedPost post;

  const FeedItemWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // 이미지 모서리도 둥글게
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*Image.network( // 네트워크 이미지 로드
            post.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            // 이미지 로딩 중 에러 발생 시 표시할 위젯
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[200],
                child: Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
              );
            },
            // 이미지 로딩 중 표시할 위젯
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),*/
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  post.dateRange,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Wrap( // 태그들을 가로로 나열, 공간 부족 시 다음 줄로
                  spacing: 6.0, // 태그 간 가로 간격
                  runSpacing: 4.0, // 태그 줄 간 간격
                  children: post.tags.map((tag) => Chip(
                    label: Text(tag, style: TextStyle(fontSize: 12, color: Colors.white)),
                    backgroundColor: Colors.teal.withOpacity(0.8),
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    labelPadding: EdgeInsets.zero, // 기본 패딩 제거
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 탭 영역 최소화
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
