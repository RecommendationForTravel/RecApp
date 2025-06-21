// lib/screens/feed_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/screens/feed/feed_detail_page.dart';
import 'package:rectrip/services/main_backend_api_service.dart';

// --- 데이터 모델 정의 (기존과 동일하나, 가독성을 위해 함께 배치) ---
class DailyLog {
  final String date;
  final List<Map<String, String>> route;
  final String comment;

  DailyLog({required this.date, required this.route, required this.comment});
}

class FeedPost {
  final String id;
  final String userName;
  final String userLocation;
  final String title;
  final String dateRange;
  final List<String> tags;
  final List<DailyLog> dailyLogs;

  FeedPost({
    required this.id,
    required this.userName,
    required this.userLocation,
    required this.title,
    required this.dateRange,
    required this.tags,
    required this.dailyLogs,
  });
}
// --- 데이터 모델 정의 끝 ---


class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final MainBackendApiService _apiService = MainBackendApiService();
  final ScrollController _scrollController = ScrollController();

  // 상태 변수들
  final List<FeedPost> _posts = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    // 첫 데이터 로드
    _fetchFeeds();

    // 스크롤 리스너 추가
    _scrollController.addListener(() {
      // 스크롤이 끝에 도달했고, 로딩 중이 아니며, 더 가져올 데이터가 있을 때
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchFeeds();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 서버에서 피드를 가져오는 함수
  Future<void> _fetchFeeds() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newPosts = await _apiService.getFeeds(page: _currentPage, tag: _selectedTag);
      setState(() {
        _posts.addAll(newPosts);
        _currentPage++;
        _isLoading = false;
        // 새로 불러온 데이터가 요청한 limit보다 적으면 더 이상 데이터가 없는 것으로 간주
        if (newPosts.length < 5) {
          _hasMore = false;
        }
      });
    } catch (e) {
      // 에러 처리
      setState(() => _isLoading = false);
      print("피드 로딩 중 에러: $e");
    }
  }

  // 새로고침 또는 태그 필터링 시 상태를 초기화하고 다시 로드하는 함수
  Future<void> _resetAndFetchFeeds({String? tag}) async {
    setState(() {
      _posts.clear();
      _currentPage = 1;
      _hasMore = true;
      _selectedTag = tag;
    });
    await _fetchFeeds();
  }

  // 태그 필터 모달을 보여주는 함수
  void _showTagFilterModal() async {
    final tags = await _apiService.getAvailableTags();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              // 전체 보기(필터 해제) 버튼
              ActionChip(
                label: Text("전체 보기"),
                onPressed: () {
                  Navigator.pop(context);
                  _resetAndFetchFeeds(tag: null);
                },
              ),
              // 각 태그별 필터 버튼
              ...tags.map((tag) => ActionChip(
                label: Text(tag),
                backgroundColor: _selectedTag == tag ? Colors.teal : Colors.grey[200],
                labelStyle: TextStyle(color: _selectedTag == tag ? Colors.white : Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                  _resetAndFetchFeeds(tag: tag);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTag ?? "전체 피드"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showTagFilterModal,
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () => _resetAndFetchFeeds(tag: _selectedTag),
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
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FeedDetailPage(post: post))),
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
