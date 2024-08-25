// TODO Implement this library.
// weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '0c96831169475325b1bf88cb0ca3718f'; 

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar datos del clima');
    }
  }

  Future<List<dynamic>> fetchForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&cnt=24&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['list'];
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}

