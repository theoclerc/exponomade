import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OptionCard extends StatelessWidget {
  const OptionCard({Key? key, required this.option, required this.color,}) : super(key: key);
  final String option;
  final Color color;

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: ListTile(
            title: Text(
              option,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0,
                color: color.red != color.green ? neutral : Colors.black,
            ),
            ),
          ),
        ),
      ),
    );  
  }
}
