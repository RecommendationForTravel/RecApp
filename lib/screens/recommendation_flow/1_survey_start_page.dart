// lib/screens/recommendation_flow/1_survey_start_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rectrip/providers/recommendation_provider.dart';
import '2_survey_form_page.dart';

class SurveyStartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 추천'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assistant_photo, size: 100, color: Colors.teal),
              SizedBox(height: 20),
              Text(
                'AI와 함께 만드는\n나만의 여행 계획',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // 이전 추천 데이터가 있다면 초기화
                  Provider.of<RecommendationProvider>(context, listen: false).clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SurveyFormPage()),
                  );
                },
                child: Text('추천 받기'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}