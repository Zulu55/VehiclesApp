class VehicleType {
  int id = 0;
  String description = '';

  VehicleType({required this.id, required this.description});

  VehicleType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    return data;
  }
}