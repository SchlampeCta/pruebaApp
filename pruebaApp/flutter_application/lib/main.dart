// main.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'weather_service.dart';
import 'forecast_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  final WeatherService weatherService = WeatherService();

  Future<Map<String, dynamic>> _fetchWeather() async {
    Position position = await _determinePosition();
    return await weatherService.fetchWeather(
        position.latitude, position.longitude);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Localización desactivada.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisos de localización denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de localización están denegados permanentemente');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App del tiempo'),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error al buscar el tiempo: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final weatherData = snapshot.data!;
              final temperature = weatherData['main']['temp'].toString();
              final description = weatherData['weather'][0]['description'];
              final icon = weatherData['weather'][0]['icon'];

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Temperature: $temperature°C',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    'Description: $description',
                    style: TextStyle(fontSize: 20),
                  ),
                  icon.isNotEmpty
                      ? Image.network(
                          'https://openweathermap.org/img/wn/$icon@2x.png',
                          width: 100,
                          height: 100,
                        )
                      : Container(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Forzamos a `FutureBuilder` a reconstruirse con los nuevos datos
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WeatherScreen(), // Actualiza la pantalla
                        ),
                      );
                    },
                    child: Text('Actualizar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForecastScreen(
                            latitude: weatherData['coord']['lat'],
                            longitude: weatherData['coord']['lon'],
                          ),
                        ),
                      );
                    },
                    child: Text('Ver predicción'),
                  ),
                ],
              );
            } else {
              return Text('No hay datos disponibles');
            }
          },
        ),
      ),
    );
  }
}


