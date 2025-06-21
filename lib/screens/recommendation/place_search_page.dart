// lib/screens/recommendation/place_search_page.dart (수정)
import 'package:flutter/material.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/services/naver_api_service.dart'; // kakao_api_service 대신 naver_api_service를 import

class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  // 서비스를 NaverApiService로 변경
  final _naverApiService = NaverApiService();
  final _searchController = TextEditingController();
  List<Place> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage; // 에러 메시지를 상태로 관리

  void _searchPlaces(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null; // 새로운 검색 시작 시 에러 메시지 초기화
    });

    try {
      // naverApiService의 함수를 호출
      final results = await _naverApiService.searchByKeyword(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        // 사용자에게 보여줄 에러 메시지 설정
        _errorMessage = e.toString();
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
            hintText: '장소, 주소 검색 (네이버)', // 힌트 텍스트 변경
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
    // 에러 메시지가 있을 경우 표시
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '오류가 발생했습니다.\n$_errorMessage',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
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
