import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

Future<Forecast> fetchForecast() async {
  //http://www.7timer.info/bin/api.pl?lon=-97.872&lat=22.282&product=civillight&output=json
  final response = await http.get('http://www.7timer.info/bin/api.pl?lon=-97.872&lat=22.282&product=civillight&output=json');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Forecast.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Forecast');
  }

}

class Forecast {
  final String product;
  final String init;
  final List<dynamic> dataSeries;


  Forecast({this.product, this.init, this.dataSeries});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      product: json['product'],
      init: json['init'],
      dataSeries: json['dataseries']
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Temperatura Tampico'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Forecast> futureForecast;
  @override
  void initState() {
    super.initState();
    futureForecast = fetchForecast();
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      futureForecast = fetchForecast();
    });
  }
  Widget weatherToImage(String weather){
    switch(weather){
      case "clear":
        return Image.asset("images/clear.png", width: 50, height: 50,);
      case "oshower":
        return Image.asset("images/rain.png", width: 50, height: 50,);
      default:
        return Text("Desconocido");
    }
  }
  
  Widget airToMS(int airCategory){
    var msj = ["","Calmado","Ligero","Moderado","Fresco","Fuerte","Vendaval",
               "Tormenta","Huracán"];
    return Row(
      children: [
        Image.asset("images/air.png", width: 25,height: 25,),
        Text(msj[airCategory]),
      ],
    );
  }


  Widget dayForecast(Forecast forecast, int day){
    var fecha = forecast.dataSeries[day]['date'].toString();
    var fecha_dt = DateTime.parse(fecha);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8 ),
      alignment: Alignment.topCenter,
      child: 
      Card(
        child:
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(fecha_dt.day.toString() + "/" + fecha_dt.month.toString() + "/" + fecha_dt.year.toString()),
              Column(children: [
                Text("Máx: "+ forecast.dataSeries[day]['temp2m']['max'].toString()),
                Text("Min: "+ forecast.dataSeries[day]['temp2m']['min'].toString()),
              ],),
              weatherToImage(forecast.dataSeries[day]['weather']),
              airToMS(forecast.dataSeries[day]["wind10m_max"]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child:
        FutureBuilder<Forecast>(
        future: futureForecast,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  dayForecast(snapshot.data, 0),
                  dayForecast(snapshot.data, 1),
                  dayForecast(snapshot.data, 2),
                  dayForecast(snapshot.data, 3),
                  dayForecast(snapshot.data, 4),
                  dayForecast(snapshot.data, 5),
                  dayForecast(snapshot.data, 6),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
        ),
      );
  }
}
