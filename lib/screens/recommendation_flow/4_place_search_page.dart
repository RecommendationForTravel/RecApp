// lib/screens/recommendation_flow/4_place_search_page.dart
import 'package:flutter/material.dart';
import 'package:rectrip/models/recommendation_models.dart';

class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Place> _searchResults = [];
  bool _isSearching = false;

  // 외부 API(Kakao, Google 등)를 호출하는 로직
  // 여기서는 임시 데이터로 대체합니다.
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    // ---- 실제 API 호출 로직 (예: Kakao Keyword Search) ----
    // final response = await http.get(Uri.parse('https://dapi.kakao.com/...'), headers: {'Authorization': 'KakaoAK YOUR_API_KEY'});
    // ...
    // setState(() { _searchResults = ... });

    // ---- Mock Search Logic ----
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _searchResults = [
        Place(id: 'search1', name: '$query 검색결과 1', address: '서울 어딘가'),
        Place(id: 'search2', name: '$query 검색결과 2', address: '서울 어딘가'),
      ];
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('장소 검색')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소 이름으로 검색',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchPlaces(_searchController.text),
                ),
              ),
              onSubmitted: _searchPlaces,
            ),
          ),
          if (_isSearching)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  return ListTile(
                    title: Text(place.name),
                    subtitle: Text(place.address),
                    onTap: () {
                      // 선택된 장소 정보를 이전 화면으로 반환
                      Navigator.pop(context, place);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}