// lib/screens/saved_trips_page.dart

import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed_page.dart';
import 'package:rectrip/services/main_backend_api_service.dart';
import 'package:rectrip/screens/feed/feed_detail_page.dart';

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

  void _loadSavedFeeds() {
    setState(() {
      _savedFeedsFuture = _apiService.getLikedFeeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('저장한 여행기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadSavedFeeds(),
        child: FutureBuilder<List<FeedPost>>(
          future: _savedFeedsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("오류: ${snapshot.error}"));
            }
            final savedPosts = snapshot.data;
            if (savedPosts == null || savedPosts.isEmpty) {
              return Center(child: Text("저장된 여행기가 없습니다."));
            }
            return ListView.builder(
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                final post = savedPosts[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedDetailPage(postId: post.id, postTitle: post.title)),
                  ),
                  child: FeedItemWidget(post: post),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
