/// Knowledge Provider
///
/// Riverpod provider for knowledge database access.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/knowledge_database.dart';
import '../models/thirukkural.dart';
import '../models/scheme.dart';
import '../models/emergency_contact.dart';
import '../models/hospital.dart';

/// Database ready state provider
final knowledgeDatabaseReadyProvider = FutureProvider<bool>((ref) async {
  return KnowledgeDatabase.isReady();
});

/// Database stats provider
final knowledgeStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  return KnowledgeDatabase.getStats();
});

/// Thirukkural by number provider
final thirukkuralProvider = FutureProvider.family<Thirukkural?, int>((ref, number) async {
  final map = await KnowledgeDatabase.getKuralByNumber(number);
  if (map == null) return null;
  return Thirukkural.fromMap(map);
});

/// Thirukkural search provider
final thirukkuralSearchProvider = FutureProvider.family<List<Thirukkural>, String>((ref, query) async {
  final results = await KnowledgeDatabase.searchKurals(query);
  return results.map((m) => Thirukkural.fromMap(m)).toList();
});

/// All Athikarams provider
final athikaramsProvider = FutureProvider<List<Athikaram>>((ref) async {
  final results = await KnowledgeDatabase.getAllAthikarams();
  return results.map((m) => Athikaram.fromMap(m)).toList();
});

/// Kurals by Athikaram provider
final kuralsByAthikaramProvider = FutureProvider.family<List<Thirukkural>, int>((ref, athikaramNumber) async {
  final results = await KnowledgeDatabase.getKuralsByAthikaram(athikaramNumber);
  return results.map((m) => Thirukkural.fromMap(m)).toList();
});

/// All schemes provider
final schemesProvider = FutureProvider<List<Scheme>>((ref) async {
  final results = await KnowledgeDatabase.getAllSchemes();
  return results.map((m) => Scheme.fromMap(m)).toList();
});

/// Schemes by level provider
final schemesByLevelProvider = FutureProvider.family<List<Scheme>, String>((ref, level) async {
  final results = await KnowledgeDatabase.getAllSchemes(level: level);
  return results.map((m) => Scheme.fromMap(m)).toList();
});

/// Scheme by ID provider
final schemeByIdProvider = FutureProvider.family<Scheme?, String>((ref, id) async {
  final map = await KnowledgeDatabase.getSchemeById(id);
  if (map == null) return null;

  final scheme = Scheme.fromMap(map);

  // Load eligibility and documents
  final eligibility = await KnowledgeDatabase.getSchemeEligibility(id);
  scheme.eligibility = eligibility.map((m) => SchemeEligibility.fromMap(m)).toList();

  final documents = await KnowledgeDatabase.getSchemeDocuments(id);
  scheme.documents = documents.map((m) => SchemeDocument.fromMap(m)).toList();

  return scheme;
});

/// National emergency contacts provider
final nationalEmergencyContactsProvider = FutureProvider<List<EmergencyContact>>((ref) async {
  final results = await KnowledgeDatabase.getNationalEmergencyNumbers();
  return results.map((m) => EmergencyContact.fromMap(m)).toList();
});

/// Emergency contacts by type provider
final emergencyContactsByTypeProvider = FutureProvider.family<List<EmergencyContact>, String>((ref, type) async {
  final results = await KnowledgeDatabase.getEmergencyContacts(type: type);
  return results.map((m) => EmergencyContact.fromMap(m)).toList();
});

/// Hospitals by district provider
final hospitalsByDistrictProvider = FutureProvider.family<List<Hospital>, String>((ref, district) async {
  final results = await KnowledgeDatabase.getHospitalsByDistrict(district);
  return results.map((m) => Hospital.fromMap(m)).toList();
});

/// Hospital search provider
final hospitalSearchProvider = FutureProvider.family<List<Hospital>, String>((ref, query) async {
  final results = await KnowledgeDatabase.searchHospitals(query);
  return results.map((m) => Hospital.fromMap(m)).toList();
});

/// Full-text search provider
final knowledgeSearchProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  return KnowledgeDatabase.fullTextSearch(query);
});

/// Categories provider
final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return KnowledgeDatabase.getCategories();
});
