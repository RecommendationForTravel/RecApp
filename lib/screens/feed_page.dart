import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed/feed_detail_page.dart';

// 샘플 데이터 모델
class FeedPost {
  final String id;
  final String userName;
  final String userLocation;
  final String imageUrl;
  final String title;
  final String dateRange;
  final List<String> tags;

  FeedPost({
    required this.id,
    required this.userName,
    required this.userLocation,
    required this.imageUrl,
    required this.title,
    required this.dateRange,
    required this.tags,
  });
}

class FeedPage extends StatelessWidget {
  // 샘플 피드 데이터
  final List<FeedPost> feedPosts = [
    FeedPost(
      id: '1',
      userName: 'aodp',
      userLocation: '서울 특별시 용산구',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2070&auto=format&fit=crop', // 샘플 이미지 URL
      title: '딱밤 여행',
      dateRange: '2025.05.05 - 2025.05.07',
      tags: ['#커플', '#낭만', '#성공적'],
    ),
    FeedPost(
      id: '2',
      userName: 'flutterdev',
      userLocation: '부산 광역시 해운대구',
      imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=2070&auto=format&fit=crop', // 샘플 이미지 URL
      title: '해변에서의 휴식',
      dateRange: '2025.06.10 - 2025.06.12',
      tags: ['#힐링', '#바다', '#여유'],
    ),
    // 더 많은 피드 아이템 추가 가능
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar( // 사용자 프로필 이미지 (임시)
            backgroundColor: Colors.grey[300],
            child: Text(
                feedPosts.isNotEmpty ? feedPosts[0].userName[0].toUpperCase() : 'U',
                style: TextStyle(color: Colors.black54)
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedPosts.isNotEmpty ? feedPosts[0].userName : '사용자명',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              feedPosts.isNotEmpty ? feedPosts[0].userLocation : '위치 정보 없음',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // 검색 기능 구현
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1, // 약간의 그림자로 구분
      ),
      body: ListView.builder(
        itemCount: feedPosts.length,
        itemBuilder: (context, index) {
          final post = feedPosts[index];
          // GestureDetector로 감싸서 탭 이벤트를 감지
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 게시물 작성 화면으로 이동 (피드 작성 화면-1)
          //Navigator.push(context, MaterialPageRoute(builder: (context) => FeedDetailPage(post: post)));
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
          Image.network( // 네트워크 이미지 로드
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
          ),
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
