import 'package:equatable/equatable.dart';

class Offer extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? imagePath;

  const Offer({
    required this.id,
    required this.name,
    this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.imagePath,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discountPercentage': discountPercentage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'imagePath': imagePath,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        discountPercentage,
        startDate,
        endDate,
        isActive,
        imagePath,
      ];
}
