//flashcard.dart
//04/23/2025
//Cristian Rodriguez
//defines a Flashcard class with properties for a Spanish word, its English translation, multiple choice options, and the correct answer, along with methods to convert between JSON data and Flashcard objects.

class Flashcard {
  String spanish;
  String english;
  List<String> options;
  String correctOption;

  Flashcard({
    required this.spanish,
    required this.english,
    required this.options,
    required this.correctOption,
  });

  // Convert JSON data to Flashcard object
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      spanish: json['spanish'],
      english: json['english'],
      options: List<String>.from(json['options']),
      correctOption: json['correctOption'],
    );
  }

  // Convert Flashcard object to JSON
  Map<String, dynamic> toJson() {
    return {
      'spanish': spanish,
      'english': english,
      'options': options,
      'correctOption': correctOption,
    };
  }
}
