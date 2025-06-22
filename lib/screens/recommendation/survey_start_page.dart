// lib/screens/recommendation/survey_start_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rectrip/providers/recommendation_provider.dart';
import 'package:rectrip/screens/recommendation/recommendation_result_page.dart';
import 'survey_form_page.dart';

class SurveyStartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // RecommendationProvider의 savedTrips를 가져옴
    final savedTrips = Provider.of<RecommendationProvider>(context).savedTrips;

    return Scaffold(
      appBar: AppBar(
        title: Text('AI 여행 추천', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 상단 추천 받기 섹션
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.assistant_photo, size: 80, color: Colors.teal),
                  SizedBox(height: 16),
                  Text(
                    'AI와 함께 만드는\n나만의 여행 계획',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<RecommendationProvider>(context, listen: false).clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SurveyFormPage()),
                      );
                    },
                    child: Text('새로운 여행 추천 받기'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 40),

            // 하단 추천 받은 기록 섹션
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("추천 받은 여행 목록", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 10),
                  savedTrips.isEmpty
                      ? Center(child: Text("아직 추천 받은 여행이 없습니다."))
                      : Expanded(
                    child: ListView.builder(
                      itemCount: savedTrips.length,
                      itemBuilder: (context, index) {
                        final trip = savedTrips[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.location_on, color: Colors.teal),
                            title: Text(trip.title),
                            subtitle: Text("총 ${trip.route.length}개의 장소"),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              // 저장된 결과를 다시 보여주는 페이지로 이동
                              /*Navigator.push(context, MaterialPageRoute(
                                builder: (context) => RecommendationResultPage(
                                    finalRoute: trip.route,
                                    tripTitle: trip.title
                                ),
                              ));*/
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}