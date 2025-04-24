//flashcard_list.dart
//04/23/2025
//Cristian Rodriguez
//defines a FlashcardList class that manages a list of flashcards, tracks the user's progress, and allows saving and loading the progress to and from a local JSON file.

import 'dart:convert'; // For json.decode
import 'dart:io'; // For File handling
import 'package:path_provider/path_provider.dart'; // For getting file directory
import 'flashcard.dart'; // Ensure the Flashcard class is imported

class FlashcardList {
  final List<Flashcard> _flashcards = [];
  int correctAnswers = 0; // Track the number of correct answers
  int currentFlashcardIndex = 0; // Track the current flashcard index

  List<Flashcard> get flashcards => _flashcards;

  void addFlashcard(Flashcard flashcard) {
    _flashcards.add(flashcard);
  }

  Flashcard getFlashcardAt(int index) => _flashcards[index];

  int get length => _flashcards.length;

  // Update the progress (increase correctAnswers if the answer is correct)
  void updateProgress(bool isCorrect) {
    if (isCorrect) {
      correctAnswers++;
    }
  }

  // Save the user's progress to a JSON file
  Future<void> saveProgress(String selectedOption) async {
    final file = await _getProgressFile();
    final progress = UserProgress(
      correctAnswers: correctAnswers,
      currentFlashcardIndex: currentFlashcardIndex,
    );
    final progressJson = json.encode(progress.toJson());

    // Save the progress to the file
    await file.writeAsString(progressJson);
  }

  // Load the user's progress from the JSON file
  Future<UserProgress?> loadProgress() async {
    try {
      final file = await _getProgressFile();
      if (file.existsSync()) {
        final content = await file.readAsString();
        final Map<String, dynamic> jsonData = json.decode(content);
        return UserProgress.fromJson(jsonData);
      }
    } catch (e) {
      print("Error loading progress: $e");
    }
    return null;
  }

  // Helper method to get the progress file
  Future<File> _getProgressFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/progress.json';
    return File(path);
  }
}

// This class represents the user's progress (correct answers, current flashcard index)
class UserProgress {
  final int correctAnswers;
  final int currentFlashcardIndex;

  UserProgress({
    required this.correctAnswers,
    required this.currentFlashcardIndex,
  });

  // Convert the progress to JSON
  Map<String, dynamic> toJson() {
    return {
      'correctAnswers': correctAnswers,
      'currentFlashcardIndex': currentFlashcardIndex,
    };
  }

  // Convert JSON back into a UserProgress object
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      correctAnswers: json['correctAnswers'],
      currentFlashcardIndex: json['currentFlashcardIndex'],
    );
  }
}
