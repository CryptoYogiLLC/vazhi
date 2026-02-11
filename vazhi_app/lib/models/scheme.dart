/// Scheme Model
///
/// Represents a government welfare scheme with eligibility and documents.
library;

class Scheme {
  final String id;
  final String nameTamil;
  final String nameEnglish;
  final String level; // central, state, district
  final String? department;
  final String descriptionTamil;
  final String descriptionEnglish;
  final String? benefitType;
  final String? benefitAmount;
  final String? howToApplyTamil;
  final String? howToApplyEnglish;
  final String? applicationUrl;
  final bool isActive;
  final String? lastUpdated;

  // Related data (loaded separately)
  List<SchemeEligibility>? eligibility;
  List<SchemeDocument>? documents;

  Scheme({
    required this.id,
    required this.nameTamil,
    required this.nameEnglish,
    required this.level,
    this.department,
    required this.descriptionTamil,
    required this.descriptionEnglish,
    this.benefitType,
    this.benefitAmount,
    this.howToApplyTamil,
    this.howToApplyEnglish,
    this.applicationUrl,
    this.isActive = true,
    this.lastUpdated,
    this.eligibility,
    this.documents,
  });

  factory Scheme.fromMap(Map<String, dynamic> map) {
    return Scheme(
      id: map['id'] as String,
      nameTamil: map['name_tamil'] as String,
      nameEnglish: map['name_english'] as String,
      level: map['level'] as String,
      department: map['department'] as String?,
      descriptionTamil: map['description_tamil'] as String,
      descriptionEnglish: map['description_english'] as String,
      benefitType: map['benefit_type'] as String?,
      benefitAmount: map['benefit_amount'] as String?,
      howToApplyTamil: map['how_to_apply_tamil'] as String?,
      howToApplyEnglish: map['how_to_apply_english'] as String?,
      applicationUrl: map['application_url'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      lastUpdated: map['last_updated'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_tamil': nameTamil,
      'name_english': nameEnglish,
      'level': level,
      'department': department,
      'description_tamil': descriptionTamil,
      'description_english': descriptionEnglish,
      'benefit_type': benefitType,
      'benefit_amount': benefitAmount,
      'how_to_apply_tamil': howToApplyTamil,
      'how_to_apply_english': howToApplyEnglish,
      'application_url': applicationUrl,
      'is_active': isActive ? 1 : 0,
      'last_updated': lastUpdated,
    };
  }

  /// Get level display text
  String get levelDisplay {
    switch (level) {
      case 'central':
        return 'மத்திய அரசு';
      case 'state':
        return 'மாநில அரசு';
      case 'district':
        return 'மாவட்ட அரசு';
      default:
        return level;
    }
  }

  /// Check if has online application
  bool get hasOnlineApplication =>
      applicationUrl != null && applicationUrl!.isNotEmpty;
}

/// Eligibility criteria for a scheme
class SchemeEligibility {
  final int id;
  final String schemeId;
  final String criteriaType;
  final String criteriaTamil;
  final String criteriaEnglish;
  final String? minValue;
  final String? maxValue;
  final String? allowedValues;

  const SchemeEligibility({
    required this.id,
    required this.schemeId,
    required this.criteriaType,
    required this.criteriaTamil,
    required this.criteriaEnglish,
    this.minValue,
    this.maxValue,
    this.allowedValues,
  });

  factory SchemeEligibility.fromMap(Map<String, dynamic> map) {
    return SchemeEligibility(
      id: map['id'] as int,
      schemeId: map['scheme_id'] as String,
      criteriaType: map['criteria_type'] as String,
      criteriaTamil: map['criteria_tamil'] as String,
      criteriaEnglish: map['criteria_english'] as String,
      minValue: map['min_value'] as String?,
      maxValue: map['max_value'] as String?,
      allowedValues: map['allowed_values'] as String?,
    );
  }
}

/// Required document for a scheme
class SchemeDocument {
  final int id;
  final String schemeId;
  final String documentTamil;
  final String documentEnglish;
  final bool isMandatory;
  final String? notes;

  const SchemeDocument({
    required this.id,
    required this.schemeId,
    required this.documentTamil,
    required this.documentEnglish,
    this.isMandatory = true,
    this.notes,
  });

  factory SchemeDocument.fromMap(Map<String, dynamic> map) {
    return SchemeDocument(
      id: map['id'] as int,
      schemeId: map['scheme_id'] as String,
      documentTamil: map['document_tamil'] as String,
      documentEnglish: map['document_english'] as String,
      isMandatory: (map['is_mandatory'] as int?) == 1,
      notes: map['notes'] as String?,
    );
  }
}
