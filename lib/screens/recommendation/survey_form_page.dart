// lib/screens/recommendation/survey_form_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rectrip/providers/recommendation_provider.dart';
import 'package:rectrip/screens/recommendation/recommendation_result_page.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/main_backend_api_service.dart';
import 'recommendation_place_selection_page.dart';

class SurveyFormPage extends StatefulWidget {
  @override
  _SurveyFormPageState createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  String? _selectedLocation;
  String? _selectedTheme;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // CalendarFormat을 .month로 고정합니다.
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final List<String> _seoulDistricts = [
    '강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구',
    '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구', '성동구',
    '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구', '종로구', '중구', '중랑구'
  ];

  // 중복 선택을 위한 Set
  final Set<String> _selectedSurveyTags = {};
  // CSV에서 불러온 태그 목록을 저장할 리스트
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    // 페이지가 시작될 때 태그를 미리 불러옵니다.
    _loadAvailableTags();
  }

  final _apiService = MainBackendApiService();

  Future<void> _loadAvailableTags() async {
    final tags = await _apiService.getTagList();
    setState(() {
      _availableTags = tags;
    });
  }

  // 날짜 선택 로직 수정
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _rangeStart = start;
      // 사용자가 시작일만 선택한 경우(아직 범위를 드래그 중인 경우), 종료일은 null일 수 있습니다.
      _rangeEnd = end;
    });
  }

  void _submitSurvey() {
    // 시작일만 선택된 경우, 종료일을 시작일과 동일하게 설정하여 하루 여행으로 처리합니다.
    final finalStartDate = _rangeStart;
    final finalEndDate = _rangeEnd ?? _rangeStart;

    if (_selectedLocation == null || _rangeStart == null || _rangeEnd == null || _selectedTheme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 항목을 선택해주세요.')),
      );
      return;
    }

    final provider = Provider.of<RecommendationProvider>(context, listen: false);

    // provider의 fetchRecommendations 호출
    provider.fetchRecommendations(
      location: _selectedLocation!,
      startDate: _rangeStart!,
      endDate: _rangeEnd!,
      theme: _selectedTheme!,
    ).then((_) {
      // 데이터 로딩이 끝나면, provider에서 데이터를 가져와 PlaceSelectionPage로 전달
      final initialPlaces = provider.itinerary;
      if (initialPlaces.isNotEmpty) {
        Navigator.push( // pushReplacement 대신 push 사용
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationPlaceSelectionPage(
              initialPlacesByDate: initialPlaces,
              // 여행 제목을 다음 페이지로 전달
              tripTitle: "${_selectedLocation!} ${_selectedTheme!} 여행",
            ),
          ),
        );
      } else {
        // 데이터가 비어있을 경우 에러 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추천 데이터를 불러오지 못했습니다.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('추천 설문조사')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('어디로 여행가시나요?', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              hint: Text('서울의 구를 선택하세요'),
              onChanged: (value) => setState(() => _selectedLocation = value),
              items: _seoulDistricts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 24),

            Text('언제 여행가시나요?', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.now().subtract(Duration(days: 365)),
              lastDay: DateTime.now().add(Duration(days: 365)),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              onRangeSelected: _onRangeSelected,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
              calendarStyle: CalendarStyle(
                rangeHighlightColor: Colors.teal.withOpacity(0.2),
                todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                rangeStartDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                rangeEndDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
              ),
            ),
            SizedBox(height: 24),

            Text('어떤 테마의 여행을 원하시나요? (중복 선택 가능)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _availableTags.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
              spacing: 8.0,
              children: _availableTags.map((tag) {
                final isSelected = _selectedSurveyTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSurveyTags.add(tag);
                      } else {
                        _selectedSurveyTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _submitSurvey,
              child: Consumer<RecommendationProvider>(
                builder: (context, provider, child) {
                  return provider.isLoading
                      ? CircularProgressIndicator(color: Colors.white,)
                      : Text('추천 결과 보기');
                },
              ),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}