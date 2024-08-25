// TODO Implement this library.
// forecast_screen.dart
import 'package:flutter/material.dart';
import 'weather_service.dart';

class ForecastScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  ForecastScreen({required this.latitude, required this.longitude});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherService weatherService = WeatherService();
  bool _loading = false;
  List<dynamic> _forecastData = [];

  @override
  void initState() {
    super.initState();
    _getForecast();
  }

  Future<void> _getForecast() async {
    setState(() {
      _loading = true;
    });

    try {
      final forecastData =
          await weatherService.fetchForecast(widget.latitude, widget.longitude);
      setState(() {
        _forecastData = forecastData;
      });
    } catch (e) {
      print('Error al mostrar el pronostico: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pronostico del tiempo'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _forecastData.length,
              itemBuilder: (context, index) {
                final forecast = _forecastData[index];
                final temperature = forecast['main']['temp'];
                final description = forecast['weather'][0]['description'];
                final icon = forecast['weather'][0]['icon'];

                return ListTile(
                  leading: Image.network(
                    'https://openweathermap.org/img/wn/$icon@2x.png',
                    width: 50,
                    height: 50,
                  ),
                  title: Text(
                    'Day ${index + 1}: $temperature°C',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
    );
  }
}
