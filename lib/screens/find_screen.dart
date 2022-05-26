import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stats/stats.dart';
//import 'package:flutter_map/flutter_map.dart';

import '../shared/menu_bottom.dart';
import '../models/weather.dart';
import '../models/point.dart';
import '../views/weather_view.dart';
import '../shared/open_weather_api.dart';
import '../shared/convex_hull.dart';


class FindScreen extends StatefulWidget {
  const FindScreen({Key? key}) : super(key: key);

  @override
  _FindScreenState createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {

  final OpenWeatherApiHttpClient client = OpenWeatherApiHttpClient();

  bool _isLoading = false;
  List<Weather> sunnyWeather = [];
  int totalCities = 0;
  int numberOfSearches = 0;
  int numberOfSteps = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Find sunshine!!')),
        bottomNavigationBar: const MenuBottom(),

        body: Column(
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(5, 20, 5, 10),
                child: Text(
                  0 != numberOfSearches ? "$totalCities cities in $numberOfSearches searches ($numberOfSteps steps)" : "",
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),

              Expanded(
                child:
                !_isLoading ?
                  ListView(
                      padding: const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                      children: List<Widget>.from(sunnyWeather.map((place) => WeatherView(place: place)),)
                  ) :
                  Container(
                    padding: const EdgeInsets.all(50),
                    margin: const EdgeInsets.all(50),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    onPressed: !_isLoading ? onPressed : null,
                    child: Text(
                      sunnyWeather.isEmpty ? 'Find' : 'Refresh',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),

            ]
        )
    );
  }

  Future onPressed() async {
    // Trigger loading
    setState((){
      _isLoading = true;
    });

    // Fetch data
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    sunnyWeather = await findTheSun(position.longitude, position.latitude);

    // End loading
    setState((){
      _isLoading = false;
    });
  }

  List<Weather> filterWeatherBySunny(List<Weather> data) {
    List<Weather> results = [];
    List<Weather> clear = List<Weather>.from(data.where((d) => 'Clear' == d.description));
    for (Weather item in clear) {
      // TODO Compare sunrise and sunset times for each location against the current time;
      results.add(item);
    }
    return results;
  }

  Future findTheSun(double longitude, double latitude) async {
    numberOfSearches = 0;
    numberOfSteps = 0;
    totalCities = 0;
    setState((){});

    final DateTime now = DateTime.now();
    List<Weather> data = await client.getWeatherWithin(longitude, latitude, 50);
    List<Weather> clear = List<Weather>.from(data.where((place) => 'Clear' == place.description));
    // TODO Compare sunrise and sunset times for each location against the current time;
    List<Weather> sunny = clear;

    numberOfSearches++;
    numberOfSteps++;
    totalCities = data.length;
    setState((){});

    if (!sunny.isNotEmpty) {
      //.BEGIN ConvexHull search

      developer.log("No sun found in initial vicinity");
      developer.log("Starting ConvexHull search");

      // Build convex hull from places to decrease searching space.
      List<Point> hull = convexHull(
          List<Point>.from(data.map((d) => Point(d.longitude, d.latitude))),
          data.length
      );

      // Dynamically determine search radius based on results
      List<double> distances = List<double>.from(data.map((d) => Geolocator.distanceBetween(latitude, longitude, d.latitude, d.longitude) / 1000));
      Stats stats = Stats.fromData(distances);
      double searchRadius = stats.median.toDouble() + (stats.standardDeviation.toDouble() / 2);
      print(stats);

      const int maxSearches = 100;
      List<String> searched = [];

      while(sunny.isEmpty) {
        int before = searched.length;

        // Break if we meet the maximum search attempts
        if (maxSearches < numberOfSearches) {
          break;
        }

        // Search along hull boundary.
        Point? previousPoint;
        double unsearchedDistance = 0.0;
        for (Point point in hull) {

          // Check if point has been searched before
          if (!searched.contains(point.toWKT())) {

            // Don't search a location if it is too close to
            // the previous searched location.
            if (null != previousPoint) {
              double distance = Geolocator.distanceBetween(point.y, point.x, previousPoint.y, previousPoint.x) / 1000;
              if ((unsearchedDistance + distance) < searchRadius) {
                unsearchedDistance += distance;
                continue;
              }
              unsearchedDistance = 0.0;
            }

            // Get weather for the current point location
            List<Weather> results = await client.getWeatherWithin(point.x, point.y, 50);
            data.addAll(results);
            data = data.toSet().toList();

            // Determine search area'
            double radius = results.map((d) => Geolocator.distanceBetween(point.y, point.x, d.latitude, d.longitude)).reduce(max);
            print("${point.toWKT()},$radius");

            // Update distances list
            distances.addAll(results.map((d) => Geolocator.distanceBetween(point.y, point.x, d.latitude, d.longitude)));

            // Make sure we don't search this location again
            searched.add(point.toWKT());

            numberOfSearches++;
            totalCities = data.toSet().toList().length;
            setState((){});
          }

          // Store previous searched point
          previousPoint = point;
        }

        // Update searched area
        hull = convexHull(
            List<Point>.from(data.map((d) => Point(d.longitude, d.latitude))),
            data.length
        );

        // Update search radius
        Stats stats = Stats.fromData(distances);
        searchRadius = stats.median.toDouble() + (stats.standardDeviation.toDouble() / 2);
        print(stats);

        // Update sunny list
        clear = List<Weather>.from(data.where((place) => 'Clear' == place.description));
        // TODO Compare sunrise and sunset times for each location against the current time;
        List<Weather> sunny = clear;


        // Check if an area was searched in this pass
        if (before == searched.length) {
          developer.log("No new cities");
          break;
        }

        numberOfSteps++;
        setState((){});
      }

      //.END ConvexHull search
    }

    totalCities = data.map((d) => d.name).toSet().toList().length;
    setState((){});

    // TODO
    // Get driving distance
    for (Weather place in sunny) {
      place.distance = Geolocator.distanceBetween(latitude, longitude, place.latitude, place.longitude) / 1000;
    }

    // Order by distance
    sunny.sort((a, b) => a.distance.compareTo(b.distance));

    return sunny;
  }



}