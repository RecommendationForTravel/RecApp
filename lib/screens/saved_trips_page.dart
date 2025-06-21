// lib/screens/saved_trips_page.dart (신규 파일)
import 'package:flutter/material.dart';

class SavedTripsPage extends StatelessWidget {
  const SavedTripsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("저장된 여행"),
      ),
      body: Center(
        child: Text(
          "저장된 여행 목록이 여기에 표시됩니다.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}