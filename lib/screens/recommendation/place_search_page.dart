// lib/screens/recommendation/place_search_page.dart (신규 파일)
import 'package:flutter/material.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/services/kakao_api_service.dart';

class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final _kakaoApiService = KakaoApiService();
  final _searchController = TextEditingController();
  List<Place> _searchResults = [];
  bool _isLoading = false;
  bool _hasError = false;

  void _searchPlaces(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await _kakaoApiService.searchByKeyword(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      print(e); // 디버깅을 위한 에러 출력
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '장소, 주소 검색',
            border: InputBorder.none,
          ),
          onSubmitted: _searchPlaces,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _searchPlaces(_searchController.text),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return Center(
        child: Text(
          '오류가 발생했습니다.\nAPI 키를 확인하거나 인터넷 연결을 확인해주세요.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_searchResults.isEmpty) {
      return Center(child: Text('검색 결과가 없습니다.'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        return ListTile(
          title: Text(place.placeName),
          subtitle: Text(place.roadAddressName),
          onTap: () {
            // 장소 선택 시, 이전 화면으로 선택된 장소 정보를 반환
            Navigator.pop(context, place);
          },
        );
      },
    );
  }
}