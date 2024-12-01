import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicament.dart';

class StorageService {
  static const String _key = 'medicaments';
  final SharedPreferences _prefs;

  StorageService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<List<Medicament>> getMedicaments() async {
    if (!_prefs.containsKey(_key)) {
      return [];
    }

    final String? medicamentsJson = _prefs.getString(_key);
    if (medicamentsJson == null || medicamentsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(medicamentsJson);
      return jsonList.map((json) => Medicament.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors de la lecture des médicaments: $e');
      return [];
    }
  }

  Future<void> saveMedicament(Medicament medicament) async {
    try {
      final List<Medicament> medicaments = await getMedicaments();
      medicaments.add(medicament);
      
      final String jsonString = json.encode(
        medicaments.map((m) => m.toJson()).toList(),
      );
      
      await _prefs.setString(_key, jsonString);
    } catch (e) {
      print('Erreur lors de la sauvegarde du médicament: $e');
    }
  }

  Future<void> updateMedicament(Medicament updatedMedicament) async {
    try {
      final List<Medicament> medicaments = await getMedicaments();
      
      final index = medicaments.indexWhere((m) => m.id == updatedMedicament.id);
      if (index != -1) {
        medicaments[index] = updatedMedicament;
        
        final String jsonString = json.encode(
          medicaments.map((m) => m.toJson()).toList(),
        );
        
        await _prefs.setString(_key, jsonString);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du médicament: $e');
    }
  }

  Future<void> deleteMedicament(String id) async {
    try {
      final List<Medicament> medicaments = await getMedicaments();
      medicaments.removeWhere((m) => m.id == id);
      
      final String jsonString = json.encode(
        medicaments.map((m) => m.toJson()).toList(),
      );
      
      await _prefs.setString(_key, jsonString);
    } catch (e) {
      print('Erreur lors de la suppression du médicament: $e');
    }
  }
}
