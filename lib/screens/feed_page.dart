import 'package:flutter/material.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/screens/feed/feed_detail_page.dart';
import 'package:rectrip/services/main_backend_api_service.dart';

// --- 데이터 모델 정의 (백엔드 DTO에 맞게 수정) ---
class DailyLog {
  final String date;
  final String placeName;
  final String comment;
  final int cost;
  final String transportation;
  final Place location; // 지도 표시를 위한 위치 정보

  DailyLog({
    required this.date,
    required this.placeName,
    required this.comment,
    required this.cost,
    required this.transportation,
    required this.location,
  });
}

class FeedPost {
  final int id;
  final String userName;
  final String title;
  final String dateRange;
  final List<String> tags;
  List<DailyLog> dailyLogs; // 상세 정보는 나중에 채워짐

  FeedPost({
    required this.id,
    required this.userName,
    required this.title,
    required this.dateRange,
    required this.tags,
    required this.dailyLogs,
  });

  // --- 목록용 fromJson 생성자 수정 (핵심 수정 부분) ---
  factory FeedPost.fromJson(Map<String, dynamic> json) {
    // 서버에서 받은 값이 null일 경우를 대비해 기본값을 설정하여 안정성을 높입니다.
    String startDate = json['startDay']?.toString() ?? '';
    String endDate = json['endDay']?.toString() ?? '';
    String dateRange = (startDate.isEmpty && endDate.isEmpty) ? '기간 정보 없음' : "$startDate - $endDate";

    // tagList가 null이거나, 리스트 내에 null 요소가 있어도 오류가 발생하지 않도록 안전하게 파싱합니다.
    List<String> tags = (json['tagList'] as List<dynamic>? ?? [])
        .map((tag) => tag?.toString() ?? '') // 각 태그가 null이면 빈 문자열로 변환
        .where((tag) => tag.isNotEmpty) // 빈 태그는 최종 목록에서 제거
        .toList();

    return FeedPost(
      id: json['articleId'] ?? 0,
      userName: json['username'] ?? '사용자',
      title: json['title'] ?? '제목 없음',
      dateRange: dateRange,
      tags: tags,
      dailyLogs: [],
    );
  }

  // 상세정보용 ArticleDetailDto로부터 객체 생성
  factory FeedPost.fromDetailJson(Map<String, dynamic> json) {
    List<DailyLog> logs = [];
    final visitDates = List<String>.from(json['visitDateList'] ?? []);
    final placeNames = List<String>.from(json['placeList'] ?? []);
    final comments = List<String>.from(json['comment'] ?? []);
    final costs = List<int>.from(json['cost'] ?? []);
    final transportations = List<String>.from(json['transportationList'] ?? []);
    final locations = List<Map<String,dynamic>>.from(json['placeLocationList'] ?? []);

    for (int i = 0; i < visitDates.length; i++) {
      logs.add(DailyLog(
        date: visitDates[i],
        placeName: placeNames.length > i ? placeNames[i] : '장소 정보 없음',
        comment: comments.length > i ? comments[i] : '',
        cost: costs.length > i ? costs[i] : 0,
        transportation: transportations.length > i ? transportations[i] : 'ETC',
        location: Place(
          placeName: placeNames.length > i ? placeNames[i] : '장소 정보 없음',
          roadAddressName: '',
          x: (locations.length > i ? locations[i]['longitude'] : 0.0) as double,
          y: (locations.length > i ? locations[i]['latitude'] : 0.0) as double,
        ),
      ));
    }

    return FeedPost(
      id: json['articleId'] ?? 0,
      userName: json['author'] ?? '사용자',
      title: json['title'] ?? '제목 없음',
      dateRange: "${json['travelDate']?['startDate'] ?? ''} - ${json['travelDate']?['endDate'] ?? ''}",
      tags: (json['placeTagPairList'] as List<dynamic>?)?.map((tag) => tag['name'] as String).toList() ?? [],
      dailyLogs: logs,
    );
  }
}

// --- UI ---
class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final MainBackendApiService _apiService = MainBackendApiService();
  final ScrollController _scrollController = ScrollController();

  List<FeedPost> _posts = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  List<String> _selectedTags = [];

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

  Future<void> _fetchFeeds() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      List<FeedPost> newPosts;
      if (_selectedTags.isEmpty) {
        newPosts = await _apiService.getFeeds(page: _currentPage);
      } else {
        newPosts = await _apiService.getFeedsByTag(tags: _selectedTags, page: _currentPage);
      }

      setState(() {
        _posts.addAll(newPosts);
        _currentPage++;
        if (newPosts.length < 10) _hasMore = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("피드 로딩 중 에러: $e");
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _currentPage = 0;
      _hasMore = true;
      _isLoading = false;
    });
    await _fetchFeeds();
  }

// --- 태그 필터 모달 표시 함수 수정 ---
  void _showTagFilterModal() async {
    // MainBackendApiService를 통해 서버에서 태그 목록을 비동기적으로 불러옵니다.
    final allTags = await _apiService.getTagList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 내용이 많아도 스크롤 가능하도록 설정
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6, // 모달의 초기 높이
            maxChildSize: 0.9,     // 최대 높이
            builder: (_, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("태그로 검색", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Wrap(
                          spacing: 8.0,
                          children: allTags.map((tag) {
                            final isSelected = _selectedTags.contains(tag);
                            return FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (selected) {
                                // 단일 선택 로직
                                setModalState(() {
                                  _selectedTags = selected ? [tag] : [];
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _refresh(); // 선택된 태그로 새로고침
                        },
                        child: const Text('선택 완료'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('피드', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
       actions: [
        IconButton(icon: Icon(Icons.search), onPressed: _showTagFilterModal)
      ]),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _posts.length) {
              final post = _posts[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedDetailPage(postId: post.id, postTitle: post.title)),
                ),
                child: FeedItemWidget(post: post),
              );
            }
            return _hasMore ? Center(child: CircularProgressIndicator()) : SizedBox();
          },
        ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('작성자: ${post.userName}'),
            Text('기간: ${post.dateRange}'),
            SizedBox(height: 8),
            Wrap(spacing: 6, children: post.tags.map((tag) => Chip(label: Text(tag))).toList()),
          ],
        ),
      ),
    );
  }
}
