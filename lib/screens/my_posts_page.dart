// lib/screens/my_posts_page.dart (신규 파일)
import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed_page.dart'; // FeedPost, FeedItemWidget 재사용
import 'package:rectrip/services/main_backend_api_service.dart';
import 'package:rectrip/screens/feed/feed_detail_page.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({Key? key}) : super(key: key);

  @override
  _MyPostsPageState createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  final MainBackendApiService _apiService = MainBackendApiService();
  // API 호출의 상태를 관리할 Future 변수
  late Future<List<FeedPost>> _myPostsFuture;

  @override
  void initState() {
    super.initState();
    // 페이지가 로드될 때 API 호출 시작
    _loadMyPosts();
  }

  void _loadMyPosts() {
    setState(() {
      _myPostsFuture = _apiService.getMyPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내가 쓴 여행기"),
      ),
      body: FutureBuilder<List<FeedPost>>(
        future: _myPostsFuture,
        builder: (context, snapshot) {
          // 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 에러 발생 시
          if (snapshot.hasError) {
            return Center(child: Text("오류가 발생했습니다: ${snapshot.error}"));
          }
          // 데이터가 없거나 비어있을 경우
          final myPosts = snapshot.data;
          if (myPosts == null || myPosts.isEmpty) {
            return const Center(
              child: Text("작성한 여행기가 없습니다."),
            );
          }

          // 데이터 로딩 성공 시 목록 표시
          return RefreshIndicator(
            onRefresh: () async => _loadMyPosts(),
            child: ListView.builder(
              itemCount: myPosts.length,
              itemBuilder: (context, index) {
                final post = myPosts[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedDetailPage(postId: post.id, postTitle: post.title)),
                  ),
                  // 피드 목록과 동일한 UI 재사용
                  child: FeedItemWidget(post: post),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
