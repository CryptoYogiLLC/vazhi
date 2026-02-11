/// Emergency Contact Model
///
/// Represents an emergency service contact number.
library;

class EmergencyContact {
  final int id;
  final String nameTamil;
  final String nameEnglish;
  final String phone;
  final String? alternatePhone;
  final String type;
  final String? district;
  final bool isNational;

  const EmergencyContact({
    required this.id,
    required this.nameTamil,
    required this.nameEnglish,
    required this.phone,
    this.alternatePhone,
    required this.type,
    this.district,
    this.isNational = false,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as int,
      nameTamil: map['name_tamil'] as String,
      nameEnglish: map['name_english'] as String,
      phone: map['phone'] as String,
      alternatePhone: map['alternate_phone'] as String?,
      type: map['type'] as String,
      district: map['district'] as String?,
      isNational: (map['is_national'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_tamil': nameTamil,
      'name_english': nameEnglish,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'type': type,
      'district': district,
      'is_national': isNational ? 1 : 0,
    };
  }

  /// Get type display text
  String get typeDisplay {
    switch (type) {
      case 'police':
        return '👮 காவல்துறை';
      case 'fire':
        return '🚒 தீயணைப்பு';
      case 'medical':
        return '🏥 மருத்துவம்';
      case 'disaster':
        return '🆘 பேரிடர்';
      case 'women':
        return '👩 பெண்கள் உதவி';
      case 'child':
        return '👶 குழந்தைகள் உதவி';
      default:
        return type;
    }
  }

  /// Get formatted phone for display
  String get formattedPhone {
    // Format short codes nicely
    if (phone.length <= 4) return phone;
    return phone;
  }

  /// Check if this is a short code (like 100, 108)
  bool get isShortCode => phone.length <= 4;
}

/// Common emergency type enum
enum EmergencyType { police, fire, medical, disaster, women, child, other }

extension EmergencyTypeExtension on EmergencyType {
  String get value {
    switch (this) {
      case EmergencyType.police:
        return 'police';
      case EmergencyType.fire:
        return 'fire';
      case EmergencyType.medical:
        return 'medical';
      case EmergencyType.disaster:
        return 'disaster';
      case EmergencyType.women:
        return 'women';
      case EmergencyType.child:
        return 'child';
      case EmergencyType.other:
        return 'other';
    }
  }
}
