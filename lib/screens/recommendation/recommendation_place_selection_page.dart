// lib/screens/recommendation/recommendation_place_selection_page.dart
// ... (import 구문)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rectrip/screens/recommendation/place_search_page.dart';
import 'package:rectrip/screens/recommendation/recommendation_result_page.dart';
import 'package:rectrip/services/main_backend_api_service.dart';

import '../../models/place_model.dart';

class RecommendationPlaceSelectionPage extends StatefulWidget {
  // 추천 서버로부터 받은 초기 장소 목록
  final List<Place> initialPlaces;

  const RecommendationPlaceSelectionPage({Key? key, required this.initialPlaces}) : super(key: key);

  @override
  _RecommendationPlaceSelectionPageState createState() =>
      _RecommendationPlaceSelectionPageState();
}

class _RecommendationPlaceSelectionPageState
    extends State<RecommendationPlaceSelectionPage> {
  // ... (기존 변수 선언)

  // 모든 장소를 하나의 리스트로 관리
  late List<Place> _finalPlaces;
  final _mainBackendService = MainBackendApiService();

  @override
  void initState() {
    super.initState();
    // 초기 장소 목록으로 상태 초기화
    _finalPlaces = List.from(widget.initialPlaces);
  }

  // "완료" 버튼을 눌렀을 때의 동작
  void _onComplete() async {
    // 1. 최종 장소 목록을 메인 백엔드 서버로 보냄
    final optimizedRoute = await _mainBackendService.getOptimizedRoute(_finalPlaces);

    // 2. 서버가 정해준 경로(순서)대로 최종 결과 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RecommendationResultPage(finalRoute: optimizedRoute)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("추천 장소 선택"),
        actions: [
          TextButton(
            onPressed: _onComplete, // 완료 버튼에 함수 연결
            child: Text("완료", style: TextStyle(color: Colors.teal, fontSize: 16)),
          )
        ],
      ),
      body: Column(
        children: [
          // TableCalendar 위젯 (기존과 동일)
          // ...
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                _buildPlaceList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 카카오 API로 장소 검색 후 추가
          final Place? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlaceSearchPage()),
          );
          if (result != null) {
            setState(() {
              _finalPlaces.add(result);
            });
          }
        },
      ),
    );
  }

  Widget _buildPlaceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("여행 장소 목록", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ..._finalPlaces.map((place) => ListTile(
          title: Text(place.placeName),
          subtitle: Text(place.roadAddressName),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () {
              setState(() {
                _finalPlaces.remove(place);
              });
            },
          ),
        )).toList(),
        Divider(),
      ],
    );
  }
}