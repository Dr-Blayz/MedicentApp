import 'package:flutter/material.dart';
import '../models/medicament.dart';
import '../main.dart';

class ModifierMedicamentScreen extends StatefulWidget {
  final Medicament medicament;

  const ModifierMedicamentScreen({
    super.key,
    required this.medicament,
  });

  @override
  State<ModifierMedicamentScreen> createState() =>
      _ModifierMedicamentScreenState();
}

class _ModifierMedicamentScreenState extends State<ModifierMedicamentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _doseController;
  late TextEditingController _quantiteController;
  late bool _rappelActive;
  late String _typeSelectionne;
  late DateTime _dateSelectionnee;
  late TimeOfDay _heureSelectionnee;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.medicament.nom);
    _doseController = TextEditingController(text: widget.medicament.dose);
    _quantiteController =
        TextEditingController(text: widget.medicament.quantite.toString());
    _rappelActive = widget.medicament.rappelActive;
    _typeSelectionne = widget.medicament.type;
    _dateSelectionnee = widget.medicament.rappel;
    _heureSelectionnee = TimeOfDay.fromDateTime(widget.medicament.rappel);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _doseController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }

  Future<void> _sauvegarderModifications() async {
    if (_formKey.currentState!.validate()) {
      try {
        final quantite = int.tryParse(_quantiteController.text);
        if (quantite == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Veuillez entrer une quantité valide')),
          );
          return;
        }

        final medicamentModifie = Medicament(
          id: widget.medicament.id,
          nom: _nomController.text,
          type: _typeSelectionne,
          dose: _doseController.text,
          quantite: quantite,
          rappel: DateTime(
            _dateSelectionnee.year,
            _dateSelectionnee.month,
            _dateSelectionnee.day,
            _heureSelectionnee.hour,
            _heureSelectionnee.minute,
          ),
          rappelActive: _rappelActive,
          pris: widget.medicament.pris,
        );

        await storageService.updateMedicament(medicamentModifie);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        print("Erreur lors de la sauvegarde : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la sauvegarde des modifications')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateSelectionnee,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dateSelectionnee) {
      setState(() {
        _dateSelectionnee = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _heureSelectionnee,
    );
    if (picked != null && picked != _heureSelectionnee) {
      setState(() {
        _heureSelectionnee = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le médicament'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du médicament',
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
                  labelText: 'Type de médicament',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Gélule',
                  'Goutte',
                  'Comprimé',
                ]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _typeSelectionne = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'Dose',
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
                  labelText: 'Quantité',
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
                'Rappel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${_dateSelectionnee.day}/${_dateSelectionnee.month}/${_dateSelectionnee.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        '${_heureSelectionnee.hour}:${_heureSelectionnee.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activer le rappel'),
                value: _rappelActive,
                onChanged: (bool value) {
                  setState(() {
                    _rappelActive = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sauvegarderModifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Sauvegarder les modifications',
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
