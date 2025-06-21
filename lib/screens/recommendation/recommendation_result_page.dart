// lib/screens/recommendation/recommendation_result_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/providers/recommendation_provider.dart';

class RecommendationResultPage extends StatelessWidget {
  final List<Place> finalRoute;
  final String tripTitle; // 이전 페이지에서 제목을 받아옴

  const RecommendationResultPage({
    Key? key,
    required this.finalRoute,
    required this.tripTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("경로 최적화 결과"),
      ),
      body: Column(
        children: [
          // Container( /* 지도 UI */ ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                // Provider를 통해 여행 저장
                Provider.of<RecommendationProvider>(context, listen: false)
                    .saveFinalTrip(tripTitle, finalRoute);

                // 저장 후, 스택의 모든 페이지를 닫고 메인 화면으로 이동
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('이 여정 저장하기'),
            ),
          )
        ],
      ),
    );
  }
}