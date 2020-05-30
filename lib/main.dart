import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Album> fetchAlbum() async {
  final response = await http.get('https://randomfox.ca/floof/');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String image, link;

  Album({this.image, this.link});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      image: json['image'],
      link: json['link'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  void handleTap() {
    setState(() {
      futureAlbum = fetchAlbum();
    });
  }

  @override
  Widget build(BuildContext context) {
    var title = 'Random Fox';
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(title, style: TextStyle(fontSize: 40))),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return InkWell(
                    onTap: handleTap,
                    child: Container(
                        width: 300.0,
                        height: 300.0,
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: new NetworkImage(snapshot.data.image),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(150.0)),
                            border: new Border.all(
                              color: Colors.deepOrangeAccent[100],
                              width: 10.0,
                            ))));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
