import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MyAttendance extends StatefulWidget {
  const MyAttendance({Key? key}) : super(key: key);

  @override
  State<MyAttendance> createState() => _MyAttendanceState();
}

class _MyAttendanceState extends State<MyAttendance> {
  String _locationMessage = '';
  String _connectionStatus = 'Unknown';
  String _connectionName = 'GSMConnection';
  String _connectionIP = 'IPAdress';

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();
      print('Connectivity Result: $results');
      _updateConnectionStatus(results[0]);
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  // Callback to handle connection changes
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        _connectionName = (await NetworkInfo().getWifiName()) ?? "WIFI Name";
        _connectionIP =
            (await NetworkInfo().getWifiIP()) ?? "IpAdress in not found";
        _connectionStatus = 'WiFi';

        break;
      case ConnectivityResult.mobile:
        _connectionStatus = 'Mobile';
        break;
      case ConnectivityResult.none:
        _connectionStatus = 'None';
        break;
      default:
        _connectionStatus = 'Unknown';
        break;
    }
    setState(() {
      _connectionStatus = _connectionStatus;
    });
  }

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          // Permissions are denied forever, handle appropriately.
          setState(() {
            _locationMessage = 'Location permissions are permanently denied.';
          });
          return;
        }
        if (permission == LocationPermission.denied) {
          // Permissions are denied, exit function.
          setState(() {
            _locationMessage = 'Location permissions are denied.';
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _locationMessage =
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
      });
    } catch (e) {
      print(e);
      setState(() {
        _locationMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_locationMessage),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: Text('Get Location'),
            ),
            Text(
                'Connection Status: $_connectionStatus   $_connectionName $_connectionIP'),
          ],
        ),
      ),
    );
  }
}
