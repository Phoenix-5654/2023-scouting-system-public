import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/First_api/match.dart';
import 'package:scouting_demo/First_api/team.dart';
import 'package:scouting_demo/pages/Pit_Scouting/teamSelectionPage.dart';

import '../../data/teamProfile.dart';
import '../../widgets/PitScouting/messagesView.dart';

class IconActions {
  static const String START_POS = 'S';
  static const String CONE_PICKUP = 'C';
  static const String CUBE_PICKUP = 'U';
  static const String PARK = 'P';
  static const String EMPTY = '';

  static Widget getIcon(String action, {bool isLight = false}) {
    switch (action) {
      case START_POS:
        return Icon(Icons.home, color: (isLight) ? Colors.grey : Colors.black);
      case CONE_PICKUP:
        return (isLight)
            ? Image.asset(
                'assets/Images/cone_light.png',
                height: 25,
                width: 25,
              )
            : Image.asset(
                'assets/Images/cone_grey.png',
                height: 25,
                width: 25,
              );
      case CUBE_PICKUP:
        return (isLight)
            ? Image.asset(
                'assets/Images/cube_light.png',
                height: 25,
                width: 25,
              )
            : Image.asset(
                'assets/Images/cube_grey.png',
                height: 25,
                width: 25,
              );
      case PARK:
        return Icon(Icons.local_parking_rounded,
            color: (isLight) ? Colors.grey : Colors.black);
      default:
        return const Icon(Icons.construction);
    }
  }

  static String getIconString(Widget icon) {
    if (icon is Icon) {
      if (icon.icon == Icons.home) {
        return START_POS;
      } else if (icon.icon == Icons.local_parking_rounded) {
        return PARK;
      }
    } else if (icon is Image) {
      if (icon.image == const AssetImage('assets/Images/cone_grey.png')) {
        return CONE_PICKUP;
      } else if (icon.image ==
          const AssetImage('assets/Images/cube_grey.png')) {
        return CUBE_PICKUP;
      }
    }
    return '';
  }
}

class AutonomusPage extends StatefulWidget {
  AutonomusPage({
    super.key,
    required this.teamProfile,
    required this.selectedMatch,
    this.alliance = ' ',
    this.isMatch = false,
  });

  bool isMatch;
  match selectedMatch;
  TeamProfile teamProfile;

  String alliance;

  static ValueNotifier<AutonomusPattern> currentPattern =
      ValueNotifier<AutonomusPattern>(AutonomusPattern(data: {}, comments: {}));

  @override
  State<AutonomusPage> createState() => _AutonomusPageState();

  Map<List<int>, String> getIcons() {
    return _AutonomusPageState().getIcons();
  }

  Map<List<int>, TextEditingController> getIconsComments() {
    return _AutonomusPageState().getIconsComments();
  }

  bool isComplete() {
    return _AutonomusPageState().isComplete();
  }
}

class _AutonomusPageState extends State<AutonomusPage> {
  Map<List<int>, String> icons = {};
  Map<List<int>, TextEditingController> iconsComments = {};

  String _selectedIcon = IconActions.EMPTY;
  AutonomusPattern _selectedPattern = AutonomusPattern(data: {}, comments: {});

  int gameElements = 0;

  Map<List<int>, String> getIcons() {
    return icons;
  }

  Map<List<int>, TextEditingController> getIconsComments() {
    return iconsComments;
  }

  Widget drawNavigation(TeamProfile teamProfile) {
    return Container(
      color: Colors.transparent,
      child: CurvedNavigationBar(
        color: Colors.orange.shade600,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.orange.shade600,
        animationCurve: Curves.easeInOut,
        // Set height to 10% of the screen height or 75 pixels, whichever is smaller.
        height: math.min(MediaQuery.of(context).size.height * 0.1, 75),
        items: const <Widget>[
          Icon(Icons.article, size: 30, color: Colors.white),
          Icon(Icons.message, size: 30, color: Colors.white),
          Icon(Icons.data_usage, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesView(teamProfile: teamProfile),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AutonomusPage(
                    teamProfile: teamProfile,
                    selectedMatch: widget.selectedMatch,
                  ),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pattern selector (One of the existing patterns or a new one)

        // Show 'buildMenu' only if 'isMatch' is false
        if (!widget.isMatch) buildMenu(),
        // Map
        buildMap(),

        // Icon selection row
        buildSelectionRow(),

        // Build the list of icons - only if 'isMatch' is false
        if (!widget.isMatch) buildList(),

        // If in match, show text button to show list of icons
        if (widget.isMatch)
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Autonomus actions'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      buildList(isMatch: widget.isMatch),

                      // Exit button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Exit',
                            style: TextStyle(color: Colors.orange.shade600)),
                      ),
                    ]),
                  );
                },
              );
            },
            child: const Text(
              'Show actions',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),

        // Submit button
        if (!widget.isMatch) buildSubmitButton(),
      ],
    );
  }

  ElevatedButton buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        // If there is no START_POS and PARK, can't submit
        if (!isComplete()) return;

        var db = FirebaseFirestore.instance;

        // If not in match, add to pit history
        // Add new document to '/teams/<teamNum>/pit_history/autonomus/<id>'
        // - ID: auto generated
        // - Data:
        //    [
        //      index : [x, y, icon]
        //    ]

        if (!widget.isMatch) {
          db
              .collection('teams')
              .doc(TeamSelectionPage.selectedTeam.value.teamNum.toString())
              .collection('pit_history')
              .doc('autonomus')
              .collection('autonomus')
              .add({
            for (var i = 0; i < icons.length; i++)
              i.toString(): [
                icons.keys.elementAt(i)[0],
                icons.keys.elementAt(i)[1],
                icons.values.elementAt(i),
                iconsComments.values.elementAt(i).text
              ]
          });
        }

        // Removing all icons from the map
        setState(() {
          icons.clear();
          iconsComments.clear();
        });

        // Show user snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('המידע נשלח בהצלחה'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: (!isComplete()) ? Colors.grey : Colors.orange.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
      child: const Text('שלח'),
    );
  }

  Row buildSelectionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: IconActions.getIcon(IconActions.START_POS),
          color: icons.containsValue(IconActions.START_POS)
              ? Colors.grey
              : Colors.black,
          onPressed: () {
            // If START_POS is already in icons, can't add it again
            if (icons.containsValue(IconActions.START_POS)) return;
            setState(() {
              _selectedIcon = IconActions.START_POS;
            });
          },
        ),
        IconButton(
          icon: IconActions.getIcon(IconActions.CONE_PICKUP,
              isLight: !icons.containsValue(IconActions.START_POS) ||
                  icons.containsValue(IconActions.PARK) ||
                  gameElements >= 4),
          onPressed: () {
            setState(() {
              _selectedIcon = IconActions.CONE_PICKUP;
            });
          },
        ),
        IconButton(
          icon: IconActions.getIcon(IconActions.CUBE_PICKUP,
              isLight: !icons.containsValue(IconActions.START_POS) ||
                  icons.containsValue(IconActions.PARK) ||
                  gameElements >= 4),
          onPressed: () {
            setState(() {
              _selectedIcon = IconActions.CUBE_PICKUP;
            });
          },
        ),
        IconButton(
          icon: IconActions.getIcon(IconActions.PARK,
              isLight: !icons.containsValue(IconActions.START_POS) ||
                  icons.containsValue(IconActions.PARK)),
          onPressed: () {
            setState(() {
              _selectedIcon = IconActions.PARK;
            });
          },
        ),

        // Divider
        Container(
          width: 1,
          height: 30,
          color: Colors.black,
        ),
        // Clear button
        IconButton(
          icon: const Icon(Icons.undo_sharp),
          color: Colors.redAccent,
          onPressed: () {
            setState(() {
              // Remove the last icon, if it was a game element, decrement the counter
              if (icons.isNotEmpty) {
                if (icons.values.last == IconActions.CONE_PICKUP ||
                    icons.values.last == IconActions.CUBE_PICKUP) {
                  gameElements--;
                }
                icons.remove(icons.keys.last);
                iconsComments.remove(iconsComments.keys.last);
                AutonomusPage.currentPattern.value.data.remove(icons.keys.last);
                AutonomusPage.currentPattern.value.comments
                    .remove(iconsComments.keys.last);
              }
            });
          },
        ),
      ],
    );
  }

  Widget buildMenu() {
    List<String> menuItems = [];

    log("Building menu with ${widget.teamProfile.autonomusData.patterns.length} patterns");
    menuItems.add("New pattern");

    int i = 0;
    for (var pattern in widget.teamProfile.autonomusData.patterns) {
      menuItems.add("Pattern ${i++} - ${pattern.data.keys.length} elements");
    }

    return PopupMenuButton(
      initialValue: menuItems[0],
      itemBuilder: (context) {
        return menuItems
            .map((item) => PopupMenuItem(
                  child: Text(item),
                  value: item,
                ))
            .toList();
      },
      onSelected: (value) {
        if (value == "New pattern") {
          log("New pattern selected");
        } else {
          setState(() {
            // Saving the icons

            var pattern = widget.teamProfile.autonomusData.patterns
                .elementAt(menuItems.indexOf(value) - 1);

            icons.addAll(pattern.data);
            iconsComments.addAll(pattern.comments);
          });
        }
      },
    );
  }

  Widget buildMap() {
    String path = 'assets/Images/blue_field.jpeg';
    if (widget.alliance == "red") {
      path = 'assets/Images/red_field.jpg';
    } else if (widget.alliance == "blue") {
      path = 'assets/Images/blue_field.jpg';
    }

    var height = math.min(MediaQuery.of(context).size.height * 0.25, 500);
    var width = math.min(MediaQuery.of(context).size.width * 0.5, 500);

    return Container(
      margin: const EdgeInsets.all(10),
      height: height.toDouble() + 20,
      width: width.toDouble() + 20,
      child: GestureDetector(
          // On tap down, print the tap coordinates
          onTapDown: (TapDownDetails details) {
            var divisor = 10;
            var relX = (details.localPosition.dx / divisor).round() * divisor;
            var relY = (details.localPosition.dy / divisor).round() * divisor;

            // Check if coordinates are in range
            // The range is within the field, but not too close to the edges
            // Calculating the sizes using 'width' and 'height' variables

            var inRange = relX > 0 &&
                relX < width &&
                relY > 0 &&
                relY < height &&
                relX > 10 &&
                relX < width - 10 &&
                relY > 10 &&
                relY < height - 10;

            // Check if coordinates are already occupied
            bool isOccupied = icons.containsKey([relX, relY]);

            log("Tap coordinates: ($relX, $relY)\nIn range: $inRange\nOccupied: $isOccupied");

            // If START_POS is already in icons, can't add it again
            if (_selectedIcon == IconActions.START_POS) {
              if (icons.containsValue(IconActions.START_POS)) return;
            }

            if (!icons.containsValue(IconActions.START_POS) &&
                _selectedIcon != IconActions.START_POS) {
              return;
            }

            // If PARK is already in icons, can't add any other icon
            if (icons.containsValue(IconActions.PARK)) return;

            if (_selectedIcon == IconActions.CONE_PICKUP ||
                _selectedIcon == IconActions.CUBE_PICKUP) {
              if (gameElements >= 4) return;
            }

            if (inRange && !isOccupied) {
              setState(() {
                // Saving the coordinates - if they are in range
                icons[[relX, relY]] = _selectedIcon;

                // Add empty TextEditingController on the comments map
                iconsComments[[relX, relY]] = TextEditingController();

                if (_selectedIcon == IconActions.CONE_PICKUP ||
                    _selectedIcon == IconActions.CUBE_PICKUP) {
                  gameElements++;
                }

                // Saving the data into 'selectedPattern'
                AutonomusPage.currentPattern.value.data = icons;
                AutonomusPage.currentPattern.value.comments = iconsComments;
              });
            }
          },
          child: Stack(
            children: [
              // The image
              Image.asset(
                path,
                fit: BoxFit.scaleDown,
                width: width.toDouble(),
                height: height.toDouble(),
                alignment: Alignment.topCenter,
              ),

              // The icons
              for (var key in icons.keys)
                Positioned(
                  left: key[0].toDouble(),
                  top: key[1].toDouble(),
                  child: IconActions.getIcon(icons[key]!),
                ),
            ],
          )),
    );
  }

  Widget buildList({bool isMatch = false}) {
    return Column(
      children: [
        Container(
          // Set max height to 25% of the screen height or 500 pixels, whichever is smaller.
          height: math.min(MediaQuery.of(context).size.height * 0.25, 500),

          // Set max width to 90% of the screen width or 700 pixels, whichever is smaller.
          width: math.min(MediaQuery.of(context).size.width * 0.9, 700),

          child: ListView.builder(
            itemCount: icons.length,
            itemBuilder: (context, index) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ]),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: IconActions.getIcon(icons.values.elementAt(index)),
                    title: Text(iconsComments.values.elementAt(index).text,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        )),
                    // Add delete button
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          icons.remove(icons.keys.elementAt(index));
                          iconsComments
                              .remove(iconsComments.keys.elementAt(index));
                        });

                        if (isMatch) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    subtitle: Text(
                        "(${icons.keys.elementAt(index)[0]}, ${icons.keys.elementAt(index)[1]})"),

                    // Add comments
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Comments'),
                            content: TextField(
                              controller: iconsComments.values.elementAt(index),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Comments',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  // Close keyboard
                                  FocusScope.of(context).unfocus();

                                  // Update the list
                                  setState(() {});

                                  // If in match - close the dialog
                                  if (isMatch) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Add comment'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Remove all button
        if (icons.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                icons.clear();
                iconsComments.clear();
                gameElements = 0;
              });

              if (isMatch) {
                Navigator.pop(context);
              }
            },
            child:
                const Text('Remove all', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  bool isComplete() {
    log("ICONS:");
    for (var icon in icons.entries) {
      log("Icon: ${icon.key} - ${icon.value}");
    }

    log("---");

    bool isComplete = (icons.containsValue(IconActions.START_POS) &&
        icons.containsValue(IconActions.PARK));
    log("Is complete: ${isComplete.toString()}");
    return isComplete;
  }
}
