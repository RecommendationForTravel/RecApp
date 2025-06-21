// lib/screens/feed/feed_detail_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed_page.dart';
import 'package:rectrip/widgets/trip_map_widget.dart';

import '../../models/place_model.dart'; // 지도 위젯 import

class FeedDetailPage extends StatefulWidget {
  final FeedPost post;
  const FeedDetailPage({Key? key, required this.post}) : super(key: key);
  @override
  _FeedDetailPageState createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  late List<bool> _isSaved;
  final PageController _pageController = PageController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _isSaved = List.filled(widget.post.dailyLogs.length, false);
    _pageController.addListener(() {
      if (_pageController.page?.round() != _pageNotifier.value) {
        _pageNotifier.value = _pageController.page!.round();
      }
    });
  }

  // ... (기존 _toggleSave, dispose 함수는 동일)
  @override
  void dispose() {
    _pageController.removeListener(() {});
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  void _toggleSave(int index) {
    setState(() {
      _isSaved[index] = !_isSaved[index];
    });
    // TODO: 실제 백엔드에 일자별 저장/삭제 API를 호출하는 로직 추가
    // 예: MainBackendApiService().saveDailyTrip(widget.post.id, widget.post.dailyLogs[index].date);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${widget.post.dailyLogs[index].date} 일정이 ${_isSaved[index] ? "저장" : "취소"}되었습니다.'
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          // ValueListenableBuilder를 사용하여 페이지 변경에 따라 아이콘을 업데이트
          ValueListenableBuilder<int>(
            valueListenable: _pageNotifier,
            builder: (context, pageIndex, _) {
              return IconButton(
                icon: Icon(
                  _isSaved[pageIndex] ? Icons.bookmark : Icons.bookmark_border,
                  color: _isSaved[pageIndex] ? Colors.amber : null,
                ),
                // 현재 페이지의 인덱스를 _toggleSave 함수에 전달
                onPressed: () => _toggleSave(pageIndex),
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.post.dailyLogs.length,
        itemBuilder: (context, index) {
          final dailyLog = widget.post.dailyLogs[index];
          // TODO: DailyLog의 route(List<Map<String,String>>)를 List<Place>로 변환해야 지도에 표시 가능합니다.
          final placesForMap = <Place>[];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TripMapWidget(places: placesForMap),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(dailyLog.date, style: Theme.of(context).textTheme.headlineSmall),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("여행 경로", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      // ... (경로 아이템 위젯)
                      SizedBox(height: 20),
                      Text("후기", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(dailyLog.comment),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
