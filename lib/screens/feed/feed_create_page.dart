// lib/screens/feed/feed_create_page.dart (신규 파일)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FeedCreatePage extends StatefulWidget {
  @override
  _FeedCreatePageState createState() => _FeedCreatePageState();
}


class _FeedCreatePageState extends State<FeedCreatePage> {
  //const FeedCreatePage({Key? key}) : super(key: key);

  // 일자별 데이터를 관리할 리스트
  List<Map<String, dynamic>> dailyLogsData = [];

  // 이미지 피커
  final ImagePicker _picker = ImagePicker();

  void _addDailyLog() {
    setState(() {
      dailyLogsData.add({
        'images': <XFile>[],
        'comment': TextEditingController(),
      });
    });
  }

  Future<void> _pickImage(int dayIndex) async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        dailyLogsData[dayIndex]['images'].addAll(pickedFiles);
      });
    }
  }

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
            child: Text(
                "다음", style: TextStyle(color: Colors.teal, fontSize: 16)),
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
                    Icon(Icons.camera_alt_outlined, size: 40,
                        color: Colors.grey[600]),
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
            // 동적으로 일자별 입력 폼 생성
            ...List.generate(
                dailyLogsData.length, (index) => _buildDailyLogForm(index)),

            TextButton.icon(
              onPressed: _addDailyLog,
              icon: Icon(Icons.add),
              label: Text("하루 일정 추가"),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDailyLogForm(int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${index + 1}일차", style: Theme
                .of(context)
                .textTheme
                .titleLarge),
            SizedBox(height: 12),
            // 이미지 추가 버튼 및 선택된 이미지 표시
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyLogsData[index]['images'].length + 1,
                itemBuilder: (context, imgIndex) {
                  if (imgIndex == 0) {
                    return GestureDetector(
                      onTap: () => _pickImage(index),
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.add_a_photo_outlined),
                      ),
                    );
                  }
                  final imageFile = dailyLogsData[index]['images'][imgIndex -
                      1];
                  return Image.file(File(imageFile.path), width: 80,
                    height: 80,
                    fit: BoxFit.cover,);
                },
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: dailyLogsData[index]['comment'],
              decoration: InputDecoration(
                  labelText: "코멘트", hintText: "이날의 경험을 기록해보세요."),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}