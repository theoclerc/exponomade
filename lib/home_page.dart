
import 'package:exponomade/map_toggle.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var selectedIndex = 0; 

  @override
  Widget build(BuildContext context){
    
    Widget page;
    switch (selectedIndex) {
      //Map
      case 0:
        page = const MapToggle();
        break;
      //Contact
      case 1:
        page = const Placeholder(); //Replace by contact page 
        break;
      //Quiz
      case 2:
        page = const Placeholder(); //Replace by quiz page
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
}

    
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Map'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info),
                  label: Text('Contact'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.question_mark),
                  label: Text('Quiz'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
        )
      );
  }
}