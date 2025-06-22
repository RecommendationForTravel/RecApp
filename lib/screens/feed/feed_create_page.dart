import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rectrip/services/main_backend_api_service.dart';

// 일자별 폼 데이터를 관리하기 위한 UI용 클래스
class DailyLogForm {
  final DateTime date;
  final TextEditingController placeController;
  final TextEditingController commentController;
  final TextEditingController costController;
  final TextEditingController regionController; // 지역 입력을 위한 컨트롤러
  final TextEditingController latitudeController; // 위도 입력을 위한 컨트롤러
  final TextEditingController longitudeController; // 경도 입력을 위한 컨트롤러
  String? selectedTransportation;
  String? selectedCategory; // 선택된 장소 카테고리

  DailyLogForm({required this.date})
      : placeController = TextEditingController(),
        commentController = TextEditingController(),
        costController = TextEditingController(),
        regionController = TextEditingController(),
        latitudeController = TextEditingController(),
        longitudeController = TextEditingController();
}

class FeedCreatePage extends StatefulWidget {
  const FeedCreatePage({Key? key}) : super(key: key);

  @override
  _FeedCreatePageState createState() => _FeedCreatePageState();
}

class _FeedCreatePageState extends State<FeedCreatePage> {
  final _apiService = MainBackendApiService();
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController(); // 전체 게시글 태그 컨트롤러

  DateTimeRange? _travelDate;
  List<DailyLogForm> _dailyForms = [];
  bool _isLoading = false;

  // 백엔드 enum과 동일한 목록
  final List<String> _transportationOptions = [
    'BUS', 'SUBWAY', 'TAXI', 'CAR', 'WALK', 'BICYCLE'
  ];
  final List<String> _placeCategoryOptions = [
    'CAFE', 'RESTAURANT', 'ACCOMMODATION', 'TOURIST_ATTRACTION', 'PARK',
    'MUSEUM', 'SHOPPING', 'ENTERTAINMENT', 'HISTORICAL_SITE', 'BEACH',
    'MOUNTAIN', 'TEMPLE', 'ETC'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    for (var form in _dailyForms) {
      form.placeController.dispose();
      form.commentController.dispose();
      form.costController.dispose();
      form.regionController.dispose();
      form.latitudeController.dispose();
      form.longitudeController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _travelDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: '여행 기간을 선택하세요',
    );
    if (picked != null) {
      setState(() {
        _travelDate = picked;
        _generateDailyForms();
      });
    }
  }

  void _generateDailyForms() {
    if (_travelDate == null) return;
    _dailyForms.clear();
    final dayCount = _travelDate!.duration.inDays + 1;
    for (int i = 0; i < dayCount; i++) {
      final date = _travelDate!.start.add(Duration(days: i));
      _dailyForms.add(DailyLogForm(date: date));
    }
  }

  // 게시물 저장 로직
  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 여행 기간을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- UI 데이터를 백엔드 PublishDto 구조에 맞게 매핑 ---
    final List<String> allTags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final Map<String, dynamic> postData = {
      "title": _titleController.text,
      "comment": _dailyForms.map((form) => form.commentController.text).toList(),
      "travelDate": {
        "startDate": DateFormat('yyyy-MM-dd').format(_travelDate!.start),
        "endDate": DateFormat('yyyy-MM-dd').format(_travelDate!.end)
      },
      "visitDateList": _dailyForms.map((form) => DateFormat('yyyy-MM-dd').format(form.date)).toList(),
      "placeList": _dailyForms.map((form) => form.placeController.text).toList(),
      "cost": _dailyForms.map((form) => int.tryParse(form.costController.text) ?? 0).toList(),
      "transportationList": _dailyForms.map((form) => form.selectedTransportation ?? 'ETC').toList(),
      // --- 새로 추가된 필드 매핑 ---
      "placeLocationList": _dailyForms.map((form) => {
        "latitude": double.tryParse(form.latitudeController.text) ?? 0.0,
        "longitude": double.tryParse(form.longitudeController.text) ?? 0.0,
      }).toList(),
      "placeCategoryList": _dailyForms.map((form) => form.selectedCategory ?? 'ETC').toList(),
      // 백엔드가 요구하는 TagDto 형식 ({"name": "태그명"})으로 변환
      "placeTagPairList": allTags.map((tag) => {"name": tag}).toList(),
      // 백엔드가 요구하는 Region 형식 ({"area1": "지역명", ...})으로 변환
      "regionList": _dailyForms.map((form) => {
        "area1": form.regionController.text, // 예시로 area1에만 값을 넣음
        "area2": null,
      }).toList(),
      // 사진은 현재 지원하지 않으므로 빈 리스트 전송
      "placePhotoUrlPairList": [],
    };

    final success = await _apiService.publishPost(postData);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 성공적으로 등록되었습니다!')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 등록에 실패했습니다. 입력값을 확인해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("새 여행기 작성"),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: const Text("등록"),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "제목"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: "태그",
              hintText: "쉼표(,)로 구분하여 입력 (예: 힐링, 맛집)",
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(_travelDate == null
                ? "여행 기간 선택"
                : "${DateFormat('yyyy.MM.dd').format(_travelDate!.start)} - ${DateFormat('yyyy.MM.dd').format(_travelDate!.end)}"),
            onPressed: () => _selectDateRange(context),
          ),
          const Divider(height: 40),
          if (_dailyForms.isNotEmpty)
            ..._dailyForms.map((form) => _buildDailyLogForm(form)).toList(),
        ],
      ),
    );
  }

  // 일자별 입력 폼 위젯
  Widget _buildDailyLogForm(DailyLogForm form) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('M월 d일 (E)', 'ko_KR').format(form.date),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: form.placeController,
              decoration: const InputDecoration(labelText: "방문 장소"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: form.selectedCategory,
              decoration: const InputDecoration(labelText: "장소 카테고리"),
              hint: const Text("선택"),
              items: _placeCategoryOptions.map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              )).toList(),
              onChanged: (String? newValue) => setState(() => form.selectedCategory = newValue),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: form.regionController,
              decoration: const InputDecoration(labelText: "지역 (예: 서울시 강남구)"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.latitudeController,
                    decoration: const InputDecoration(labelText: "위도"),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: form.longitudeController,
                    decoration: const InputDecoration(labelText: "경도"),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.costController,
                    decoration: const InputDecoration(labelText: "비용 (원)"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: form.selectedTransportation,
                    decoration: const InputDecoration(labelText: "교통수단"),
                    hint: const Text("선택"),
                    items: _transportationOptions.map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    )).toList(),
                    onChanged: (String? newValue) => setState(() => form.selectedTransportation = newValue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: form.commentController,
              decoration: const InputDecoration(labelText: "코멘트"),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
