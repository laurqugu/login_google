import 'package:flutter/material.dart';

class Record {
  int id = 0;
  String date = '';
  String email = '';
  int qualification = 0;
  String theBest = '';
  String theWorst = '';
  String remarks = '';

  Record(
    {
      required this.id,
      required this.email,
      required this.qualification,
      required this.theBest,
      required this.theWorst,
      required this.remarks
    }
  );

  Record.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    qualification = json['qualification'];
    theBest = json['theBest'];
    theWorst = json['theWorst'];
    remarks = json['remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['qualification'] = this.qualification;
    data['theBest'] = this.theBest;
    data['theWorst'] = this.theWorst;
    data['remarks'] = this.remarks;
    return data;
  }
}