import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rectrip/models/place_model.dart';
import 'package:rectrip/screens/recommendation/place_search_page.dart';
import 'package:rectrip/services/main_backend_api_service.dart';

// 일자별 폼 데이터를 관리하기 위한 UI용 클래스
class DailyLogForm {
  final DateTime date;
  Place? selectedPlace; // 네이버 검색을 통해 선택된 장소 정보
  final TextEditingController commentController;
  final TextEditingController costController;
  String? selectedTransportation;
  String? selectedCategory; // 장소 카테고리

  DailyLogForm({required this.date})
      : commentController = TextEditingController(),
        costController = TextEditingController();
}

class FeedCreatePage extends StatefulWidget {
  const FeedCreatePage({Key? key}) : super(key: key);

  @override
  _FeedCreatePageState createState() => _FeedCreatePageState();
}

class _FeedCreatePageState extends State<FeedCreatePage> {
  final _apiService = MainBackendApiService();
  final _titleController = TextEditingController();

  DateTimeRange? _travelDate;
  List<DailyLogForm> _dailyForms = [];
  bool _isLoading = false;

  final Set<String> _selectedPostTags = {};
  List<String> _availableTags = [];

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
  void initState() {
    super.initState();
    _loadAvailableTags();
  }

  Future<void> _loadAvailableTags() async {
    final tags = await _apiService.getTagList();
    if (mounted) {
      setState(() => _availableTags = tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var form in _dailyForms) {
      form.commentController.dispose();
      form.costController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _travelDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 여행 기간을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- 백엔드 PublishDto 구조에 맞게 매핑 (placeTagPairList 수정) ---
    final Map<String, dynamic> postData = {
      "title": _titleController.text,
      "comment": _dailyForms.map((form) => form.commentController.text).toList(),
      "travelDate": {
        "startDate": DateFormat('yyyy-MM-dd').format(_travelDate!.start),
        "endDate": DateFormat('yyyy-MM-dd').format(_travelDate!.end)
      },
      "visitDateList": _dailyForms.map((form) => DateFormat('yyyy-MM-dd').format(form.date)).toList(),
      "placeList": _dailyForms.map((form) => form.selectedPlace?.placeName ?? '').toList(),
      "cost": _dailyForms.map((form) => int.tryParse(form.costController.text) ?? 0).toList(),
      "transportationList": _dailyForms.map((form) => form.selectedTransportation ?? 'ETC').toList(),
      "placeLocationList": _dailyForms.map((form) => {
        "latitude": form.selectedPlace?.y ?? 0.0,
        "longitude": form.selectedPlace?.x ?? 0.0,
      }).toList(),
      "placeCategoryList": _dailyForms.map((form) => form.selectedCategory ?? 'ETC').toList(),
      // 백엔드 TagDto 형식 {"place": null, "tag": "태그명"}으로 변환
      "placeTagPairList": _selectedPostTags.map((tag) => {"place": null, "tag": tag}).toList(),
      "regionList": _dailyForms.map((form) {
        final address = form.selectedPlace?.roadAddressName.split(' ');
        return {
          "area1": address != null && address.isNotEmpty ? address[0] : null,
          "area2": address != null && address.length > 1 ? address[1] : null,
        };
      }).toList(),
      "placePhotoUrlPairList": [],
    };

    final success = await _apiService.publishPost(postData);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시물이 등록되었습니다!')));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시물 등록에 실패했습니다.')));
      }
    }
  }

  Future<void> _searchAndSetPlace(DailyLogForm form) async {
    final Place? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaceSearchPage()),
    );
    if (result != null) {
      setState(() => form.selectedPlace = result);
    }
  }

  // --- 태그 선택 UI 수정: 팝업(Dialog)으로 변경 ---
  Future<void> _showTagSelectionDialog() async {
    // 임시로 선택 상태를 관리할 Set
    final Set<String> tempSelectedTags = Set.from(_selectedPostTags);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('태그 선택'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return SingleChildScrollView(
                child: _availableTags.isEmpty
                    ? const Center(child: Text("태그 로딩 중..."))
                    : Wrap(
                  spacing: 8.0,
                  children: _availableTags.map((tag) {
                    final isSelected = tempSelectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            tempSelectedTags.add(tag);
                          } else {
                            tempSelectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('선택 완료'),
              onPressed: () {
                setState(() {
                  _selectedPostTags.clear();
                  _selectedPostTags.addAll(tempSelectedTags);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 여행기 작성', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
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
            decoration: const InputDecoration(labelText: "제목", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(_travelDate == null
                ? "여행 기간 선택"
                : "${DateFormat('yyyy.MM.dd').format(_travelDate!.start)} - ${DateFormat('yyyy.MM.dd').format(_travelDate!.end)}"),
            onPressed: () => _selectDateRange(context),
          ),
          const SizedBox(height: 20),

          // --- 태그 선택 UI를 버튼으로 변경 ---
          OutlinedButton.icon(
            icon: const Icon(Icons.tag),
            label: const Text("태그 선택"),
            onPressed: _showTagSelectionDialog,
          ),
          // 선택된 태그를 보여주는 부분
          if (_selectedPostTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8.0,
                children: _selectedPostTags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ),

          const Divider(height: 40),
          if (_dailyForms.isNotEmpty)
            ..._dailyForms.map((form) => _buildDailyLogForm(form)).toList(),
        ],
      ),
    );
  }

  Widget _buildDailyLogForm(DailyLogForm form) {
    // ... 기존 _buildDailyLogForm 위젯 코드는 변경 없음 ...
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
            const Text("방문 장소", style: TextStyle(color: Colors.grey)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(form.selectedPlace?.placeName ?? "장소를 검색해주세요"),
              subtitle: Text(form.selectedPlace?.roadAddressName ?? ""),
              trailing: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchAndSetPlace(form),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: form.selectedCategory,
              decoration: const InputDecoration(labelText: "장소 카테고리"),
              items: _placeCategoryOptions
                  .map((val) => DropdownMenuItem<String>(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) => setState(() => form.selectedCategory = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.costController,
                    decoration: const InputDecoration(labelText: "비용 (원)"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: form.selectedTransportation,
                    decoration: const InputDecoration(labelText: "교통수단"),
                    items: _transportationOptions
                        .map((val) => DropdownMenuItem<String>(value: val, child: Text(val)))
                        .toList(),
                    onChanged: (val) => setState(() => form.selectedTransportation = val),
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
