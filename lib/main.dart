//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_sudoku/sudoku_dart.dart';
import 'domains/sudoku/SudokuProblem.dart';
import 'domains/sudoku/SudokuState.dart';
import 'dart:ui';

import 'framework/problem/SolvingAssistant.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LettuceSudoku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'FiraCode',
      ),
      home: MyHomePage(title: 'LettuceSudoku'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SudokuProblem problem = SudokuProblem();
  GridView board;
  List button_grid;
  bool cell_selected = false;
  var menuHeight = 70;
  int selectedRow = 0;
  int selectedCol = 0;
  SolvingAssistant assistant;

  void _resetBoard() {
    problem = SudokuProblem();
    cell_selected = false;
    setState(() {});
  }

  double getConstraint() {
    var padding = MediaQuery.of(context).padding;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height - padding.top - padding.bottom - menuHeight;
    var constraint = width <= height ? width : height;
    return constraint;
  }

  EdgeInsets getBoardPadding(int index) {
    int row = index ~/ problem.board_size;
    int col = index % problem.board_size;

    double thickness = 2;
    double defaultThickness = 0.5;
    double right = defaultThickness;
    double top = defaultThickness;
    double left = defaultThickness;
    double bottom = defaultThickness;

    if(row == 0) {
      top = thickness;
    }
    if(col == 0) {
      left = thickness;
    }
    if(row % problem.cell_size == problem.cell_size - 1) {
      bottom = thickness;
    }
    if(col % problem.cell_size == problem.cell_size - 1) {
      right = thickness;
    }

    return EdgeInsets.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
  }

  void _doMove(int num, int row, int col) {
    assistant = SolvingAssistant(problem);
    if (!problem.success()) {
      var move = 'Place ' +
          num.toString() +
          ' at ' +
          row.toString() +
          ' ' +
          col.toString();
      assistant.tryMove(move);
    }
  }

  void _solveGame(SudokuProblem problem) {
    cell_size = problem.cell_size;
    board_size = problem.board_size;
    for (var i = 0; i < board_size; i++) {
      for (var j = 0; j < board_size; j++) {
        for (var k = 1; k <= board_size; k++) {
          if (!problem.isCorrect(i, j)) {
            _doMove(k, i, j);
            if (problem.isCorrect(i, j)) {
              break;
            }
          }
        }
      }
    }
  }

  Color _getColor(int row, int col) {
    Color color;
    if (cell_selected == null) {
      cell_selected = false;
    }
    if(cell_selected) {
      if(row == selectedRow || col == selectedCol) {
        color = Colors.deepOrange;
      }
      if(row ~/ problem.cell_size == selectedRow ~/ problem.cell_size && col ~/ problem.cell_size == selectedCol ~/ problem.cell_size) {
        color = Colors.deepOrange;
      }
      if(row == selectedRow && col == selectedCol) {
        color = Colors.white;
      }
    }
    else {
      color = Colors.white;
    }
    if(problem.success()) {
      color = Colors.deepOrange;
    }
    return color;
  }

  Widget _makeBoardButton(int index, SudokuProblem problem) {
    var row = index ~/ problem.board_size;
    var col = index % problem.board_size;
    SudokuState currentState = problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    var cellNum = currentBoard[row][col];
    String toPlace = cellNum == 0 ? '' : cellNum.toString();

    Ink button = Ink(
      padding: getBoardPadding(index),
      child: Material(
        color: _getColor(row, col),
        child: InkWell(
          splashColor: Colors.deepOrange,
          hoverColor: Colors.red,
          onTap: () {
            selectedRow = row;
            selectedCol = col;
            cell_selected = true;
            setState(() {
            });
          },
          child: Center(
            child: AutoSizeText(
              toPlace,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'FiraCode-Bold',
                fontSize: 40,
              ),
            ),
          ),
        ),
      ),
    );

    return button;
  }

  @override
  Widget build(BuildContext context) {
    if(problem == null) {
      problem = SudokuProblem();
    }

    if(button_grid == null) {
      button_grid = List();
    }

//    board = _getBoard();

    return Scaffold(
      appBar: AppBar(
        leading: Container(
//          child: Material(
            child: InkWell(
//              splashColor: Colors.deepOrange,
              child: Container(
                height: 30,
                width: 30,
                child: Icon(Icons.menu, color: Colors.white, size: 30),
              ),
              onTap: () {
                _solveGame(problem);
                setState(() {});
              },
            ),
//          ),
        ),
        title: Text(
          'LettuceSudoku',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'FiraCode-Bold',
            fontSize: 26,
          ),
        ),
      ),
      body: _getBody(),
    );
  }

  Widget _getBoard() {
    AspectRatio board = AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.black,
        child: GridView.count(
            padding: EdgeInsets.all(1),
            crossAxisCount: problem.board_size,
            childAspectRatio: 1,
            children: List.generate(problem.board_size * problem.board_size, (index) {
              Ink button = _makeBoardButton(index, problem);
              button_grid.add(button);
              return button;
            })
        ),
      ),
    );
    return board;
  }

  Widget _getMoveButtons(double aspect) {
    var buttons =
//    Flex(
//      direction: Axis.horizontal,
//        children: <Widget>[
//          Flexible(
//            flex: 4,
//            child:
            GridView.count(
              padding: EdgeInsets.all(1),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: aspect,
              children: List.generate(9, (index) {
                int num = (index + 1) % (problem.board_size + 1);
                String toPlace = num == 0 ? 'X' : (index + 1).toString();
                Container button = Container(
                  height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom / 5,
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        _doMove(num, selectedRow, selectedCol);
                        setState(() {});
                      },
                      child: Center(
                        child: AutoSizeText(
                          toPlace,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'FiraCode-Bold',
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                button_grid.add(button);
                return button;
              }),
//            ),
//          ),
//        ],
      );
    return buttons;
  }

  Widget _getBody() {
    final _focusNode = FocusNode();
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var body = Container(
      height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
      width: MediaQuery.of(context).size.width,
      child: isPortrait ? _makeBoardCol() : _makeBoardRow(),
    );
    return body;
  }

  Widget _makeBoardCol() {
    Column col = Column (
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible( // board
          flex: 4,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(4),
              child: Container(
                color: Colors.black,
                child: _getBoard(),
              ),
            ),
          ),
        ),
        Flexible( // move buttons
          flex: 3,
          child: Container(
            child: _getMoveButtons(1.5),
          ),
        ),
      ],
    );
    return col;
  }

  Widget _makeBoardRow() {
    Row row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
//        Flexible( // spacer
//          flex: 2,
//          child: Material(
//            child: InkWell(
////              onTap: () {},
//              splashColor: Colors.deepOrange,
//            ),
//          ),
//        ),
        Flexible( // board
          flex: 4,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(4),
              child: Container(
                color: Colors.black,
                child: _getBoard(),
              ),
            ),
          ),
        ),
        Flexible( // move buttons
          flex: 4,
          child: Container(
            height: getConstraint(),
            width: getConstraint(),
            padding: EdgeInsets.all(4),
            child: _getMoveButtons(1),
          ),
        ),
//
//        Flexible( // move buttons
//          flex: 2,
//          child: Material(
////                color: Colors.blue,
//            child: InkWell(
////              onTap: () {},
//              splashColor: Colors.deepOrange,
//            ),
//          ),
//        ),
      ],
    );
    return row;
  }
}