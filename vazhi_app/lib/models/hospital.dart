/// Hospital Model
///
/// Represents a hospital or health facility.
library;

class Hospital {
  final int id;
  final String? nameTamil;
  final String nameEnglish;
  final String type;
  final String? specialty;
  final String district;
  final String? city;
  final String? address;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? emergencyPhone;
  final String? email;
  final int? beds;
  final bool hasEmergency;
  final bool hasAmbulance;
  final bool acceptsCmchis;
  final bool acceptsAyushman;

  const Hospital({
    required this.id,
    this.nameTamil,
    required this.nameEnglish,
    required this.type,
    this.specialty,
    required this.district,
    this.city,
    this.address,
    this.pincode,
    this.latitude,
    this.longitude,
    this.phone,
    this.emergencyPhone,
    this.email,
    this.beds,
    this.hasEmergency = false,
    this.hasAmbulance = false,
    this.acceptsCmchis = false,
    this.acceptsAyushman = false,
  });

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      id: map['id'] as int,
      nameTamil: map['name_tamil'] as String?,
      nameEnglish: map['name_english'] as String,
      type: map['type'] as String,
      specialty: map['specialty'] as String?,
      district: map['district'] as String,
      city: map['city'] as String?,
      address: map['address'] as String?,
      pincode: map['pincode'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      phone: map['phone'] as String?,
      emergencyPhone: map['emergency_phone'] as String?,
      email: map['email'] as String?,
      beds: map['beds'] as int?,
      hasEmergency: (map['has_emergency'] as int?) == 1,
      hasAmbulance: (map['has_ambulance'] as int?) == 1,
      acceptsCmchis: (map['accepts_cmchis'] as int?) == 1,
      acceptsAyushman: (map['accepts_ayushman'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_tamil': nameTamil,
      'name_english': nameEnglish,
      'type': type,
      'specialty': specialty,
      'district': district,
      'city': city,
      'address': address,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'emergency_phone': emergencyPhone,
      'email': email,
      'beds': beds,
      'has_emergency': hasEmergency ? 1 : 0,
      'has_ambulance': hasAmbulance ? 1 : 0,
      'accepts_cmchis': acceptsCmchis ? 1 : 0,
      'accepts_ayushman': acceptsAyushman ? 1 : 0,
    };
  }

  /// Get display name (prefer Tamil if available)
  String get displayName => nameTamil ?? nameEnglish;

  /// Get type display text
  String get typeDisplay {
    switch (type) {
      case 'govt':
        return '🏥 அரசு மருத்துவமனை';
      case 'private':
        return '🏨 தனியார் மருத்துவமனை';
      case 'phc':
        return '🏠 ஆரம்ப சுகாதார நிலையம்';
      case 'ghq':
        return '🏢 அரசு தலைமை மருத்துவமனை';
      default:
        return type;
    }
  }

  /// Get insurance badges
  List<String> get insuranceBadges {
    final badges = <String>[];
    if (acceptsCmchis) badges.add('CMCHIS');
    if (acceptsAyushman) badges.add('Ayushman');
    return badges;
  }

  /// Get facility badges
  List<String> get facilityBadges {
    final badges = <String>[];
    if (hasEmergency) badges.add('24/7 Emergency');
    if (hasAmbulance) badges.add('Ambulance');
    return badges;
  }

  /// Check if has location coordinates
  bool get hasLocation => latitude != null && longitude != null;

  /// Get full address
  String get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    parts.add(district);
    if (pincode != null) parts.add(pincode!);
    return parts.join(', ');
  }
}

/// Hospital type enum
enum HospitalType { govt, private, phc, ghq }

extension HospitalTypeExtension on HospitalType {
  String get value {
    switch (this) {
      case HospitalType.govt:
        return 'govt';
      case HospitalType.private:
        return 'private';
      case HospitalType.phc:
        return 'phc';
      case HospitalType.ghq:
        return 'ghq';
    }
  }
}
