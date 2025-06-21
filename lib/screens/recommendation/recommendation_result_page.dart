// lib/screens/recommendation/recommendation_result_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/providers/recommendation_provider.dart';
import 'package:rectrip/widgets/trip_map_widget.dart'; // 지도 위젯 import

class RecommendationResultPage extends StatelessWidget {
  final List<Place> finalRoute;
  final String tripTitle;

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
          // 지도 위젯 추가 (번호 표시 옵션 활성화)
          TripMapWidget(places: finalRoute, showNumbers: true),
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
                Provider.of<RecommendationProvider>(context, listen: false)
                    .saveFinalTrip(tripTitle, finalRoute);
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
