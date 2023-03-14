import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _hasPermisssion = false;
  @override
  void initState() {
    fetchPermission();
    super.initState();
  }

  void fetchPermission() {
    Permission.locationWhenInUse.status.then((value) {
      if (mounted) {
        setState(() {
          _hasPermisssion = value == PermissionStatus.granted;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(
      builder: (context) {
        if (_hasPermisssion) {
          return _buildCompass();
        } else {
          return _buildPermission();
        }
      },
    ));
  }

  Widget _buildPermission() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Permission.locationWhenInUse
              .request()
              .then((value) => fetchPermission());
        },
        child:const  Text('Request'),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        double? direction = snapshot.data!.heading;
        if (direction == null) {
          return const Center(
            child: Text('Устройства не поддерживает'),
          );
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Transform.rotate(
                angle: direction * (pi / 180) - 1,
                child: Image.asset('images/compass.png')),
          ),
        );
      },
    );
  }
}
