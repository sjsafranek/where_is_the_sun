import 'package:flutter/material.dart';

import '../models/weather.dart';


class WeatherView extends StatelessWidget {
  const WeatherView({Key? key, required this.place}) : super(key: key);
  final Weather place;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      // TODO: LINK TO MAP
      child: Text(
          "${place.name} --> ${place.description} (${place.distance.toStringAsFixed(2)} km)",
          style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
