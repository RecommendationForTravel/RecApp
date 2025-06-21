// lib/screens/recommendation/recommendation_place_selection_page.dart
// ... (import 구문)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rectrip/screens/recommendation/place_search_page.dart';
import 'package:rectrip/screens/recommendation/recommendation_result_page.dart';
import 'package:rectrip/services/main_backend_api_service.dart';

import '../../models/place_model.dart';


class RecommendationPlaceSelectionPage extends StatefulWidget {
  // 일자별로 구분된 초기 추천 장소 목록
  final Map<DateTime, List<Place>> initialPlacesByDate;
  final String tripTitle; // 여행 제목 추가

  const RecommendationPlaceSelectionPage({
    Key? key,
    required this.initialPlacesByDate,
    required this.tripTitle, // 생성자에 추가
  }) : super(key: key);

  @override
  _RecommendationPlaceSelectionPageState createState() => _RecommendationPlaceSelectionPageState();
}

class _RecommendationPlaceSelectionPageState extends State<RecommendationPlaceSelectionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<DateTime, List<Place>> _finalPlacesByDate;
  final _mainBackendService = MainBackendApiService();

  @override
  void initState() {
    super.initState();
    _finalPlacesByDate = Map.from(widget.initialPlacesByDate);
    _tabController = TabController(length: widget.initialPlacesByDate.length, vsync: this);
  }


  void _onComplete() async {
    // 현재 활성화된 탭(날짜)의 장소 목록으로 최종 경로 요청
    final currentTabDate = _finalPlacesByDate.keys.elementAt(_tabController.index);
    final placesForThisDay = _finalPlacesByDate[currentTabDate]!;

    // 로딩 인디케이터 표시
    showDialog(context: context, builder: (c) => Center(child: CircularProgressIndicator()));

    final optimizedRoute = await _mainBackendService.getOptimizedRoute(placesForThisDay);

    Navigator.pop(context); // 로딩 인디케이터 닫기
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecommendationResultPage(finalRoute: optimizedRoute, tripTitle: '',)),
    );
  }

  // 장소 추가/삭제 로직
  void _addPlace(DateTime date, Place place) {
    setState(() {
      _finalPlacesByDate[date]?.add(place);
    });
  }

  void _removePlace(DateTime date, Place place) {
    setState(() {
      _finalPlacesByDate[date]?.remove(place);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("추천 장소 선택"),
        actions: [TextButton(onPressed: _onComplete, child: Text("경로 최적화"))],
        bottom: TabBar(
          controller: _tabController,
          tabs: _finalPlacesByDate.keys.map((date) => Tab(text: "${date.month}/${date.day}")).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _finalPlacesByDate.entries.map((entry) {
          final date = entry.key;
          final places = entry.value;
          return _buildPlaceListForDay(date, places);
        }).toList(),
      ),
    );
  }

  Widget _buildPlaceListForDay(DateTime date, List<Place> places) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return ListTile(
              title: Text(place.placeName),
              subtitle: Text(place.roadAddressName),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () => _removePlace(date, place),
              ),
            );
          },
        ),
        Positioned(
          bottom: 16, right: 16,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              final Place? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlaceSearchPage()),
              );
              if (result != null) {
                _addPlace(date, result);
              }
            },
          ),
        )
      ],
    );
  }
}