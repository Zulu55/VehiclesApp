import 'detail.dart';

class History {
  int id = 0;
  String date = '';
  String dateLocal = '';
  int mileage = 0;
  String? remarks = '';
  List<Detail> details = [];
  int detailsCount = 0;
  int totalLabor = 0;
  int totalSpareParts = 0;
  int total = 0;

  History({
    required this.id,
    required this.date,
    required this.dateLocal,
    required this.mileage,
    required this.remarks,
    required this.details,
    required this.detailsCount,
    required this.totalLabor,
    required this.totalSpareParts,
    required this.total
  });

  History.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    dateLocal = json['dateLocal'];
    mileage = json['mileage'];
    remarks = json['remarks'];
    if (json['details'] != null) {
      details = [];
      json['details'].forEach((v) {
        details.add(new Detail.fromJson(v));
      });
    }
    detailsCount = json['detailsCount'];
    totalLabor = json['totalLabor'];
    totalSpareParts = json['totalSpareParts'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['dateLocal'] = this.dateLocal;
    data['mileage'] = this.mileage;
    data['remarks'] = this.remarks;
      data['details'] = this.details.map((v) => v.toJson()).toList();
    data['detailsCount'] = this.detailsCount;
    data['totalLabor'] = this.totalLabor;
    data['totalSpareParts'] = this.totalSpareParts;
    data['total'] = this.total;
    return data;
  }
}
