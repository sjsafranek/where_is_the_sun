import 'package:flutter/services.dart';

class Weather {
  int id = 0;
  String name = '';
  String description = '';
  double temperature = 0;
  double perceived = 0;
  int pressure = 0;
  int humidity = 0;
  double longitude = 0.0;
  double latitude = 0.0;
  double distance = 0.0;

  Weather(this.id, this.name, this.description, this.temperature, this.perceived, this.pressure, this.humidity);

  Weather.fromJson(Map<String, dynamic> openWeatherMap) {
    this.id = openWeatherMap['id'];
    this.name = openWeatherMap['name'];
    this.temperature = (openWeatherMap['main']['temp'] - 273.13) ?? 0;
    this.perceived = (openWeatherMap['main']['feels_like'] - 273.13) ?? 0;
    this.pressure = openWeatherMap['main']['pressure'];
    this.humidity = openWeatherMap['main']['humidity'];
    this.longitude = openWeatherMap['coord']['lon'];
    this.latitude = openWeatherMap['coord']['lat'];
    this.description = openWeatherMap['weather'][0]['main'] ?? '';
  }

  // Handle toSet()
  @override
  bool operator ==(Object other) {
    return other != null && other is Weather && this.hashCode == other.hashCode;
  }

  @override
  int get hashCode => this.id;

}