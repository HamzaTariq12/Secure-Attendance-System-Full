// ignore_for_file: unnecessary_this, unnecessary_new

import 'package:flutter/src/material/data_table.dart';

class AttendanceModel {
  int? id;
  String? moduleType;
  Student? student;
  String? status;
  Course? course;
  bool? enrollmentStatus;
  String? createdAt;

  AttendanceModel(
      {this.id,
      this.moduleType,
      this.student,
      this.status,
      this.course,
      this.enrollmentStatus,
      this.createdAt});

  AttendanceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleType = json['module_type'];
    student =
        json['student'] != null ? new Student.fromJson(json['student']) : null;
    status = json['status'];
    course =
        json['course'] != null ? new Course.fromJson(json['course']) : null;
    enrollmentStatus = json['enrollment_status'];
    createdAt = json['created_at'];
  }

  get data => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['module_type'] = this.moduleType;
    if (this.student != null) {
      data['student'] = this.student!.toJson();
    }
    data['status'] = this.status;
    if (this.course != null) {
      data['course'] = this.course!.toJson();
    }
    data['enrollment_status'] = this.enrollmentStatus;
    data['created_at'] = this.createdAt;
    return data;
  }

  static map(DataRow Function(dynamic user) param0) {}
}

class Student {
  int? id;
  String? fullName;
  String? rollNo;

  Student({this.id, this.fullName, this.rollNo});

  Student.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    rollNo = json['roll_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['full_name'] = this.fullName;
    data['roll_no'] = this.rollNo;
    return data;
  }
}

class Course {
  int? id;
  String? title;

  Course({this.id, this.title});

  Course.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  get name => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}
