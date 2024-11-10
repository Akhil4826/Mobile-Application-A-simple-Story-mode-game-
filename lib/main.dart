import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(StoryModeGameApp());

class StoryModeGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Mode Game',
      home: StoryScreen(),
    );
  }
}

class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List<Scene> scenes = [];
  int currentSceneId = 1;

  @override
  void initState() {
    super.initState();
    loadStoryData();
  }

  Future<void> loadStoryData() async {
    final String response = await rootBundle.loadString('assets/story.json');
    final data = json.decode(response);
    setState(() {
      scenes = (data['scenes'] as List)
          .map((scene) => Scene.fromJson(scene))
          .toList();
    });
  }

  void chooseNextScene(int nextSceneId) {
    setState(() {
      currentSceneId = nextSceneId;
    });
  }

  Scene get currentScene =>
      scenes.firstWhere((scene) => scene.id == currentSceneId);

  @override
  Widget build(BuildContext context) {
    if (scenes.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text("Story Mode Game")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentScene.text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Check if `choices` is not null before using `.map`
            if (currentScene.choices != null)
              ...currentScene.choices!.map((choice) => ElevatedButton(
                    onPressed: () => chooseNextScene(choice.nextSceneId),
                    child: Text(choice.text),
                  )),
            if (currentScene.choices == null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentSceneId = 1; // Restart the game
                  });
                },
                child: const Text("Restart"),
              ),
          ],
        ),
      ),
    );
  }
}

class Scene {
  final int id;
  final String text;
  final List<Choice>? choices;

  Scene({required this.id, required this.text, this.choices});

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'],
      text: json['text'],
      choices: json['choices'] != null
          ? (json['choices'] as List)
              .map((choice) => Choice.fromJson(choice))
              .toList()
          : null,
    );
  }
}

class Choice {
  final String text;
  final int nextSceneId;

  Choice({required this.text, required this.nextSceneId});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      text: json['text'],
      nextSceneId: json['next_scene'],
    );
  }
}
