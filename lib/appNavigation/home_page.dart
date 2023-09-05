import 'package:flutter/material.dart';
import 'package:exponomade/maps/map_toggle.dart';
import 'package:exponomade/appNavigation/contact_page.dart';
import 'package:exponomade/appNavigation/admin_page.dart';
import 'package:exponomade/appNavigation/quiz_page.dart';

class HomePage extends StatefulWidget {
  // First page.
  final int initialPage;
  // User's score.
  final int? score;

  const HomePage({Key? key, this.initialPage = 0, this.score}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index for the desired page.
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    // Initialize the selectedIndex with the initialPage value passed to the widget.
    selectedIndex = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    // Determine which page to display based on the selectedIndex.
    switch (selectedIndex) {
      // Case 0: Map Page.
      case 0:
        page = const MapToggle();
        break;
      // Case 1: Contact Page.
      case 1:
        page = ContactPage(score: widget.score);
        break;
      // Case 2: Quiz Page.
      case 2:
        page = const QuizPage();
        break;
      // Case 3: Admin Page.
      case 3:
        page = AdminPage();
        break;
      default:
        // Throw an error if selectedIndex is out of range.
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            // Navigation rail on the left of the page.
            child: NavigationRail(
              extended: false,
              destinations: [
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
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Admin'),
                ),
              ],
              selectedIndex: selectedIndex,
              // Callback when a destination is selected to update selectedIndex.
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              // Set the container's color using the theme's primaryContainer color.
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}
