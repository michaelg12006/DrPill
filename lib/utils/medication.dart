
class Medication {
  final String id;
  final String name;
  final String dosage;
  final String instruction;
  final String time;
  final bool isTaken;
  final bool isAsNeeded;

  Medication({
    this.id = '',
    required this.name,
    required this.dosage,
    required this.instruction,
    required this.time,
    this.isTaken = false,
    this.isAsNeeded = false,
  });

  Medication copyWith({
    bool? isTaken,
  }) {
    return Medication(
      id: id,
      name: name,
      dosage: dosage,
      instruction: instruction,
      time: time,
      isTaken: isTaken ?? this.isTaken,
      isAsNeeded: isAsNeeded,
    );
  }
}
