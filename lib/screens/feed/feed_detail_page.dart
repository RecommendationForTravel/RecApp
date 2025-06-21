// lib/screens/feed/feed_detail_page.dart
import 'package:flutter/material.dart';
import 'package:rectrip/screens/feed_page.dart';

class FeedDetailPage extends StatefulWidget {
  final FeedPost post;
  const FeedDetailPage({Key? key, required this.post}) : super(key: key);
  @override
  _FeedDetailPageState createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  // 각 일자별 저장 상태를 관리
  late List<bool> _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = List.filled(widget.post.dailyLogs.length, false);
  }

  void _toggleSave(int index) {
    setState(() {
      _isSaved[index] = !_isSaved[index];
    });
    // 여기에 실제 백엔드 저장/삭제 API 호출 로직 추가
    // 예: MainBackendApiService().saveTripForDay(widget.post.id, widget.post.dailyLogs[index].date);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.post.dailyLogs[index].date} 일정이 ${_isSaved[index] ? "저장" : "취소"}되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          // 현재 보고있는 페이지의 저장 버튼
          ValueListenableBuilder<int>(
            valueListenable: _pageNotifier,
            builder: (context, page, _) {
              return IconButton(
                icon: Icon(_isSaved[page] ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () => _toggleSave(page),
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
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 페이지 상단에 날짜 표시
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(dailyLog.date, style: Theme.of(context).textTheme.headlineSmall),
                ),
                // 일자별 사진 (여러 개일 경우 PageView 등으로 표현 가능)
                // Image.network(
                //   dailyLog.photoUrls.isNotEmpty ? dailyLog.photoUrls.first : widget.post.imageUrl,
                //   height: 250,
                //   width: double.infinity,
                //   fit: BoxFit.cover,
                // ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
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

  // PageView 컨트롤러와 Notifier 추가
  final PageController _pageController = PageController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }
}