import 'package:flutter/material.dart';
import "package:sudoku_solver/sudoku_grid.dart";
import "package:sudoku_solver/styles.dart" as styles;

void main() {
  runApp(const MyApp());
}

// to do
// show error when trying to solve a invalid grid
// show message after solving informing whether a valid solution was found or not
// create a slider to control the speed at which the sudoku is solved
// add a clear icon to clear sudoku button
// maybe add a lightbulb icon to solve sudoku button
// add animations
// make sudoku grid zoomable
// add support for any n*n sudoku grid and add a slider to control that n

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sudoku Solver",
      home: HomePage(),
      theme: styles.app_theme,
    );
  }
}

class HomePage extends StatelessWidget {
  final SudokuGrid sudoku_grid = SudokuGrid();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    styles.create_styles(Theme.of(
        context)); // because this is a stateless widget this line will be executed only once
    return Scaffold(
      backgroundColor: styles.background_color,
      appBar: AppBar(
        title: Text(
          "Sudoku Solver",
          style: styles.title_text_style,
        ),
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: styles.container_color,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: styles.button_style,
                    onPressed: () {
                      sudoku_grid.clear_grid();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Clear Sudoku",
                        style: styles.body_text_style,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: styles.button_style,
                    onPressed: () {
                      sudoku_grid.start_solving_sudoku();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Solve Sudoku",
                        style: styles.body_text_style,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          sudoku_grid,
        ],
      ),
    );
  }
}
