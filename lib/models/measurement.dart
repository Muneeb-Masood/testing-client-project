class Measurement {
  String title;
  String unit;
  double measure;
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measurement &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          unit == other.unit &&
          measure == other.measure;

  Measurement({required this.title, this.unit = 'in', required this.measure});
  Map<String, dynamic> toJson() =>
      {'title': title, 'unit': unit, 'measure': measure};

  static Measurement fromJson(Map<String, dynamic> json) => Measurement(
        title: json['title'],
        unit: json['unit'],
        measure: json['measure'].toDouble(),
      );

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MeasurementChoice {
  online,
  physical,
  viaAgent,
}

List<String> measurementChoiceSubtitles = [
  'I will submit measurements online.',
  "I will come to tailor's shop to submit measurements.",
  'Tailor will send an agent to take measurements.',
];

const Map<String, String> totalMeasurements = {
  "neck": "assets/measurementImages/neck.jpg",
  "shoulderWidth": "assets/measurementImages/shoulderWidth.jpg",
  "halfShoulder": "assets/measurementImages/halfShoulder.jpg",
  "chest": "assets/measurementImages/chest.jpg",
  "waist": "assets/measurementImages/waist.jpg",
  "waistToAnkle": "assets/measurementImages/waistToAnkle.jpg",
  "shirtLength": "assets/measurementImages/shirtLength.jpg",
  "sleeveLength": "assets/measurementImages/sleeveLength.jpg",
};
