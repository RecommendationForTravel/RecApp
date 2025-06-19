// lib/screens/recommendation_flow/3_recommendation_result_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rectrip/models/recommendation_models.dart';
import 'package:rectrip/providers/recommendation_provider.dart';
import '4_place_search_page.dart';

class RecommendationResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (provider.itineraries.isEmpty) {
          return Scaffold(body: Center(child: Text('추천 결과를 불러오지 못했습니다.')));
        }

        return DefaultTabController(
          length: provider.itineraries.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text('추천 여행기'),
              bottom: TabBar(
                tabs: provider.itineraries
                    .map((it) => Tab(text: DateFormat('M.d(E)', 'ko_KR').format(it.date)))
                    .toList(),
              ),
            ),
            body: TabBarView(
              children: provider.itineraries
                  .map((itinerary) => DailyItineraryView(itinerary: itinerary))
                  .toList(),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // 최종 결과 화면으로 이동 (구현 필요)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('최종 결과 화면으로 이동합니다 (구현 필요).')),
                  );
                },
                child: Text('장소 선택 완료'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DailyItineraryView extends StatelessWidget {
  final DailyItinerary itinerary;
  const DailyItineraryView({Key? key, required this.itinerary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = itinerary.placesByCategory.keys.toList();

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final places = itinerary.placesByCategory[category]!;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category, style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.teal),
                      onPressed: () async {
                        // 장소 검색 페이지로 이동하고, 결과(Place)를 받아옴
                        final Place? newPlace = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlaceSearchPage()),
                        );
                        if (newPlace != null) {
                          Provider.of<RecommendationProvider>(context, listen: false)
                              .addPlace(itinerary.date, category, newPlace);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ...places.map((place) => ListTile(
                  title: Text(place.name),
                  subtitle: Text(place.address),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () {
                      Provider.of<RecommendationProvider>(context, listen: false)
                          .removePlace(itinerary.date, category, place);
                    },
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}