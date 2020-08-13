import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lettuce_sudoku/util/globals.dart' as globals;

Future<bool> readFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  // final legality = prefs.getBool('doLegality');
  final peerCells = prefs.getBool('doPeerCells');
  final peerDigits = prefs.getBool('doPeerDigits');
  final mistakes = prefs.getBool('doMistakes');
  final hints = prefs.getInt('initialHints');
  final legality = prefs.getInt('legalityRadio');
  globals.doPeerCells.value = peerCells != null ? peerCells : true;
  globals.doPeerDigits.value = peerDigits != null ? peerDigits : true;
  globals.doMistakes.value = mistakes != null ? mistakes : true;
  globals.initialHints.value = hints != null ? hints : 30;
  globals.legalityRadio.value = legality == 1 || legality == 0 ? legality : 0;
  return true;
}

saveGame() async {
  final prefs = await SharedPreferences.getInstance();
  String initialString = "";
  String currentString = "";
  String finalString = "";
  SudokuState initialState = globals.problem.getInitialState();
  List initialBoard = initialState.getTiles();
  SudokuState currentState = globals.problem.getCurrentState();
  List currentBoard = currentState.getTiles();
  SudokuState finalState = globals.problem.getFinalState();
  List finalBoard = finalState.getTiles();

  for (int i = 0; i < globals.problem.board_size; i++) {
    for (int j = 0; j < globals.problem.board_size; j++) {
      initialString += initialBoard[i][j].toString();
      currentString += currentBoard[i][j].toString();
      finalString += finalBoard[i][j].toString();
    }
  }

  String hintString = '';
  for (var i = 0; i < globals.hintsGiven.length; i++) {
    hintString += globals.hintsGiven[i][0].toString();
    hintString += globals.hintsGiven[i][1].toString();
  }

  prefs.setString('initialBoard', initialString);
  prefs.setString('currentBoard', currentString);
  prefs.setString('finalBoard', finalString);
  prefs.setString('hintsGiven', hintString);
}

Future<bool> applyGameState() async {
  final prefs = await SharedPreferences.getInstance();
  final initialString = prefs.getString('initialBoard');
  final currentString = prefs.getString('currentBoard');
  final finalString = prefs.getString('finalBoard');
  final hintString = prefs.getString('hintsGiven');
  // SudokuProblem problem;
  List initialBoard = List.generate(9, (i) => List(9), growable: false);
  List currentBoard = List.generate(9, (i) => List(9), growable: false);
  List finalBoard = List.generate(9, (i) => List(9), growable: false);
  if (initialString != null && currentString != null && finalString != null) {
    for (int i = 0; i < initialString.length; i++) {
      initialBoard[i ~/ 9][i % 9] = int.parse(initialString[i]);
      currentBoard[i ~/ 9][i % 9] = int.parse(currentString[i]);
      finalBoard[i ~/ 9][i % 9] = int.parse(finalString[i]);
    }
    globals.problem =
        SudokuProblem.resume(initialBoard, currentBoard, finalBoard);
  } else {
    globals.problem =
        SudokuProblem.withMoreHints(globals.initialHints.value - 17);
  }

  globals.hintsGiven.clear();
  for (var i = 0; i < hintString.length ~/ 2; i++) {
    int row = int.parse(hintString[i * 2]);
    int col = int.parse(hintString[i * 2 + 1]);
    globals.hintsGiven.add([row, col]);
  }

  return true;
}

MaterialColor getMaterialColor(Color color) {
  int colorInt = color.value;
  return MaterialColor(colorInt, <int, Color>{
    50: color,
    100: color,
    200: color,
    300: color,
    400: color,
    500: color,
    600: color,
    700: color,
    800: color,
    900: color,
  });
}