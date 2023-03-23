import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/leaderboard_page.dart';
import 'home_page.dart';

class Player {
  final String name;
  int score;

  Player({required this.name, required this.score});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'score': score};
  }
}

class GamePage extends StatefulWidget {
  final String playerName;
  const GamePage({Key? key, required this.playerName}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int level = 1;
  int numberOfViews = 4; // default to Level 1
  int score = 0;
  late Timer timer;
  int secondsLeft = 5;
  int totalTouches = 0;
  Set<int> highlightedIndexes =
      {}; // Set to store the indexes of highlighted views
  bool isGameOver = false; // Flag to indicate if game is over
  bool timeStarted = false;
  List<Player> top25Players = [
    Player(name: 'Warren', score: 10),
    Player(name: 'Kevin', score: 20),
    Player(name: 'Ivan', score: 30),
    Player(name: 'Navi', score: 34),
    Player(name: 'Nasa', score: 29),
    Player(name: 'Nellie', score: 25),
    Player(name: 'Kelly', score: 23),
    Player(name: 'Melissa', score: 22),
    Player(name: 'Shireen', score: 21),
    Player(name: 'Jiaqi', score: 20),
    Player(name: 'Penny', score: 19),
    Player(name: 'Yuru', score: 18),
    Player(name: 'Jiabao', score: 17),
    Player(name: 'Sinrou', score: 13),
    Player(name: 'Tong', score: 11),
    Player(name: 'Nan', score: 9),
    Player(name: 'Xixi', score: 6),
    Player(name: 'Hehe', score: 3),
    Player(name: 'hoho', score: 2),
    Player(name: 'Jehere', score: 24),
    Player(name: 'Jenny', score: 12),
    Player(name: 'Sinjoe', score: 5),
    Player(name: 'huiYee', score: 8),
    Player(name: 'Jingyu', score: 1),
    Player(name: 'Huiyi', score: 9),
  ];

  @override
  void initState() {
    super.initState();
    // Add some sample players to the top25Players list

    loadData();
    startTimer();
    highlightedIndexes.add(
        Random().nextInt(numberOfViews)); // Highlight a random view initially
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel timer when screen is disposed
    super.dispose();
  }

  void startTimer() {
    if (score > 0) {
      timer.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        secondsLeft--;
        if (secondsLeft < 1) {
          handleTimerOver();
        }
      });
    } else if (score == 0) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        secondsLeft--;
        if (secondsLeft < 1) {
          handleTimerOver();
        }
      });
    }
  }

  /*void startTimer() {
    timer.cancel(); // Cancel any existing timer
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsLeft--;
      if (secondsLeft < 1) {
        handleTimerOver();
      }
    });
  }*/

  void handleTouch(int index) {
    if (highlightedIndexes.contains(index)) {
      score++;
      secondsLeft += 1; // Increase duration time by 1 seconds
      startTimer();
      highlightedIndexes.remove(index);
      // Check if the score meets the level up conditions
      if (score == 6 || score == 11 || score == 21 || score == 41) {
        handleLevelUp();
      }
    }
    totalTouches++;
    if (highlightedIndexes.isEmpty) {
      setState(() {
        highlightedIndexes.clear();
        highlightedIndexes
            .add(Random().nextInt(numberOfViews)); // Highlight a random view
      });
    }
  }

  void handleLevelUp() {
    level++;
    secondsLeft -= 2;
    if (score == 6) {
      numberOfViews = 9;
    } else if (score == 11) {
      numberOfViews = 16;
    } else if (score == 21) {
      numberOfViews = 25;
    } else if (score == 41) {
      numberOfViews = 36;
    }
  }

  Future<void> handleTimerOver() async {
    timer.cancel(); // Stop the timer
    highlightedIndexes.clear();
    isGameOver = true;
    addPlayer(widget.playerName, score);
  }

  void addPlayer(String name, int score) {
    Player newPlayer = Player(
      name: name,
      score: score,
    );
    // Check if the new player is already in the list
    bool foundPlayer = false;
    for (Player player in top25Players) {
      if (player.name == newPlayer.name) {
        foundPlayer = true;
        // Update the existing player's score if the new score is higher
        if (newPlayer.score > player.score) {
          player.score = newPlayer.score;
        }
        break;
      }
    }
    // If the new player is not already in the list, add it
    if (!foundPlayer) {
      if (top25Players.length < 25) {
        // If the list has less than 25 players, simply add the new player
        top25Players.add(newPlayer);
      } else {
        // Otherwise, check if the new player's score is higher than the score of the 25th player in the list
        if (score > top25Players[24].score) {
          // If the new player's score is higher, add the new player and remove the player with the lowest score
          top25Players.removeLast();
          top25Players.add(newPlayer);
        }
      }
    }
    top25Players.sort((a, b) => b.score.compareTo(a.score));
    setState(() {
      top25Players = top25Players.toList();
    });
    saveData();
  }

  // Loads the user's name and score from shared preferences
  Future<List<Player>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<Player> top25Players = [];

    for (int i = 0; i < 25; i++) {
      final score = prefs.getInt('player$i-score');
      final name = prefs.getString('player$i-name');
      if (score != null && name != null) {
        top25Players.add(Player(name: name, score: score));
      }
    }

    return top25Players;
  }

  // Saves the user's name and score to shared preferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 25 && i < top25Players.length; i++) {
      await prefs.setInt('player$i-score', top25Players[i].score);
      await prefs.setString('player$i-name', top25Players[i].name);
    }
  }

  Widget buildGame(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level $level'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: GridView.count(
                  crossAxisCount: level + 1,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                  children: List.generate(
                    numberOfViews,
                    (index) => GestureDetector(
                      onTap: () => handleTouch(index),
                      child: Container(
                        color: highlightedIndexes.contains(index)
                            ? Colors.blueGrey.shade800
                            : Colors.grey.shade600,
                        margin: const EdgeInsets.all(1.0),
                        transform: Matrix4.diagonal3Values(0.5, 0.5, 1.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time left: $secondsLeft seconds',
                    style: const TextStyle(fontSize: 25),
                  ),
                  Text(
                    'Score: $score',
                    style: const TextStyle(fontSize: 25),
                  ),
                  Text(
                    'Touches: $totalTouches',
                    style: const TextStyle(fontSize: 25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGameOver(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Your Score: $score',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Home'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Leaderboard(players: top25Players),
                  ),
                );
              },
              child: const Text('View Leaderboard'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      return buildGameOver(context);
    } else {
      if (!timeStarted) {
        startTimer();
        timeStarted = true;
      }
      return buildGame(context);
    }
  }
}
