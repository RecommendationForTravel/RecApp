
import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed_page.dart'; // FeedPost 모델을 가져오기 위함

class FeedDetailPage extends StatelessWidget {
  final FeedPost post;

  const FeedDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 지도 이미지 (임시)
            Container(
              height: 250,
              color: Colors.grey[300],
              child: Center(
                child: Icon(Icons.map_outlined, size: 100, color: Colors.grey[600]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("여행 경로", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  // 경로 아이템 (UI 예시에 따라 구성)
                  _buildRouteItem(Icons.train, "카레 맛집", "서울역 근처", "12000원"),
                  _buildRouteItem(Icons.coffee, "오션뷰 카페", "해운대 해변", "8000원"),
                  SizedBox(height: 20),
                  Text("후기", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("정말 즐거운 여행이었습니다! 특히 카레 맛집은 인생 맛집이었어요. 오션뷰 카페는 경치가 정말 좋아서 시간 가는 줄 몰랐네요. 이 코스 강력 추천합니다!"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteItem(IconData icon, String title, String subtitle, String price) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(price),
      ),
    );
  }
}