/// Emergency Service
///
/// Handles deterministic retrieval of emergency contacts and helplines.

import '../../database/knowledge_database.dart';
import '../../models/emergency_contact.dart';
import '../../models/query_result.dart';
import 'retrieval_service.dart';

class EmergencyService extends RetrievalService {
  @override
  KnowledgeCategory get category => KnowledgeCategory.emergency;

  /// Get all emergency contacts
  Future<RetrievalResult<EmergencyContact>> getAllContacts() async {
    try {
      final results = await KnowledgeDatabase.getEmergencyContacts();
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: 'அவசர தொடர்புகள் கிடைக்கவில்லை',
        );
      }

      final contacts = results.map((m) => EmergencyContact.fromMap(m)).toList();
      return RetrievalResult.list(
        contacts,
        category: category,
        displayTitle: 'அவசர தொடர்பு எண்கள்',
        formattedResponse: _formatContactListResponse(contacts),
        totalCount: contacts.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Get national emergency numbers
  Future<RetrievalResult<EmergencyContact>> getNationalNumbers() async {
    try {
      final results = await KnowledgeDatabase.getNationalEmergencyNumbers();
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: 'தேசிய அவசர எண்கள் கிடைக்கவில்லை',
        );
      }

      final contacts = results.map((m) => EmergencyContact.fromMap(m)).toList();
      return RetrievalResult.list(
        contacts,
        category: category,
        displayTitle: 'தேசிய அவசர எண்கள்',
        formattedResponse: _formatContactListResponse(
          contacts,
          showNationalBadge: true,
        ),
        totalCount: contacts.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Get contacts by type (police, fire, medical, etc.)
  Future<RetrievalResult<EmergencyContact>> getByType(String type) async {
    try {
      final results = await KnowledgeDatabase.getEmergencyContacts(type: type);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: '$type தொடர்புகள் கிடைக்கவில்லை',
        );
      }

      final contacts = results.map((m) => EmergencyContact.fromMap(m)).toList();
      final typeLabel = _getTypeLabel(type);

      return RetrievalResult.list(
        contacts,
        category: category,
        displayTitle: '$typeLabel எண்கள்',
        formattedResponse: _formatContactListResponse(contacts),
        totalCount: contacts.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Get contacts by district
  Future<RetrievalResult<EmergencyContact>> getByDistrict(
    String district,
  ) async {
    try {
      final results = await KnowledgeDatabase.getEmergencyContacts(
        district: district,
      );
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: '$district மாவட்ட தொடர்புகள் கிடைக்கவில்லை',
        );
      }

      final contacts = results.map((m) => EmergencyContact.fromMap(m)).toList();
      return RetrievalResult.list(
        contacts,
        category: category,
        displayTitle: '$district அவசர எண்கள்',
        formattedResponse: _formatContactListResponse(contacts),
        totalCount: contacts.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Search emergency contacts
  @override
  Future<RetrievalResult<EmergencyContact>> search(
    String query, {
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) {
      return getAllContacts();
    }

    try {
      // Get all contacts and filter locally
      final results = await KnowledgeDatabase.getEmergencyContacts();
      final queryLower = query.toLowerCase();

      final filtered = results.where((m) {
        final nameTamil = (m['name_tamil'] as String?)?.toLowerCase() ?? '';
        final nameEnglish = (m['name_english'] as String?)?.toLowerCase() ?? '';
        final phone = (m['phone'] as String?)?.toLowerCase() ?? '';
        final type = (m['type'] as String?)?.toLowerCase() ?? '';

        return nameTamil.contains(queryLower) ||
            nameEnglish.contains(queryLower) ||
            phone.contains(queryLower) ||
            type.contains(queryLower);
      }).toList();

      if (filtered.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: '"$query" க்கான தொடர்புகள் கிடைக்கவில்லை',
        );
      }

      final contacts = filtered
          .map((m) => EmergencyContact.fromMap(m))
          .toList();
      return RetrievalResult.list(
        contacts,
        category: category,
        displayTitle: '"$query" தொடர்புகள்',
        formattedResponse: _formatContactListResponse(contacts),
        totalCount: contacts.length,
      );
    } catch (e) {
      return RetrievalResult.error('தேடல் பிழை: $e', category: category);
    }
  }

  /// Get quick emergency response (most important numbers)
  Future<RetrievalResult<EmergencyContact>> getQuickEmergency() async {
    try {
      final results = await KnowledgeDatabase.getEmergencyContacts();

      // Filter for most critical numbers
      final criticalTypes = ['police', 'fire', 'medical'];
      final filtered = results.where((m) {
        final type = m['type'] as String?;
        final isNational = (m['is_national'] as int?) == 1;
        return criticalTypes.contains(type) && isNational;
      }).toList();

      if (filtered.isEmpty) {
        return getAllContacts();
      }

      final contacts = filtered
          .map((m) => EmergencyContact.fromMap(m))
          .toList();
      return RetrievalResult.list(
        contacts,
        category: category,
        displayTitle: '🚨 அவசர எண்கள்',
        formattedResponse: _formatQuickEmergencyResponse(contacts),
        totalCount: contacts.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  @override
  String formatForDisplay(dynamic item) {
    if (item is! EmergencyContact) return item.toString();
    return _formatSingleContact(item);
  }

  /// Get type label in Tamil
  String _getTypeLabel(String type) {
    switch (type) {
      case 'police':
        return '👮 காவல்துறை';
      case 'fire':
        return '🚒 தீயணைப்பு';
      case 'medical':
        return '🏥 மருத்துவம்';
      case 'women':
        return '👩 பெண்கள் உதவி';
      case 'child':
        return '👶 குழந்தைகள் உதவி';
      case 'disaster':
        return '🌊 பேரிடர் மேலாண்மை';
      default:
        return type;
    }
  }

  /// Format a single contact
  String _formatSingleContact(EmergencyContact contact) {
    final buffer = StringBuffer();

    final icon = _getTypeIcon(contact.type);
    buffer.writeln('$icon **${contact.nameTamil}**');
    buffer.writeln('${contact.nameEnglish}');
    buffer.writeln();
    buffer.writeln('📞 **${contact.phone}**');
    if (contact.alternatePhone != null) {
      buffer.writeln('📞 ${contact.alternatePhone} (மாற்று)');
    }

    return buffer.toString();
  }

  /// Format list of contacts
  String _formatContactListResponse(
    List<EmergencyContact> contacts, {
    bool showNationalBadge = false,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('🚨 **அவசர தொடர்பு எண்கள்**');
    buffer.writeln();

    // Group by type
    final byType = <String, List<EmergencyContact>>{};
    for (final contact in contacts) {
      byType.putIfAbsent(contact.type, () => []).add(contact);
    }

    for (final entry in byType.entries) {
      final typeLabel = _getTypeLabel(entry.key);
      buffer.writeln('### $typeLabel');
      buffer.writeln();

      for (final contact in entry.value) {
        final badge = showNationalBadge && contact.isNational ? ' 🇮🇳' : '';
        buffer.writeln('• **${contact.nameTamil}**$badge: ${contact.phone}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Format quick emergency response
  String _formatQuickEmergencyResponse(List<EmergencyContact> contacts) {
    final buffer = StringBuffer();

    buffer.writeln('# 🚨 அவசர எண்கள்');
    buffer.writeln();

    for (final contact in contacts) {
      final icon = _getTypeIcon(contact.type);
      buffer.writeln('## $icon ${contact.phone}');
      buffer.writeln('${contact.nameTamil} | ${contact.nameEnglish}');
      buffer.writeln();
    }

    buffer.writeln('---');
    buffer.writeln('_இந்த எண்கள் 24/7 இலவசமாக கிடைக்கும்_');

    return buffer.toString();
  }

  /// Get icon for type
  String _getTypeIcon(String type) {
    switch (type) {
      case 'police':
        return '👮';
      case 'fire':
        return '🚒';
      case 'medical':
        return '🏥';
      case 'women':
        return '👩';
      case 'child':
        return '👶';
      case 'disaster':
        return '🌊';
      default:
        return '📞';
    }
  }
}
