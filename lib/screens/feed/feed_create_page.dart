// lib/screens/feed/feed_create_page.dart (신규 파일)
import 'package:flutter/material.dart';

class FeedCreatePage extends StatelessWidget {
  const FeedCreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("새 게시물"),
        actions: [
          TextButton(
            onPressed: () {
              // 게시물 저장 로직
              Navigator.of(context).pop(); // 저장 후 화면 닫기
            },
            child: Text("다음", style: TextStyle(color: Colors.teal, fontSize: 16)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: "제목",
                hintText: "여행 제목을 입력하세요",
              ),
            ),
            SizedBox(height: 16),
            // 날짜 선택 (UI 예시에 따라 구현)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("2025.05.05", style: TextStyle(fontSize: 16)),
                Text("-"),
                Text("2025.05.07", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 16),
            // 이미지 추가 버튼
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey[600]),
                    SizedBox(height: 8),
                    Text("대표 이미지 추가"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "태그",
                hintText: "#낭만 #커플 #성공적",
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "코멘트",
                hintText: "여행에 대한 코멘트를 남겨주세요",
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}