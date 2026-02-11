/// Healthcare Service
///
/// Handles deterministic retrieval of hospitals and health facilities.

import '../../database/knowledge_database.dart';
import '../../models/hospital.dart';
import '../../models/query_result.dart';
import 'retrieval_service.dart';

class HealthcareService extends RetrievalService {
  @override
  KnowledgeCategory get category => KnowledgeCategory.health;

  /// Get hospitals by district
  Future<RetrievalResult<Hospital>> getByDistrict(
    String district, {
    String? type,
    bool cmchisOnly = false,
  }) async {
    try {
      final results = await KnowledgeDatabase.getHospitalsByDistrict(
        district,
        type: type,
        cmchisOnly: cmchisOnly,
      );

      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: '$district மாவட்டத்தில் மருத்துவமனைகள் கிடைக்கவில்லை',
        );
      }

      final hospitals = results.map((m) => Hospital.fromMap(m)).toList();
      return RetrievalResult.list(
        hospitals,
        category: category,
        displayTitle: '$district மருத்துவமனைகள்',
        formattedResponse: _formatHospitalListResponse(hospitals, district),
        totalCount: hospitals.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Get government hospitals
  Future<RetrievalResult<Hospital>> getGovernmentHospitals(
    String? district,
  ) async {
    if (district == null) {
      return RetrievalResult.notFound(
        category: category,
        message: 'மாவட்டம் குறிப்பிடவும்',
      );
    }

    return getByDistrict(district, type: 'govt');
  }

  /// Get hospitals that accept CMCHIS
  Future<RetrievalResult<Hospital>> getCmchisHospitals(String district) async {
    return getByDistrict(district, cmchisOnly: true);
  }

  /// Search hospitals
  @override
  Future<RetrievalResult<Hospital>> search(
    String query, {
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) {
      return RetrievalResult.notFound(
        category: category,
        message: 'தேடல் சொல்லை உள்ளிடவும்',
      );
    }

    try {
      final results = await KnowledgeDatabase.searchHospitals(query);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: '"$query" க்கான மருத்துவமனைகள் கிடைக்கவில்லை',
        );
      }

      final hospitals = results.map((m) => Hospital.fromMap(m)).toList();
      return RetrievalResult.list(
        hospitals,
        category: category,
        displayTitle: '"$query" மருத்துவமனைகள்',
        formattedResponse: _formatSearchResponse(hospitals, query),
        totalCount: hospitals.length,
        hasMore: hospitals.length >= limit,
      );
    } catch (e) {
      return RetrievalResult.error('தேடல் பிழை: $e', category: category);
    }
  }

  /// Get emergency hospitals (with 24/7 emergency)
  Future<RetrievalResult<Hospital>> getEmergencyHospitals(
    String district,
  ) async {
    try {
      final results = await KnowledgeDatabase.getHospitalsByDistrict(district);

      // Filter for hospitals with emergency service
      final filtered = results
          .where((m) => (m['has_emergency'] as int?) == 1)
          .toList();

      if (filtered.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message:
              '$district மாவட்டத்தில் அவசர சிகிச்சை மருத்துவமனைகள் கிடைக்கவில்லை',
        );
      }

      final hospitals = filtered.map((m) => Hospital.fromMap(m)).toList();
      return RetrievalResult.list(
        hospitals,
        category: category,
        displayTitle: '$district - 24/7 அவசர மருத்துவமனைகள்',
        formattedResponse: _formatEmergencyHospitals(hospitals),
        totalCount: hospitals.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  @override
  String formatForDisplay(dynamic item) {
    if (item is! Hospital) return item.toString();
    return _formatHospitalResponse(item);
  }

  /// Format a single hospital
  String _formatHospitalResponse(Hospital hospital) {
    final buffer = StringBuffer();

    buffer.writeln('🏥 **${hospital.displayName}**');
    buffer.writeln('${hospital.nameEnglish}');
    buffer.writeln();
    buffer.writeln('${hospital.typeDisplay}');
    buffer.writeln();

    // Contact info
    if (hospital.phone != null) {
      buffer.writeln('📞 ${hospital.phone}');
    }
    if (hospital.emergencyPhone != null) {
      buffer.writeln('🚨 ${hospital.emergencyPhone} (அவசரம்)');
    }
    buffer.writeln();

    // Address
    buffer.writeln('📍 ${hospital.fullAddress}');
    buffer.writeln();

    // Facilities
    final facilities = hospital.facilityBadges;
    if (facilities.isNotEmpty) {
      buffer.writeln('✅ ${facilities.join(' | ')}');
    }

    // Insurance
    final insurance = hospital.insuranceBadges;
    if (insurance.isNotEmpty) {
      buffer.writeln('💳 ${insurance.join(' | ')}');
    }

    return buffer.toString();
  }

  /// Format list of hospitals
  String _formatHospitalListResponse(
    List<Hospital> hospitals,
    String district,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('🏥 **$district மருத்துவமனைகள்** (${hospitals.length})');
    buffer.writeln();

    // Group by type
    final govt = hospitals
        .where((h) => h.type == 'govt' || h.type == 'ghq')
        .toList();
    final private = hospitals.where((h) => h.type == 'private').toList();

    if (govt.isNotEmpty) {
      buffer.writeln('### 🏛️ அரசு மருத்துவமனைகள்');
      buffer.writeln();
      for (final h in govt) {
        buffer.writeln('• **${h.displayName}**');
        if (h.phone != null) {
          buffer.writeln('  📞 ${h.phone}');
        }
        final badges = <String>[];
        if (h.hasEmergency) badges.add('24/7');
        if (h.acceptsCmchis) badges.add('CMCHIS');
        if (badges.isNotEmpty) {
          buffer.writeln('  ${badges.join(' | ')}');
        }
        buffer.writeln();
      }
    }

    if (private.isNotEmpty) {
      buffer.writeln('### 🏨 தனியார் மருத்துவமனைகள்');
      buffer.writeln();
      for (final h in private) {
        buffer.writeln('• **${h.displayName}**');
        if (h.specialty != null) {
          buffer.writeln('  ${h.specialty}');
        }
        if (h.phone != null) {
          buffer.writeln('  📞 ${h.phone}');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Format search results
  String _formatSearchResponse(List<Hospital> hospitals, String query) {
    final buffer = StringBuffer();

    buffer.writeln('🔍 **"$query" - ${hospitals.length} மருத்துவமனைகள்**');
    buffer.writeln();

    for (final h in hospitals.take(10)) {
      buffer.writeln('• **${h.displayName}** (${h.district})');
      buffer.writeln('  ${h.typeDisplay}');
      if (h.phone != null) {
        buffer.writeln('  📞 ${h.phone}');
      }
      buffer.writeln();
    }

    if (hospitals.length > 10) {
      buffer.writeln('_...மேலும் ${hospitals.length - 10} மருத்துவமனைகள்_');
    }

    return buffer.toString();
  }

  /// Format emergency hospitals
  String _formatEmergencyHospitals(List<Hospital> hospitals) {
    final buffer = StringBuffer();

    buffer.writeln('🚨 **24/7 அவசர மருத்துவமனைகள்**');
    buffer.writeln();

    for (final h in hospitals) {
      buffer.writeln('### ${h.displayName}');
      buffer.writeln();
      if (h.emergencyPhone != null) {
        buffer.writeln('🚨 **அவசர எண்:** ${h.emergencyPhone}');
      } else if (h.phone != null) {
        buffer.writeln('📞 ${h.phone}');
      }
      if (h.hasAmbulance) {
        buffer.writeln('🚑 ஆம்புலன்ஸ் உள்ளது');
      }
      buffer.writeln('📍 ${h.fullAddress}');
      buffer.writeln();
    }

    return buffer.toString();
  }
}
