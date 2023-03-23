import 'package:flutter/material.dart';

import 'game_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize formKey in initState
    formKey.currentState?.dispose();
  }

  void startGame(BuildContext context) {
    debugPrint('formKey.currentState: ${formKey.currentState}');
    debugPrint('nameController.text: ${nameController.text}');

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      // Navigate to the game page if the form is valid
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(
            playerName: nameController.text,
          ),
        ),
      );
    } else {
      debugPrint('error: form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Image.asset('images/game.png'),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  startGame(context); // pass the context as a parameter
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(
                      Icons.games,
                      color: Color.fromARGB(255, 77, 187, 60),
                    ),
                    Text(
                      'Play Game',
                      style: TextStyle(
                          color: Color.fromARGB(255, 1, 177, 42), fontSize: 25),
                    ),
                    Icon(
                      Icons.games,
                      color: Color.fromARGB(255, 77, 187, 60),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
