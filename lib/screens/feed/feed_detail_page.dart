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

  @override
  void initState() {
    super.initState();
    _isSaved = List.filled(widget.post.dailyLogs.length, false);
    // PageController 리스너 추가
    _pageController.addListener(() {
      if (_pageController.page?.round() != _pageNotifier.value) {
        _pageNotifier.value = _pageController.page!.round();
      }
    });
  }

  // PageView 컨트롤러와 Notifier 추가
  final PageController _pageController = PageController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);

  // ... (기존 _toggleSave, dispose 함수는 동일)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _pageNotifier,
            builder: (context, page, _) {
              return IconButton(
                icon: Icon(_isSaved[page] ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () {}, // _toggleSave(page)
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
          // DailyLog의 route(List<Map<String,String>>)를 List<Place>로 변환해야 함
          // 현재 데이터 모델이 맞지 않으므로, 임시로 빈 리스트를 전달합니다.
          // TODO: DailyLog의 route를 Place 객체 리스트로 변경해야 합니다.
          final placesForMap = <Place>[];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 지도 위젯 추가
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
                      // ... (dailyLog.route를 기반으로 경로 아이템 생성)
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
