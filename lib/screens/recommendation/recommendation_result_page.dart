// lib/screens/recommendation/recommendation_result_page.dart
import 'package:flutter/material.dart';
import 'package:rectrip/models/place_model.dart';

class RecommendationResultPage extends StatelessWidget {
  // 메인 백엔드가 정해준 최종 경로(순서가 있는 장소 리스트)
  final List<Place> finalRoute;

  const RecommendationResultPage({Key? key, required this.finalRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("추천 결과입니다!"),
      ),
      body: Column(
        children: [
          Container( /* 지도 UI */ ),
          Expanded(
            child: ListView.builder(
              itemCount: finalRoute.length,
              itemBuilder: (context, index) {
                final place = finalRoute[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(place.placeName),
                  subtitle: Text(place.roadAddressName),
                );
              },
            ),
          ),
          /* 저장 버튼 */
        ],
      ),
    );
  }
}