// lib/screens/recommendation/recommendation_result_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/providers/recommendation_provider.dart';
import 'package:rectrip/widgets/trip_map_widget.dart';

class RecommendationResultPage extends StatelessWidget {
  final List<Place> finalRoute;
  final String tripTitle;
  final int dayIndex;
  final int totalDays;

  const RecommendationResultPage({
    Key? key,
    required this.finalRoute,
    required this.tripTitle,
    required this.dayIndex,
    required this.totalDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLastDay = dayIndex == totalDays - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text("${dayIndex + 1}일차 최적화 결과"),
        // 마지막 날이 아닐 경우, 뒤로가기 버튼을 명시적으로 비활성화하여 혼란 방지
        automaticallyImplyLeading: isLastDay,
      ),
      body: Column(
        children: [
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
                if (isLastDay) {
                  // 마지막 날: 전체 여정 저장 후 메인 화면으로 이동
                  // TODO: 전체 일정(모든 날짜의 경로)을 저장하도록 Provider 로직 개선 필요
                  Provider.of<RecommendationProvider>(context, listen: false)
                      .saveFinalTrip(tripTitle, finalRoute); // 우선 마지막 날 경로만 저장

                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  // 다음 날이 있음: 'next' 신호를 보내고 장소 선택 화면으로 복귀
                  Navigator.of(context).pop('next');
                }
              },
              // 마지막 날 여부에 따라 버튼 텍스트 변경
              child: Text(isLastDay ? '이 여정 전체 저장하기' : '다음 일자 선택하기'),
            ),
          )
        ],
      ),
    );
  }
}
