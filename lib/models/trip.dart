class Trip {
  final int id;
  final String status; // requested|searching|accepted|in_progress|completed|cancelled
  final String category;
  final double? distanceKm;
  final double? estimatedFare;
  final double? finalFare;
  final bool isOutOfZone;

  Trip({
    required this.id,
    required this.status,
    required this.category,
    this.distanceKm,
    this.estimatedFare,
    this.finalFare,
    required this.isOutOfZone,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'],
        status: json['status'],
        category: json['category'],
        distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null,
        estimatedFare: json['estimated_fare'] != null ? double.tryParse(json['estimated_fare'].toString()) : null,
        finalFare: json['final_fare'] != null ? double.tryParse(json['final_fare'].toString()) : null,
        isOutOfZone: json['is_out_of_zone'] == true || json['is_out_of_zone'] == 1,
      );
}
