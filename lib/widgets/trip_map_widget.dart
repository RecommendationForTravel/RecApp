// lib/widgets/trip_map_widget.dart (수정)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:rectrip/models/place_model.dart';

class TripMapWidget extends StatefulWidget {
  final List<Place> places;
  final bool showNumbers; // 마커에 번호를 표시할지 여부

  const TripMapWidget({
    Key? key,
    required this.places,
    this.showNumbers = false, // 기본값은 false
  }) : super(key: key);

  @override
  State<TripMapWidget> createState() => _TripMapWidgetState();
}

class _TripMapWidgetState extends State<TripMapWidget> {
  NaverMapController? _mapController;
  final Completer<NaverMapController> _controllerCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: Center(
          child: Text(
            "지도에 표시할 장소가 없습니다.",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      height: 250,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: widget.places.first.latLng,
            zoom: 12,
          ),
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _updateMarkers(widget.places);
          if (!_controllerCompleter.isCompleted) {
            _controllerCompleter.complete(controller);
          }
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TripMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // places 목록이 실제로 변경되었을 때만 마커를 업데이트합니다.
    if (oldWidget.places != widget.places) {
      _updateMarkers(widget.places);
    }
  }

  /// 지도에 마커를 업데이트하는 함수
  void _updateMarkers(List<Place> places) async {
    if (_mapController == null) return;

    // 기존 오버레이(마커)를 모두 제거합니다.
    await _mapController!.clearOverlays();
    if (places.isEmpty) return;

    final Set<NMarker> markers = {};
    for (int i = 0; i < places.length; i++) {
      final place = places[i];

      // --- 에러 수정 부분 ---
      // icon과 caption은 NMarker 생성자에서 직접 설정해야 합니다.
      NOverlayCaption caption;
      if (widget.showNumbers) {
        // showNumbers가 true일 때, 캡션에 순서 번호를 추가합니다.
        caption = NOverlayCaption(text: '${i + 1}. ${place.placeName}');
      } else {
        caption = NOverlayCaption(text: place.placeName);
      }

      // 참고: 번호가 있는 커스텀 마커 아이콘을 사용하려면,
      // 1. 프로젝트의 assets 폴더에 'marker_1.png', 'marker_2.png' ... 와 같은 이미지 파일을 추가해야 합니다.
      // 2. pubspec.yaml 파일에 해당 assets 폴더를 등록해야 합니다.
      // 예: icon: NOverlayImage.fromAssetImage('assets/images/marker_${i+1}.png')
      // 현재는 기본 마커를 사용합니다.

      final marker = NMarker(
        id: place.placeName + i.toString(), // 마커의 고유 ID
        position: place.latLng,             // 마커의 위치 (위경도)
        caption: caption,                   // 마커 하단에 표시될 텍스트 (수정됨)
        // icon: icon,                      // 커스텀 아이콘 (수정됨)
      );

      markers.add(marker);
    }

    // 준비된 마커들을 지도에 한 번에 추가합니다.
    _mapController!.addOverlayAll(markers);

    // 모든 마커가 보이도록 카메라 위치를 자동으로 조정합니다.
    if (places.length > 1) {
      final bounds = NLatLngBounds.from(places.map((p) => p.latLng).toList());
      _mapController!.updateCamera(
        NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(50)),
      );
    } else {
      _mapController!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(target: places.first.latLng, zoom: 14),
      );
    }
  }
}
