//main.dart
//04/23/2025
//Cristian Rodriguez
//initializes the Flutter app, sets up the app theme, and launches the MyHomePage widget where users can enter/select their name, view their progress, and start the flashcard quiz.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'flashcard.dart'; // Import Flashcard class directly
import 'flashcard_list.dart'; // Import FlashcardList class

void main() {
  runApp(const SpanishLearningApp());
}

class SpanishLearningApp extends StatelessWidget {
  const SpanishLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spanish Learning App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  FlashcardList flashcardList = FlashcardList();
  String? selectedName;
  List<String> savedNames = [];
  int correctAnswers = 0;
  int totalFlashcards = 0;

  @override
  void initState() {
    super.initState();
    loadFlashcards();
    loadNames();
  }

  // Load flashcards from the JSON file
  Future<void> loadFlashcards() async {
    final String response = await rootBundle.loadString(
      'assets/flashcards.json',
    );
    final data = json.decode(response);
    final List<Flashcard> loadedFlashcards = [];

    data['flashcards'].forEach((flashcardData) {
      loadedFlashcards.add(
        Flashcard.fromJson(flashcardData),
      ); // Correct usage of Flashcard
    });

    setState(() {
      flashcardList.flashcards.addAll(loadedFlashcards);
      totalFlashcards = flashcardList.flashcards.length; // Set total flashcards
    });
  }

  // Load saved names from SharedPreferences
  Future<void> loadNames() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedNames = prefs.getStringList('savedNames') ?? [];
    });
  }

  // Save selected name to SharedPreferences
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    if (!savedNames.contains(name)) {
      savedNames.add(name);
    }
    await prefs.setStringList('savedNames', savedNames);
  }

  // Save correct answers to SharedPreferences
  Future<void> saveCorrectAnswers(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$name-rightAnswers',
      correctAnswers,
    ); // Save correct answers
    print('Correct Answers saved: $correctAnswers');
  }

  // Start flashcards from the first card
  void openFlashcardsPage(BuildContext context) {
    if (selectedName != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FlashcardPage(
                flashcardList: flashcardList,
                name: selectedName!,
                onComplete: (correctCount) {
                  setState(() {
                    correctAnswers = correctCount;
                  });
                  saveCorrectAnswers(
                    selectedName!,
                  ); // Save the result when all cards are answered
                },
              ),
        ),
      );
    }
  }

  // Reset the name and clear any stored progress when the reset button is pressed
  void reset() {
    setState(() {
      selectedName = null; // Clear selected name
      correctAnswers = 0; // Reset answers
      _controller.clear(); // Clear the text field
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spanish Learning App")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Spanish Learning App",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Enter or Select your name:",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              // TextField for entering new names
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Enter your name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedName = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (selectedName != null && selectedName!.isNotEmpty) {
                    await saveName(selectedName!);
                    setState(() {
                      selectedName = selectedName;
                    });
                    _controller.clear();
                  }
                },
                child: const Text("Save Name"),
              ),
              const SizedBox(height: 20),
              // Dropdown for selecting a saved name
              DropdownButton<String>(
                value: selectedName,
                hint: const Text("Select a saved name"),
                onChanged: (String? newName) async {
                  setState(() {
                    selectedName = newName;
                  });
                  if (newName != null) {
                    openFlashcardsPage(
                      context,
                    ); // Start flashcards after selecting name
                  }
                },
                items:
                    savedNames.isEmpty
                        ? []
                        : savedNames.map<DropdownMenuItem<String>>((
                          String name,
                        ) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  openFlashcardsPage(
                    context,
                  ); // Start flashcards from the first one
                },
                child: const Text("Start Flashcards"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: reset, // Reset the name and progress
                child: const Text("Reset Progress"),
              ),
              const SizedBox(height: 20),
              // Displaying progress
              Text(
                "Correct Answers: $correctAnswers / $totalFlashcards",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlashcardPage extends StatefulWidget {
  final FlashcardList flashcardList;
  final String name;
  final Function(int) onComplete;

  const FlashcardPage({
    super.key,
    required this.flashcardList,
    required this.name,
    required this.onComplete,
  });

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  late Flashcard currentFlashcard;
  String selectedOption = '';
  int currentIndex = 0;
  int correctAnswers = 0;
  String feedback = ''; // Feedback after each answer
  String finalMessage = ''; // Final message when all flashcards are done

  @override
  void initState() {
    super.initState();
    currentFlashcard = widget.flashcardList.getFlashcardAt(currentIndex);
  }

  void nextFlashcard(bool isCorrect) {
    if (isCorrect) {
      correctAnswers++; // Increment correct answers if the answer is correct
    }
    setState(() {
      currentIndex++;
      if (currentIndex < widget.flashcardList.length) {
        currentFlashcard = widget.flashcardList.getFlashcardAt(currentIndex);
      } else {
        // End of flashcards, notify completion
        widget.onComplete(
          correctAnswers,
        ); // Send total correct answers to parent
        feedback = 'You have completed all flashcards!'; // Final message
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flashcards")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Flashcard: ${currentFlashcard.spanish}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Display the answer options as buttons
            ...currentFlashcard.options.map((option) {
              return ElevatedButton(
                onPressed: () {
                  bool isCorrect = option == currentFlashcard.correctOption;
                  nextFlashcard(isCorrect);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  backgroundColor:
                      selectedOption == option ? Colors.blue : Colors.grey,
                  textStyle: const TextStyle(fontSize: 18),
                  minimumSize: const Size(200, 50),
                ),
                child: Text(option),
              );
            }).toList(),
            const SizedBox(height: 20),
            // Displaying feedback after answering
            Text(
              "Correct Answers: $correctAnswers",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Final message when all flashcards are done
            if (currentIndex >= widget.flashcardList.length) ...[
              Text(
                feedback,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
