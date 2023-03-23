import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/game_page.dart';

class Leaderboard extends StatefulWidget {
  final List<Player> players;

  const Leaderboard({Key? key, this.players = const []}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    players = [];
    for (int i = 0; i < 25; i++) {
      final playerScore = prefs.getInt('player$i-score');
      final playerName = prefs.getString('player$i-name');
      if (playerScore != null && playerName != null) {
        players.add(Player(name: playerName, score: playerScore));
      }
    }
    players.sort((a, b) =>
        b.score.compareTo(a.score)); // sort in descending order of score
    setState(() {
      players = players;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return ListTile(
            leading: Text('Top ${index + 1}'),
            title: Text(player.name),
            trailing: Text(player.score.toString()),
          );
        },
      ),
    );
  }
}
