class Country {
  final int id;
  final String iso;
  final String name;
  final String iso3;
  final String nicename;
  final int numcode;
  final int phonecode;

  Country({
    required this.id,
    required this.iso,
    required this.name,
    required this.iso3,
    required this.nicename,
    required this.numcode,
    required this.phonecode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: (json['id'] as num?)?.toInt() ?? 0,
      iso: json['iso']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      iso3: json['iso3']?.toString() ?? '',
      nicename: json['nicename']?.toString() ?? '',
      numcode: (json['numcode'] as num?)?.toInt() ?? 0,
      phonecode: (json['phonecode'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iso': iso,
      'name': name,
      'iso3': iso3,
      'nicename': nicename,
      'numcode': numcode,
      'phonecode': phonecode,
    };
  }
}

class CountryInfo {
  final int? id;
  final String? iso;
  final String? name;
  final int? phonecode;

  CountryInfo({
    this.id,
    this.iso,
    this.name,
    this.phonecode,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      id: (json['id'] as num?)?.toInt(),
      iso: json['iso']?.toString(),
      name: json['name']?.toString(),
      phonecode: (json['phonecode'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iso': iso,
      'name': name,
      'phonecode': phonecode,
    };
  }
}
