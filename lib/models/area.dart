class Area {
  final int id;
  final String nameAr;
  final String type; // compound | city_district
  final String city;
  final String rolloutStatus; // active | coming_soon

  Area({
    required this.id,
    required this.nameAr,
    required this.type,
    required this.city,
    required this.rolloutStatus,
  });

  bool get isActive => rolloutStatus == 'active';

  factory Area.fromJson(Map<String, dynamic> json) => Area(
        id: json['id'],
        nameAr: json['name_ar'],
        type: json['type'],
        city: json['city'],
        rolloutStatus: json['rollout_status'],
      );
}
