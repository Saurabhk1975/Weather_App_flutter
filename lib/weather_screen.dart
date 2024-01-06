import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/AdditionalWidget.dart';
import 'package:weather_app/HourlyWidget.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityname = 'London';
      final res = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$cityname,uk&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected Error Occured';
      }
      return data;
      //data['list'][0]['main']['temp'];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 223, 198, 198),
          ),
        ),
        centerTitle: true,
        // icon ke liye action widget ka use karte hai
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final weatherdata = data['list'][0];
          final currentweather = weatherdata['main']['temp'];
          final currentsky = weatherdata['weather'][0]['main'];
          final currentpressure = weatherdata['main']['pressure'];
          final currenthumidity = weatherdata['main']['humidity'];
          final currentwindspeed = weatherdata['wind']['speed'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // main card
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$currentweather °K',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Icon(
                                    currentsky == 'Rain' ||
                                            currentsky == 'Clouds'
                                        ? Icons.cloud
                                        : Icons.wb_sunny_rounded,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    currentsky,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // weather forecast card
                    const Text(
                      'Hourly Forecast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                    //       for (int i = 0; i < 38; i++)
                    //         HourlyWidget(
                    //           heading: data['list'][i + 1]['dt'].toString(),
                    //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                    //                       'Rain' ||
                    //                   data['list'][i + 1]['weather'][0]
                    //                           ['main'] ==
                    //                       'Clouds'
                    //               ? Icons.cloud
                    //               : Icons.wb_sunny_rounded,
                    //           data: data['list'][i + 1]['main']['temp']
                    //               .toString(),
                    //         ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final hourlyforcast = data['list'][index + 1];
                          final hourlysky =
                              data['list'][index + 1]['weather'][0]['main'];
                          final time = DateTime.parse(
                              hourlyforcast['dt_txt'].toString());
                          return HourlyWidget(
                            heading: DateFormat.j().format(time),
                            icon: hourlysky == 'Rain' || hourlysky == 'Clouds'
                                ? Icons.cloud
                                : Icons.wb_sunny_rounded,
                            data: hourlyforcast['main']['temp'].toString(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    // additional information  card
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalWidget(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: currenthumidity.toString(),
                        ),
                        AdditionalWidget(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: currentwindspeed.toString(),
                        ),
                        AdditionalWidget(
                          icon: Icons.beach_access_outlined,
                          label: 'Pressure',
                          value: currentpressure.toString(),
                        ),
                      ],
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }
}
