// lib/screens/recommendation/recommendation_place_selection_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/screens/recommendation/place_search_page.dart';
import 'package:rectrip/screens/recommendation/recommendation_result_page.dart';
import 'package:rectrip/services/main_backend_api_service.dart';
import 'package:rectrip/widgets/trip_map_widget.dart';

class RecommendationPlaceSelectionPage extends StatefulWidget {
  final Map<DateTime, List<Place>> initialPlacesByDate;
  final String tripTitle;

  const RecommendationPlaceSelectionPage({
    Key? key,
    required this.initialPlacesByDate,
    required this.tripTitle,
  }) : super(key: key);

  @override
  _RecommendationPlaceSelectionPageState createState() =>
      _RecommendationPlaceSelectionPageState();
}

class _RecommendationPlaceSelectionPageState
    extends State<RecommendationPlaceSelectionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<DateTime, List<Place>> _finalPlacesByDate;
  final _mainBackendService = MainBackendApiService();

  @override
  void initState() {
    super.initState();
    _finalPlacesByDate = Map.from(widget.initialPlacesByDate);
    _tabController =
        TabController(length: widget.initialPlacesByDate.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 현재 일자의 경로를 최적화하고 결과 페이지로 이동하는 함수
  void _optimizeCurrentDayRoute() async {
    final dayIndex = _tabController.index;
    final currentDate = _finalPlacesByDate.keys.elementAt(dayIndex);
    final placesForThisDay = _finalPlacesByDate[currentDate]!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(child: CircularProgressIndicator()),
    );

    final optimizedRoute =
    await _mainBackendService.getOptimizedRoute(placesForThisDay);
    Navigator.pop(context); // 로딩 인디케이터 닫기

    // 결과 페이지로 이동. 다음 페이지에서 'next' 신호를 보내면 탭 이동
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendationResultPage(
          finalRoute: optimizedRoute,
          tripTitle: widget.tripTitle,
          dayIndex: dayIndex,
          totalDays: _finalPlacesByDate.length,
        ),
      ),
    );

    // 결과 페이지에서 '다음 일자 선택'을 눌렀을 경우
    if (result == 'next' && dayIndex < _finalPlacesByDate.length - 1) {
      _tabController.animateTo(dayIndex + 1);
    }
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
    final currentPlaces = _finalPlacesByDate.values.elementAt(_tabController.index);

    return Scaffold(
      appBar: AppBar(
        title: Text("추천 장소 선택"),
        actions: [
          TextButton(
            onPressed: _optimizeCurrentDayRoute,
            child: Text("현재일자 경로 최적화"),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _finalPlacesByDate.keys
              .map((date) => Tab(text: "${date.month}/${date.day}"))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          TripMapWidget(places: currentPlaces),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _finalPlacesByDate.entries.map((entry) {
                return _buildPlaceListForDay(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 장소를 추가하는 플로팅 액션 버튼을 포함한 리스트 위젯
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
                onPressed: () { // _removePlace(date, place)
                  setState(() {
                    _finalPlacesByDate[date]?.remove(place);
                  });
                },
              ),
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              final Place? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlaceSearchPage()),
              );
              if (result != null) {
                setState(() { // _addPlace(date, result)
                  _finalPlacesByDate[date]?.add(result);
                });
              }
            },
          ),
        )
      ],
    );
  }
}
