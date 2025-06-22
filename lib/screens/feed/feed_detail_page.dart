// lib/screens/feed/feed_detail_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed_page.dart'; // FeedPost, DailyLog 모델
import 'package:rectrip/services/main_backend_api_service.dart';
import 'package:rectrip/widgets/trip_map_widget.dart';

import '../../models/place_model.dart'; // 지도 위젯

class FeedDetailPage extends StatefulWidget {
  // 목록에서 받은 요약 정보
  final FeedPost postSummary;

  const FeedDetailPage({Key? key, required this.postSummary}) : super(key: key);

  @override
  _FeedDetailPageState createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  final MainBackendApiService _apiService = MainBackendApiService();
  // 서버에서 받아올 전체 상세 정보를 담을 Future
  late Future<FeedPost> _feedDetailFuture;

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때, 요약 정보의 ID를 이용해 상세 정보를 요청
    _feedDetailFuture = _apiService.getFeedDetail(widget.postSummary.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 상세 정보가 로딩되기 전에도 제목을 보여줌
        title: Text(widget.postSummary.title),
      ),
      // FutureBuilder를 사용하여 비동기 데이터를 처리
      body: FutureBuilder<FeedPost>(
        future: _feedDetailFuture,
        builder: (context, snapshot) {
          // 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // 에러 발생 시
          if (snapshot.hasError) {
            return Center(child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
          }
          // 데이터가 없을 때 (정상적으론 발생하기 어려움)
          if (!snapshot.hasData) {
            return Center(child: Text("게시물 정보를 찾을 수 없습니다."));
          }

          // 데이터 로딩 성공. 전체 상세 정보가 담긴 post 객체
          final post = snapshot.data!;

          // PageView로 일자별 상세 정보 표시 (기존 로직과 유사)
          return PageView.builder(
            itemCount: post.dailyLogs.length,
            itemBuilder: (context, index) {
              final dailyLog = post.dailyLogs[index];
              // TODO: DailyLog의 route를 Place 객체 리스트로 변환해야 지도에 표시 가능합니다.
              final placesForMap = <Place>[];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TripMapWidget(places: placesForMap),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(dailyLog.date,
                          style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("여행 경로",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          // ... (경로 아이템 위젯)
                          SizedBox(height: 20),
                          Text("후기",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text(dailyLog.comment),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
