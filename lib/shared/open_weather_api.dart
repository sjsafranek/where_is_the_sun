import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather.dart';


class OpenWeatherApiHttpClient {
  // https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
  // https://api.openweathermap.org/data/2.5/weather?lat=0.0&lon=0.0&appid=878b346c2b273d997608b5e696507a63
  final String authority = 'api.openweathermap.org';
  final String endpoint = 'data/2.5/weather';
  final String apikey = '878b346c2b273d997608b5e696507a63';

  Future<List<Weather>> getWeatherWithin(double longitude, double latitude, int radius) async {
    Uri uri = Uri.parse('https://api.openweathermap.org/data/2.5/find?lat=${latitude}&lon=${longitude}&cnt=${radius}&appid=${this.apikey}');
    http.Response result = await http.get(uri);
    Map<String, dynamic> data = json.decode(result.body);
    return List<Weather>.from(
        data['list'].map((data) =>
            Weather.fromJson(data)
        ).toList()
    );
  }

  Future<Weather> getWeatherByPosition(double longitude, double latitude) async {
    Uri uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${this.apikey}');
    http.Response result = await http.get(uri);
    Map<String, dynamic> data = json.decode(result.body);
    Weather weather = Weather.fromJson(data);
    return weather;
  }

  Future<Weather> getWeatherByCity(String city) async {
    Uri uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${this.apikey}');
    http.Response result = await http.get(uri);
    Map<String, dynamic> data = json.decode(result.body);
    Weather weather = Weather.fromJson(data);
    return weather;
  }

}