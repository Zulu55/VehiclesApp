class Procedure {
  int id = 0;
  String description = '';
  double price = 0;

  Procedure({required this.id, required this.description, required this.price});

  Procedure.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['price'] = this.price;
    return data;
  }
}