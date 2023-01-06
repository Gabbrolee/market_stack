import 'package:json_annotation/json_annotation.dart';

// Create a model class to represent a company
class Company {
  final String name;
  final String symbol;

  Company({this.name = 'name1', this.symbol = 'symbol1'});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      symbol: json['symbol'],
    );
  }
}

