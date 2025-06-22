// lib/screens/feed/feed_detail_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed_page.dart'; // DailyLog 모델 사용
import 'package:rectrip/services/main_backend_api_service.dart';
import 'package:rectrip/widgets/trip_map_widget.dart';

class FeedDetailPage extends StatefulWidget {
  final int postId;
  final String postTitle;

  const FeedDetailPage({Key? key, required this.postId, required this.postTitle}) : super(key: key);

  @override
  _FeedDetailPageState createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  final MainBackendApiService _apiService = MainBackendApiService();
  late Future<List<DailyLog>> _dailyLogsFuture;

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    // API 서비스를 통해 상세 로그 데이터를 가져옵니다.
    _dailyLogsFuture = _apiService.getFeedDetail(widget.postId);
  }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      _apiService.likePost(widget.postId, widget.postTitle);
    } else {
      // TODO: 좋아요 취소 API 연동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postTitle),
        actions: [
          IconButton(
            icon: Icon(_isLiked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleLike,
          )
        ],
      ),
      // FutureBuilder의 타입을 Future<List<DailyLog>>로 변경
      body: FutureBuilder<List<DailyLog>>(
        future: _dailyLogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("상세 정보를 불러오는 중 오류가 발생했습니다: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("상세 여행 기록이 없습니다."));
          }

          final dailyLogs = snapshot.data!;

          return PageView.builder(
            itemCount: dailyLogs.length,
            itemBuilder: (context, index) {
              final dailyLog = dailyLogs[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 지도에 현재 일자의 장소만 표시
                    TripMapWidget(places: [dailyLog.location]),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dailyLog.date, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 24),
                          _buildDetailRow(Icons.location_on_outlined, "장소", dailyLog.placeName),
                          _buildDetailRow(Icons.comment_outlined, "코멘트", dailyLog.comment),
                          _buildDetailRow(Icons.payment_outlined, "비용", "${dailyLog.cost}원"),
                          _buildDetailRow(Icons.directions_car_outlined, "교통수단", dailyLog.transportation),
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

  // 상세 정보 행을 만드는 헬퍼 위젯
  Widget _buildDetailRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }
}
