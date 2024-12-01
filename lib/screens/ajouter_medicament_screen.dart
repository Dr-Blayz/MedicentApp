import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../models/medicament.dart';
import '../main.dart';
import '../services/notification_service.dart';

class AjouterMedicamentScreen extends StatefulWidget {
  const AjouterMedicamentScreen({super.key});

  @override
  State<AjouterMedicamentScreen> createState() => _AjouterMedicamentScreenState();
}

class _AjouterMedicamentScreenState extends State<AjouterMedicamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _doseController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _notificationService = NotificationService();
  
  bool _rappelActive = false;
  String? _typeSelectionne;
  DateTime _dateSelectionnee = DateTime.now();
  TimeOfDay _heureSelectionnee = TimeOfDay.now();

  final List<String> _typesMedicaments = [
    'Gélule',
    'Goutte',
    'Comprimé',
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _heureSelectionnee,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _heureSelectionnee = time;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Future<void> _sauvegarderMedicament() async {
    if (_formKey.currentState!.validate()) {
      final medicament = Medicament(
        id: const Uuid().v4(),
        nom: _nomController.text,
        type: _typeSelectionne ?? 'Comprimé',
        dose: _doseController.text,
        quantite: int.parse(_quantiteController.text),
        rappel: DateTime(
          _dateSelectionnee.year,
          _dateSelectionnee.month,
          _dateSelectionnee.day,
          _heureSelectionnee.hour,
          _heureSelectionnee.minute,
        ),
        rappelActive: _rappelActive,
        pris: false,
      );

      await storageService.saveMedicament(medicament);

      if (_rappelActive) {
        await _notificationService.scheduleNotification(medicament);
      }

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _doseController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Médicament'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Remplissez les champs et appuyez sur le bouton Enregistrer !',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom*',
                  hintText: 'Nom (ex: Vitamine D)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _typeSelectionne,
                decoration: const InputDecoration(
                  labelText: 'Type*',
                  border: OutlineInputBorder(),
                ),
                items: _typesMedicaments.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _typeSelectionne = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'Dose*',
                  hintText: 'Dose (ex: 1000mg)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une dose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantiteController,
                decoration: const InputDecoration(
                  labelText: 'Quantité*',
                  hintText: 'Quantité (ex: 1)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Rappels',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatTime(_heureSelectionnee)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Éditer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activer les rappels'),
                value: _rappelActive,
                onChanged: (bool value) {
                  setState(() {
                    _rappelActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _sauvegarderMedicament,
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
