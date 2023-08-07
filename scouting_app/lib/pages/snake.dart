import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/pages/homePage.dart';
import 'package:scouting_demo/pages/loggedIn.dart';
import 'package:scouting_demo/widgets/userStateManager.dart';

class Snake extends StatefulWidget {
  const Snake({super.key});

  @override
  State<Snake> createState() => _SnakeState();
}

class _SnakeState extends State<Snake> {
  static List<int> snakePosition = [45, 65, 85, 105, 125];
  int numberOfSquares = 760;

  static var randomNumber = Random();
  int food = randomNumber.nextInt(700);
  void generateNewFood() {
    food = randomNumber.nextInt(700);
  }

  void startGame() {
    UserStateManager.setUserState(UserStates.InSnake);
    snakePosition = [45, 65, 85, 105, 125];
    const Duration duration = Duration(milliseconds: 150);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver()) {
        timer.cancel();
        _showGameOverScreen();
      }
    });
  }

  var direction = 'down';
  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > 740) {
            snakePosition.add(snakePosition.last + 20 - 760);
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break;
        case 'up':
          if (snakePosition.last < 20) {
            snakePosition.add(snakePosition.last - 20 + 760);
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;
        case 'left':
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(snakePosition.last - 1 + 20);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(snakePosition.last + 1 - 20);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
        default:
      }
      if (snakePosition.last == food) {
        generateNewFood();
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(0xFFFF5722),
      body: Column(
        children: <Widget>[
          Expanded(
              child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (direction != 'up' && details.delta.dy > 0) {
                direction = 'down';
              } else if (direction != 'down' && details.delta.dy < 0) {
                direction = 'up';
              }
            },
            onHorizontalDragUpdate: (details) {
              if (direction != 'left' && details.delta.dx > 0) {
                direction = 'right';
              } else if (direction != 'right' && details.delta.dx < 0) {
                direction = 'left';
              }
            },
            child: Container(
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: numberOfSquares,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 20,
                  ),
                  itemBuilder: (context, index) {
                    if (snakePosition.contains(index)) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                    if (index == food) {
                      return Container(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Colors.green,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: const Color(0xFF225B),
                          ),
                        ),
                      );
                    }
                  }),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: startGame,
                    child: const Text(
                      'Start Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showGameOverScreen,
                    child: const Text(
                      'End Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Text(
                    'Score: ${snakePosition.length - 5}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ]),
          )
        ],
      ));

  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 999999;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count++;
        }
        if (count > 1) {
          return true;
        }
      }
    }

    return false;
  }

  void _showGameOverScreen() {
    UserStateManager.setUserState(UserStates.Online);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Game Over"),
            content: Text("You\'re score: ${snakePosition.length - 5}"),
            actions: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Play Again"),
                      onPressed: () {
                        startGame();
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Exit"),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pop(context); // Closing the NavigationBar
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
