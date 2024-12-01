class Medicament {
  final String id;
  final String nom;
  final String type;
  final String dose;
  final int quantite;
  final DateTime rappel;
  final bool rappelActive;
  bool pris;

  Medicament({
    required this.id,
    required this.nom,
    required this.type,
    required this.dose,
    required this.quantite,
    required this.rappel,
    required this.rappelActive,
    this.pris = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'dose': dose,
      'quantite': quantite,
      'rappel': rappel.toIso8601String(),
      'rappelActive': rappelActive,
      'pris': pris,
    };
  }

  factory Medicament.fromJson(Map<String, dynamic> json) {
    return Medicament(
      id: json['id'],
      nom: json['nom'],
      type: json['type'],
      dose: json['dose'],
      quantite: json['quantite'],
      rappel: DateTime.parse(json['rappel']),
      rappelActive: json['rappelActive'],
      pris: json['pris'] ?? false,
    );
  }
}
