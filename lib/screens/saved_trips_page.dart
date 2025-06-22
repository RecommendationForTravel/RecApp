// lib/screens/saved_trips_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed_page.dart'; // FeedPost, FeedItemWidget 재사용
import 'package:rectrip/services/main_backend_api_service.dart';

class SavedTripsPage extends StatefulWidget {
  const SavedTripsPage({Key? key}) : super(key: key);

  @override
  _SavedTripsPageState createState() => _SavedTripsPageState();
}

class _SavedTripsPageState extends State<SavedTripsPage> {
  final MainBackendApiService _apiService = MainBackendApiService();
  late Future<List<FeedPost>> _savedFeedsFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedFeeds();
  }

  // 저장된 피드를 불러오는 함수
  void _loadSavedFeeds() {
    setState(() {
      _savedFeedsFuture = _apiService.getSavedFeeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("저장된 여행기"),
      ),
      // FutureBuilder를 사용하여 비동기 데이터를 처리
      body: FutureBuilder<List<FeedPost>>(
        future: _savedFeedsFuture,
        builder: (context, snapshot) {
          // 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // 에러 발생
          if (snapshot.hasError) {
            return Center(child: Text("오류가 발생했습니다: ${snapshot.error}"));
          }
          // 데이터가 없거나 비어있을 경우
          final savedPosts = snapshot.data;
          if (savedPosts == null || savedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "저장된 여행기가 없습니다.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 데이터 로딩 성공
          return RefreshIndicator(
            onRefresh: () async => _loadSavedFeeds(),
            child: ListView.builder(
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                // 저장된 피드를 표시할 때는 재사용 가능한 FeedItemWidget 사용
                //return FeedItemWidget(post: savedPosts[index], isLiked: null,, onLikePressed: () {  },);
              },
            ),
          );
        },
      ),
    );
  }
}
