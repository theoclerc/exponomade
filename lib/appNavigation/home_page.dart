import 'package:exponomade/maps/map_toggle.dart';
import 'contact_page.dart';
import 'package:flutter/material.dart';
import 'package:exponomade/appNavigation/quiz_page.dart';

class HomePage extends StatefulWidget {
  
  final int initialPage;
  final int? score;

  const HomePage({Key? key, this.initialPage = 0, this.score}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialPage;
  }

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
        page = ContactPage(score: widget.score); 
        break;
      //Quiz
      case 2:
        page = const QuizPage();
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