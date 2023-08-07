import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/data/teamProfile.dart';

class QuestionDrawer extends StatefulWidget {
  QuestionDrawer(
      {super.key,
      required this.questionData,
      required this.teamProfile,
      required this.drawQuestion});

  QuestionData questionData;
  TeamProfile teamProfile;
  bool drawQuestion;

  @override
  State<QuestionDrawer> createState() => _QuestionDrawerState();
}

class _QuestionDrawerState extends State<QuestionDrawer> {
  @override
  Widget build(BuildContext context) {
    var questionController = TextEditingController(
        text: widget.questionData.answers['אחר'] is bool
            ? ''
            : widget.questionData.answers['אחר']);

    // If the question is a title, draw it as a title with a divider
    if (widget.questionData.isTitle) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.questionData.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: 1,
            ),
          ],
        ),
      );
    }

    if (widget.questionData.isMultiple) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.drawQuestion)
            Text(
              widget.questionData.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.questionData.answers.keys.map((String key) {
              return Row(
                children: [
                  Checkbox(
                    // Color: orange
                    activeColor: Colors.orange.shade600,
                    value: widget.questionData.answers[key] is bool
                        ? widget.questionData.answers[key]
                        : true,
                    onChanged: (bool? value) {
                      setState(() {
                        log('Change question: value: $value | key: $key');
                        updateMultipleAnswerQuestion(key, value!);
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        var value = widget.questionData.answers[key] is bool
                            ? !widget.questionData.answers[key]
                            : true;
                        log('Change question: value: $value | key: $key');
                        updateMultipleAnswerQuestion(key, value);
                      });
                    },
                    child: (key == 'אחר')
                        ? // If 'other' is selected, show text field
                        // The entry of the text field will be saved in
                        // widget.teamProfile.teamData.value[widget.questionData]
                        // as the value of the 'אחר' key

                        SizedBox(
                            width: 200,
                            height: 50,
                            child: TextField(
                              controller: questionController,
                              enabled: widget.questionData.answers[key] is bool
                                  ? widget.questionData.answers[key]
                                  : true,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                                labelText: 'הקלד תשובה',
                                labelStyle: TextStyle(
                                  color:
                                      widget.questionData.answers[key]! is bool
                                          ? widget.questionData.answers[key]!
                                              ? Colors.orange.shade600
                                              : Colors.black
                                          : Colors.black,
                                ),
                              ),
                              onChanged: (value) {
                                log('Change question: value: ${questionController.text} | key: $key');
                                updateMultipleAnswerQuestion(
                                    key, questionController.text);
                              },
                            ),
                          )
                        : Text(
                            key
                            // If the answer is selected, make it orange
                            ,
                            style: TextStyle(
                              fontSize: 18,
                              color: widget.questionData.answers[key]!
                                  ? Colors.orange.shade600
                                  : Colors.black,
                            )),
                  )
                ],
              );
            }).toList(),
          ),
        ],
      );
    }
    // Not multiple choice with possibility to choose only one answer
    else if (widget.questionData.isTextOnly == false) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.drawQuestion)
            Text(
              widget.questionData.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.questionData.answers.keys.map((String key) {
              return Row(
                children: [
                  Radio(
                    activeColor: Colors.orange.shade600,
                    value: widget.questionData.answers[key]! is bool
                        ? widget.questionData.answers[key]
                        : true,
                    groupValue: true,
                    onChanged: (value) {
                      setState(() {
                        log('Change question: value: $value | key: $key');
                        updateSingleAnswerQuestion(key, !value);
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        var value = true;
                        log('Change question: value: $value | key: $key');
                        updateSingleAnswerQuestion(key, value);
                      });
                    },
                    child: (key == 'אחר')
                        ? SizedBox(
                            width: 200,
                            height: 50,
                            child: TextField(
                              controller: questionController,
                              enabled: widget.questionData.answers[key] is bool
                                  ? widget.questionData.answers[key]
                                  : true,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                                labelText: 'הקלד תשובה',
                                labelStyle: TextStyle(
                                  color:
                                      widget.questionData.answers[key] is bool
                                          ? widget.questionData.answers[key]!
                                              ? Colors.orange.shade600
                                              : Colors.black
                                          : Colors.black,
                                ),
                              ),
                              onChanged: (value) {
                                log('Change question: value: ${questionController.text} | key: $key');
                                updateSingleAnswerQuestion(
                                    key, questionController.text);
                              },
                            ),
                          )
                        : Text(key,
                            style: TextStyle(
                              fontSize: 18,
                              // If the answer is selected, make it orange
                              color: widget.questionData.answers[key]!
                                  ? Colors.orange.shade600
                                  : Colors.black,
                            )),
                  )
                ],
              );
            }).toList(),
          ),
        ],
      );
    }

    // If text only
    if (widget.questionData.isTextOnly) {
      return Column(
        children: [
          Text(widget.questionData.text),
          const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Answer',
            ),
          ),
        ],
      );
    }

    return Container();
  }

  void updateMultipleAnswerQuestion(String key, dynamic value) {
    widget.questionData.answers[key] = value;
    widget.teamProfile.teamData.value[widget.questionData] =
        widget.questionData.answers;
  }

  void updateSingleAnswerQuestion(String key, dynamic value) {
    widget.questionData.answers.forEach((key, value) {
      widget.questionData.answers[key] = false;
    });
    widget.questionData.answers[key] = value;
    widget.teamProfile.teamData.value[widget.questionData] =
        widget.questionData.answers;
  }
}
