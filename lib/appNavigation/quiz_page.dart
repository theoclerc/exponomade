import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/question_model.dart';
import '../services/quiz_services.dart';
import '../widgets/question_widget.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override 
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future _question;

  int index = 0;
  int score = 0;
  bool isPressed = false;
  bool isAlreadySelected = false;

  @override
  void initState() {
    _question = QuizServices.getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _question as Future<List<Question>>,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (snapshot.hasData) {
              var extractedData = snapshot.data as List<Question>;
              return Scaffold(
                backgroundColor: background,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Questionnaire'),
                  backgroundColor: background,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text('Score: $score', style: const TextStyle(fontSize: 18.0)),
                    ),
                  ],
                ),
                body: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      QuestionWidget(
                        indexAction: index,
                        question: extractedData[index].title,
                        totalQuestions: extractedData.length,
                      ),
                      const SizedBox(height: 30.0),
                      for (int i = 0; i < extractedData[index].options.length; i++)
                        GestureDetector(
                          onTap: () => QuizServices.checkAnswerAndUpdate(
                            value: extractedData[index].options.values.toList()[i],
                            isAlreadySelected: isAlreadySelected,
                            setPressed: () => setState(() {
                              isPressed = true;
                            }),
                            setAlreadySelected: () => setState(() {
                              isAlreadySelected = true;
                            }),
                            incrementScore: () => setState(() {
                              score++;
                            }),
                          ),
                          child: SizedBox(
                            width: 500,
                            child: OptionCard(
                              option: extractedData[index].options.keys.toList()[i],
                              color: isPressed
                                ? extractedData[index].options.values.toList()[i] == true
                                  ? correct
                                  : incorrect
                                : neutral,
                          ),
                        ),
                        ),
                      GestureDetector(
                        onTap: () => QuizServices.nextQuestion(
                          context: context,
                          index: index,
                          score: score,
                          isPressed: isPressed,
                          extractedData: extractedData,
                          updateState: (indexValue, scoreValue, isPressedValue, isAlreadySelectedValue) {
                            setState(() {
                              index = indexValue;
                              score = scoreValue;
                              isPressed = isPressedValue;
                              isAlreadySelected = isAlreadySelectedValue;
                            });
                          }
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                          child: NextButton(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20.0),
                Text(
                  'Chargement...',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.none,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('Aucune donnée trouvée'));
      },
    );
  }
}
