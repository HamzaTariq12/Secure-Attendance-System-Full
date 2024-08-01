import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:start/models/attendance_model.dart';
import 'package:intl/intl.dart';
import 'package:start/models/base_api_response.dart';

class Myhome extends StatefulWidget {
  Myhome() : super();

  final String title = "Student Attendance";

  @override
  MyhomeState createState() => MyhomeState();
}

class MyhomeState extends State<Myhome> {
  String getDate(dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat.yMd().format(dateTime);
  }

  String getTime(dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat.Hm().format(dateTime);
  }

  Future<List<AttendanceModel>> attendanceModel() async {
    var response = await ApiService.getRequest('student/attendance/');
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData);
      return jsonData.map((json) => AttendanceModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load attendance data');
    }
  }

  SingleChildScrollView dataBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<List<AttendanceModel>>(
        future: attendanceModel(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(
                  child: CircularProgressIndicator(
                color: Colors.greenAccent,
              )),
            ); // Display a loading indicator while waiting for data
          } else if (snapshot.hasError) {
            return Text(
                "Error: ${snapshot.error}"); // Display an error message if fetching data fails
          } else {
            List<AttendanceModel> attendanceData =
                snapshot.data ?? []; // Extract the data from the snapshot

            return DataTable(
              columnSpacing: 40,
              border: TableBorder.all(color: Colors.greenAccent),
              dataRowMinHeight: 45,
              headingRowColor: MaterialStateProperty.resolveWith(
                  (states) => const Color(0xFF464E57)),
              headingTextStyle: TextStyle(color: Colors.white),
              sortColumnIndex: 0,
              columns: [
                DataColumn(
                  label: Text("Date"),
                  numeric: false,
                  tooltip: "Date",
                ),
                DataColumn(
                  label: Text("Time"),
                  numeric: false,
                  tooltip: "Time",
                ),
                DataColumn(
                  label: Text("Course"),
                  numeric: false,
                  tooltip: "Course",
                ),
                DataColumn(
                  label: Text("Status"),
                  numeric: false,
                  tooltip: "Status",
                ),
              ],
              rows: attendanceData.map((attendance) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(getDate(attendance.createdAt ??
                          '')), // Assuming 'date' is a property in your AttendanceModel
                    ),
                    DataCell(
                      Text(getTime(attendance.createdAt ??
                          '')), // Assuming 'date' is a property in your AttendanceModel
                    ),
                    DataCell(
                      Text(attendance.course?.title ??
                          ' '), // Assuming 'status' is a property in your AttendanceModel
                    ),
                    DataCell(
                      Text(attendance.status ??
                          ''), // Assuming 'course' is a property in your AttendanceModel
                    ),
                  ],
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.title), style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  const Color(0xFF00CCFF),
                  const Color(0xFF3366FF),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Expanded(
            child: dataBody(),
          ),
        ],
      ),
    );
  }
}
