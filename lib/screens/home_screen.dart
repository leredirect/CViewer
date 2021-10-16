import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Курсы валют"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed('settings');
          }, icon: const Icon(Icons.settings_sharp)),
        ],
      ),
      body: const Placeholder(),
    );
  }
}
