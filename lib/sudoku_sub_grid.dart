import 'package:flutter/material.dart';
import "package:sudoku_solver/sudoku_cell.dart";

class SudokuSubGrid extends StatelessWidget {
  final int my_size;
  final void Function({required int cell_x, required int cell_y})
      check_collision_of_cell_in_sub_grid_callback;
  final List<List<SudokuCellController>> sudoku_cell_controllers = [];

  SudokuSubGrid({
    super.key,
    required this.my_size,
    required this.check_collision_of_cell_in_sub_grid_callback,
  }) {
    for (int y = 0; y < my_size; y += 1) {
      sudoku_cell_controllers.add([]);
      for (int x = 0; x < my_size; x += 1) {
        sudoku_cell_controllers[y].add(SudokuCellController());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          for (int cell_y = 0; cell_y < my_size; cell_y += 1)
            TableRow(
              children: [
                for (int cell_x = 0; cell_x < my_size; cell_x += 1)
                  SudokuCell(
                      sudoku_cell_controller: sudoku_cell_controllers[cell_y]
                          [cell_x],
                      check_collision_of_cell_callback: () {
                        check_collision_of_cell_in_sub_grid_callback(
                            cell_x: cell_x, cell_y: cell_y);
                      })
              ],
            )
        ],
      ),
    );
  }

  void clear_sub_grid() {
    for (int y = 0; y < my_size; y += 1) {
      for (int x = 0; x < my_size; x += 1) {
        sudoku_cell_controllers[y][x].clear_cell();
      }
    }
  }

  void disable_input() {
    for (int y = 0; y < my_size; y += 1) {
      for (int x = 0; x < my_size; x += 1) {
        sudoku_cell_controllers[y][x].disable_input();
      }
    }
  }

  void enable_input() {
    for (int y = 0; y < my_size; y += 1) {
      for (int x = 0; x < my_size; x += 1) {
        sudoku_cell_controllers[y][x].enable_input();
      }
    }
  }

  bool are_all_cells_valid() {
    for (int y = 0; y < my_size; y += 1) {
      for (int x = 0; x < my_size; x += 1) {
        if (!sudoku_cell_controllers[y][x].is_cell_valid()) {
          return false;
        }
      }
    }
    return true;
  }

  SudokuCellController get_cell_controller(
      {required int cell_x, required int cell_y}) {
    return sudoku_cell_controllers[cell_y][cell_x];
  }

  List<SudokuCellController> get_all_cell_controllers() {
    List<SudokuCellController> all_cell_controllers = [];
    for (int y = 0; y < my_size; y += 1) {
      all_cell_controllers += sudoku_cell_controllers[y];
    }
    return all_cell_controllers;
  }

  List<SudokuCellController> get_all_cell_controllers_except(
      {required int cell_x, required int cell_y}) {
    List<SudokuCellController> cell_controllers = [];
    for (int y = 0; y < my_size; y += 1) {
      for (int x = 0; x < my_size; x += 1) {
        if (!((cell_x == x) && (cell_y == y))) {
          cell_controllers.add(sudoku_cell_controllers[y][x]);
        }
      }
    }
    return cell_controllers;
  }

  List<SudokuCellController> get_all_cell_controllers_in_row(
      {required int row_index}) {
    return sudoku_cell_controllers[row_index];
  }

  List<SudokuCellController> get_all_cell_controllers_in_column(
      {required int column_index}) {
    List<SudokuCellController> cell_controllers_in_column = [];
    for (int y = 0; y < my_size; y += 1) {
      cell_controllers_in_column.add(sudoku_cell_controllers[y][column_index]);
    }
    return cell_controllers_in_column;
  }
}
