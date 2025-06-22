// lib/screens/feed_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed/feed_detail_page.dart';
import 'package:rectrip/services/main_backend_api_service.dart';

// --- 데이터 모델 정의 (fromJson 생성자 추가) ---
class DailyLog {
  final String date;
  final List<Map<String, String>> route;
  final String comment;

  DailyLog({required this.date, required this.route, required this.comment});

  // 상세 정보 JSON으로부터 DailyLog 객체를 생성하는 factory 생성자
  factory DailyLog.fromJson(Map<String, dynamic> json) {
    // TODO: 백엔드 DTO의 실제 필드명 확인 및 매핑 필요
    return DailyLog(
      date: json['date'] ?? '날짜 정보 없음',
      route: (json['route'] as List<dynamic>?)
          ?.map((r) => Map<String, String>.from(r))
          .toList() ??
          [],
      comment: json['comment'] ?? '',
    );
  }
}

class FeedPost {
  final int id; // 백엔드 ID 타입이 정수형일 가능성이 높음
  final String userName;
  final String title;
  final String dateRange;
  final List<String> tags;
  List<DailyLog> dailyLogs; // 상세 정보는 나중에 채워질 수 있도록 late가 아닌 일반 변수로

  FeedPost({
    required this.id,
    required this.userName,
    required this.title,
    required this.dateRange,
    required this.tags,
    required this.dailyLogs,
  });

  // 목록용 JSON(ArticleDto)으로부터 FeedPost 객체를 생성
  factory FeedPost.fromJson(Map<String, dynamic> json) {
    // TODO: 백엔드 DTO의 실제 필드명 확인 및 매핑 필요
    return FeedPost(
      id: json['articleId'] ?? 0,
      userName: json['author'] ?? '작성자 정보 없음',
      title: json['title'] ?? '제목 없음',
      dateRange:
      "${json['startDate'] ?? ''} - ${json['endDate'] ?? ''}",
      tags: List<String>.from(json['tags'] ?? []),
      dailyLogs: [], // 목록에서는 상세 정보가 없으므로 빈 리스트로 초기화
    );
  }

  // 상세정보용 JSON(ArticleDetailDto)으로부터 FeedPost 객체를 생성
  factory FeedPost.fromDetailJson(Map<String, dynamic> json) {
    // TODO: 백엔드 DTO의 실제 필드명 확인 및 매핑 필요
    return FeedPost(
      id: json['articleId'] ?? 0,
      userName: json['author'] ?? '작성자 정보 없음',
      title: json['title'] ?? '제목 없음',
      dateRange:
      "${json['startDate'] ?? ''} - ${json['endDate'] ?? ''}",
      tags: List<String>.from(json['tags'] ?? []),
      dailyLogs: (json['dailyLogs'] as List<dynamic>?)
          ?.map((logJson) => DailyLog.fromJson(logJson))
          .toList() ??
          [],
    );
  }
}
// --- 데이터 모델 정의 끝 ---

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final MainBackendApiService _apiService = MainBackendApiService();
  final ScrollController _scrollController = ScrollController();

  final List<FeedPost> _posts = [];
  int _currentPage = 0; // Spring Page는 0부터 시작
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchFeeds();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading && _hasMore) {
        _fetchFeeds();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchFeeds() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final newPosts = await _apiService.getFeeds(page: _currentPage);
      setState(() {
        if (newPosts.isNotEmpty) {
          _posts.addAll(newPosts);
          _currentPage++;
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _fetchFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("피드"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _posts.isEmpty && _isLoading
            ? Center(child: CircularProgressIndicator())
            : _posts.isEmpty && !_isLoading
            ? Center(child: Text("표시할 피드가 없습니다."))
            : ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _posts.length) {
              final post = _posts[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedDetailPage(postSummary: post)),
                ),
                child: FeedItemWidget(post: post),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}

// 피드 아이템 위젯 (이미지 관련 코드 없음)
class FeedItemWidget extends StatelessWidget {
  final FeedPost post;
  const FeedItemWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(post.userName, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            SizedBox(height: 4),
            Text(post.dateRange, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            SizedBox(height: 10),
            Wrap(
              spacing: 6.0,
              children: post.tags.map((tag) => Chip(
                label: Text(tag, style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.teal.withOpacity(0.1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
