import 'dart:convert';

class ProductModel {
  //inisialisasi var data
  final String name;
  final String description;
  final int price;

  //constructor untuk mengisi data
  ProductModel({
    required this.name,
    required this.description,
    required this.price,
  });

  //object -> Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
    };
  }

  //map -> object
  factory ProductModel.fromMap(
    Map<String, dynamic> map,
    ) {
    return ProductModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
    );
  }

  //object -> json
  String toJson() => jsonEncode(toMap());

  //json -> object
  factory ProductModel.frpmJson(String source){
    return ProductModel.fromMap(
      jsonDecode(source)
    );
  }
}
