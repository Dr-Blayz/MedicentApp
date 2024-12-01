import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicament.dart';
import '../main.dart';
import 'ajouter_medicament_screen.dart';
import 'detail_medicament_screen.dart';
import 'modifier_medicament_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _today = DateTime.now();
  final List<String> _weekDays = ['DIM', 'LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM'];
  List<Medicament> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final meds = await storageService.getMedicaments();
      if (!mounted) return;
      
      setState(() {
        _medications = meds;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des médicaments: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<DateTime> _getWeekDays() {
    final DateTime now = DateTime.now();
    final int currentDay = now.weekday;
    return List.generate(7, (index) {
      final difference = index - (currentDay - 1);
      return now.add(Duration(days: difference));
    });
  }

  int _getMedicationsTakenToday() {
    return _medications.where((med) => med.pris).length;
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medication, color: Colors.red),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.emoji_emotions, color: Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Aujourd'hui",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = weekDays[index];
                    final isToday = DateFormat('d').format(date) == 
                                  DateFormat('d').format(_today);
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            _weekDays[date.weekday % 7],
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Prises',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_getMedicationsTakenToday()}/${_medications.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE', 'fr').format(_today),
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _medications.length,
                        itemBuilder: (context, index) {
                          final med = _medications[index];
                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailMedicamentScreen(
                                    medicament: med,
                                    onDelete: () async {
                                      await storageService.deleteMedicament(med.id);
                                      if (mounted) {
                                        Navigator.pop(context);
                                        _loadMedications();
                                      }
                                    },
                                    onTake: () async {
                                      final updatedMed = Medicament(
                                        id: med.id,
                                        nom: med.nom,
                                        type: med.type,
                                        dose: med.dose,
                                        quantite: med.quantite,
                                        rappel: med.rappel,
                                        rappelActive: med.rappelActive,
                                        pris: true,
                                      );
                                      await storageService.updateMedicament(updatedMed);
                                      if (mounted) {
                                        Navigator.pop(context);
                                        _loadMedications();
                                      }
                                    },
                                    onEdit: () {
                                      // Implémenter la modification
                                    },
                                  ),
                                ),
                              );
                              _loadMedications();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.medication,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          med.nom,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${med.type} ${med.dose}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DateFormat('HH:mm').format(med.rappel),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ModifierMedicamentScreen(
                                                      medicament: med,
                                                    ),
                                                  ),
                                                );
                                                if (mounted) {
                                                  _loadMedications();
                                                }
                                              },
                                              child: const Text('Modifier'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AjouterMedicamentScreen(),
            ),
          );
          _loadMedications();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
