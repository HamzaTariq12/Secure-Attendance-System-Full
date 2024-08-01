import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:start/models/Locations.dart';
import 'package:start/models/base_api_response.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../newscreen.dart';
import '../utils/toast.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({Key? key}) : super(key: key);

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String? _connectionName;
  String? _connectionIP;
  String? _connectionStatus;
  String? buildId;
  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    // _initConnectivity();
    assignValue();
    _getDeviceInfo(); // Added to retrieve device information
  }

  void assignValue() {
    getIPAddress().then((value) {
      setState(() {
        _connectionIP = value;
      });
    });
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      try {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        buildId = androidInfo.id;
      } catch (e) {
        // Handle any errors
        print('Error getting device info: $e');
      }
    }
  }

  Future<String> getIPAddress() async {
    try {
      bool isConnected = await _isConnectedToNetwork();
      if (isConnected) {
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.wifi)) {
          return _getWifiIPAddress();
        } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
          return _getCellularIPAddress();
        } else {
          return "Unknown";
        }
      } else {
        return "Not connected to any network";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<bool> _isConnectedToNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String> _getWifiIPAddress() async {
    try {
      var wifiName = await NetworkInfo().getWifiName();
      var wifiIP = await NetworkInfo().getWifiIP();
      _connectionName = wifiName;
      return wifiIP.toString();
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String> _getCellularIPAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            if (addr.address.isNotEmpty && !addr.address.startsWith("127.")) {
              _connectionName = addr.host;
              return addr.address;
            }
          }
        }
      }
      return "Unknown";
    } catch (e) {
      return "Error: $e";
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Future checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return showToast('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return showToast('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return showToast(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result!.code != null) {
          setState(() {
            isScanned = true;
          });
          controller.pauseCamera();
          showDialog(
            context: context,
            barrierDismissible:
                false, // Prevent dialog from closing on tap outside
            builder: (BuildContext context) {
              return Center(
                child: CircularProgressIndicator(), // Show loader
              );
            },
          );
          // controller.dispose();
          try {
            // Convert the scanned QR code result into Base64 encoding
            String base64Encoded = result!.code!;

            // Decode the Base64 encoded string back to its original form
            String decodedString = utf8.decode(base64.decode(base64Encoded));
            Map decodedData = json.decode(decodedString);

            // Calculate expiration
            String qrExpireAtString = decodedData['qr_expire_at'];
            DateTime qrExpireAt = DateTime.parse(qrExpireAtString);
            DateTime now = DateTime.now();

            Navigator.pop(context); // Close the loader dialog

            if (now.isAfter(qrExpireAt)) {
              // QR code has expired
              // print('QR code has expired');
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('QR Code Expired'),
                    content: Text('The QR code has expired.'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isScanned = false;
                          });
                          controller.resumeCamera();
                          Navigator.pop(context);
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  );
                },
              );
            } else {
              sendAttendance(
                decodedData,
              );
            }
          } catch (e) {
            // Handle decoding errors
            // print("Error decoding QR code: $e");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('Error decoding QR code: $e'),
                );
              },
            );
          }
        }
      });
    });
  }

  Future<void> sendAttendance(Map data) async {
    checkPermission();
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      LatLng studentLocation = LatLng(position.latitude, position.longitude);
      LatLng qrLocation = LatLng(data['latitude'], data['longitude']);
      double distance = LatLng.calculateDistance(studentLocation, qrLocation);
      bool isWithinDistance = studentLocation.isWithinDistance(qrLocation, 50);
      int id = data['id'];
      if (isWithinDistance) {
        String url = "teacher-course/attendance/mark/qr/$id";
        var body = {
          'latitude': studentLocation.latitude.toString(),
          'longitude': studentLocation.longitude.toString(),
          'ssid': _connectionName,
          'ip': _connectionIP,
          'device': buildId,
        };
        var response = await ApiService.putRequest(url, body);
        print(response.body);
        print(response.statusCode);
        if (response.statusCode == 201 || response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => SecondScreen(),
                        ),
                      );
                    },
                    child: Text('Ok'),
                  ),
                ],
                content: Text('Attendance marked successfully'),
              );
            },
          );
        } else if (response.statusCode >= 400 && response.statusCode <= 404) {
          if (response.body.contains('error')) {
            String error = json.decode(response.body)['error'];
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isScanned = false;
                        });
                        controller!.resumeCamera();
                        Navigator.pop(context);
                      },
                      child: Text('Retry'),
                    ),
                  ],
                  content: Text(error),
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isScanned = false;
                      });
                      controller!.resumeCamera();
                      Navigator.pop(context);
                    },
                    child: Text('Retry'),
                  ),
                ],
                content: Text('Attendance could not be marked'),
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isScanned = false;
                    });
                    controller!.resumeCamera();
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
              content: Text('Location accuracy is not within 10 meters.'),
            );
          },
        );
      }
    } catch (e) {
      print("Error: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Error: $e'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: scanArea,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: isScanned == true
                  ? Text('QR CODE Scanned')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
