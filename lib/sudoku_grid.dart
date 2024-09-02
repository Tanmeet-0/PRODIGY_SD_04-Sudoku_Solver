import 'package:flutter/material.dart';
import "dart:async";
import "package:sudoku_solver/sudoku_sub_grid.dart";
import "package:sudoku_solver/sudoku_cell.dart";
import "package:sudoku_solver/styles.dart" as styles;

class SudokuGrid extends StatelessWidget {
  final int sub_grid_size;
  final List<List<SudokuSubGrid>> sudoku_sub_grids = [];
  bool is_currently_solving = false;
  _SudokuGridSolver? sudoku_solver;
  final time_between_each_solve_sudoku_step_in_milliseconds =
      100; // 1000 milliseconds = 1 second
  SudokuGrid({super.key, this.sub_grid_size = 3}) {
    for (int sub_grid_y = 0; sub_grid_y < sub_grid_size; sub_grid_y += 1) {
      sudoku_sub_grids.add([]);
      for (int sub_grid_x = 0; sub_grid_x < sub_grid_size; sub_grid_x += 1) {
        sudoku_sub_grids[sub_grid_y].add(
          SudokuSubGrid(
            my_size: sub_grid_size,
            check_collision_of_cell_in_sub_grid_callback: (
                {required int cell_x, required int cell_y}) {
              check_collision_of_cell_in_sub_grid(
                  sub_grid_x, sub_grid_y, cell_x, cell_y);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: styles.container_border_color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        //border: TableBorder.all(width: 7, color: styles.container_border_color,borderRadius: BorderRadius.circular(10)),
        border: TableBorder.symmetric(
          inside: BorderSide(width: 6, color: styles.container_border_color),
          outside: BorderSide(width: 3,color: styles.container_border_color),
          borderRadius: BorderRadius.circular(10),
        ),
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          for (int y = 0; y < sub_grid_size; y += 1)
            TableRow(
              children: [
                for (int x = 0; x < sub_grid_size; x += 1)
                  sudoku_sub_grids[y][x]
              ],
            )
        ],
      ),
    );
  }

  void start_solving_sudoku() {
    if (!is_currently_solving) {
      // only start solving sudoku if the sudoku is not currently being solved
      disable_input();
      if (are_all_cells_in_all_sub_grids_valid()) {
        // if there are no collisions among all the cells, then start solving the sudoku
        int min_cell_value = 1;
        int max_cell_value = sub_grid_size * sub_grid_size;
        sudoku_solver = _SudokuGridSolver(
          all_cell_controllers: get_all_cell_controllers_in_all_sub_grids(),
          min_cell_value: min_cell_value,
          max_cell_value: max_cell_value,
        );
        is_currently_solving = true;
        Timer.periodic(
          Duration(
              milliseconds:
                  time_between_each_solve_sudoku_step_in_milliseconds),
          (timer) {
            if (!is_currently_solving) {
              timer.cancel();
            }
            solve_sudoku_next_step();
          },
        );
      } else {
        enable_input();
      }
    }
  }

  void solve_sudoku_next_step() {
    if (is_currently_solving) {
      // if is_currently_solving is true then sudoku_solver cannot be null
      if (!(sudoku_solver!.completed)) {
        var current_cell_value_brute_forcer =
            sudoku_solver!.get_current_cell_value_brute_forcer();
        if (current_cell_value_brute_forcer.has_tried_all_possible_values) {
          // either this is a new cell or a cell that is being revisited after changing something in the previous cells
          // in both cases we need to restart it
          current_cell_value_brute_forcer.start_new_attempt();
        }
        // it is also possible that a correct value was found for a cell
        // but then it was revisited because another cell after it did not have a correct value
        // in that case just try the next possible value for the cell
        if (current_cell_value_brute_forcer.try_next_value()) {
          // if a value for this cell has been found then go to next cell
          sudoku_solver!.next_cell_value_brute_forcer();
        } else if (current_cell_value_brute_forcer
            .has_tried_all_possible_values) {
          // if all values for this cell has been tried then go to a previous cell and change it
          sudoku_solver!.previous_cell_value_brute_forcer();
        }
      } else {
        is_currently_solving = false;
        sudoku_solver = null;
        enable_input();
      }
    }
  }

  void clear_grid() {
    if (!is_currently_solving) {
      // don't clear the grid while solving
      for (int y = 0; y < sub_grid_size; y += 1) {
        for (int x = 0; x < sub_grid_size; x += 1) {
          sudoku_sub_grids[y][x].clear_sub_grid();
        }
      }
    }
  }

  void disable_input() {
    for (int y = 0; y < sub_grid_size; y += 1) {
      for (int x = 0; x < sub_grid_size; x += 1) {
        sudoku_sub_grids[y][x].disable_input();
      }
    }
  }

  void enable_input() {
    for (int y = 0; y < sub_grid_size; y += 1) {
      for (int x = 0; x < sub_grid_size; x += 1) {
        sudoku_sub_grids[y][x].enable_input();
      }
    }
  }

  bool are_all_cells_in_all_sub_grids_valid() {
    for (int y = 0; y < sub_grid_size; y += 1) {
      for (int x = 0; x < sub_grid_size; x += 1) {
        if (!sudoku_sub_grids[y][x].are_all_cells_valid()) {
          return false;
        }
      }
    }
    return true;
  }

  void check_collision_of_cell_in_sub_grid(
      int sub_grid_x, int sub_grid_y, int cell_x, int cell_y) {
    var cell_controller = sudoku_sub_grids[sub_grid_y][sub_grid_x]
        .get_cell_controller(cell_x: cell_x, cell_y: cell_y);
    cell_controller.remove_all_colliding_neighbours();
    // remove any existing colliding neighbours because they are being recalculated below
    var cell_value = cell_controller.get_value();
    if (cell_value.isNotEmpty) {
      // cell has value, need to check collisions
      var cell_controllers_of_neighbours =
          get_cell_controllers_of_neighbours_of_cell_in_sub_grid(
              sub_grid_x, sub_grid_y, cell_x, cell_y);
      for (var cell_controller_of_neighbour in cell_controllers_of_neighbours) {
        if (cell_value == cell_controller_of_neighbour.get_value()) {
          cell_controller.add_colliding_neighbour(
              cell_controller_of_neighbour: cell_controller_of_neighbour);
          cell_controller_of_neighbour.add_colliding_neighbour(
              cell_controller_of_neighbour: cell_controller);
        }
      }
    }
  }

  List<SudokuCellController>
      get_cell_controllers_of_neighbours_of_cell_in_sub_grid(
          int sub_grid_x, int sub_grid_y, int cell_x, int cell_y) {
    // neighbours means all the cells affected by the given cell
    // which includes
    // all the other cells in the sub grid of the cell
    // all the other cells in the same row and column as the given cell
    List<SudokuCellController> cell_controllers_of_neighbours = [];
    cell_controllers_of_neighbours += sudoku_sub_grids[sub_grid_y][sub_grid_x]
        .get_all_cell_controllers_except(cell_x: cell_x, cell_y: cell_y);
    for (int neighbour_sub_grid_y = 0;
        neighbour_sub_grid_y < sub_grid_size;
        neighbour_sub_grid_y += 1) {
      if (neighbour_sub_grid_y != sub_grid_y) {
        cell_controllers_of_neighbours += sudoku_sub_grids[neighbour_sub_grid_y]
                [sub_grid_x]
            .get_all_cell_controllers_in_column(column_index: cell_x);
      }
    }
    for (int neighbour_sub_grid_x = 0;
        neighbour_sub_grid_x < sub_grid_size;
        neighbour_sub_grid_x += 1) {
      if (neighbour_sub_grid_x != sub_grid_x) {
        cell_controllers_of_neighbours += sudoku_sub_grids[sub_grid_y]
                [neighbour_sub_grid_x]
            .get_all_cell_controllers_in_row(row_index: cell_y);
      }
    }
    return cell_controllers_of_neighbours;
  }

  List<SudokuCellController> get_all_cell_controllers_in_all_sub_grids() {
    List<SudokuCellController> all_cell_controllers = [];
    for (int y = 0; y < sub_grid_size; y += 1) {
      for (int x = 0; x < sub_grid_size; x += 1) {
        all_cell_controllers +=
            sudoku_sub_grids[y][x].get_all_cell_controllers();
      }
    }
    return all_cell_controllers;
  }
}

class _SudokuGridSolver {
  final List<_SudokuCellValueBruteForcer> cell_value_brute_forcers = [];
  int cell_value_brute_forcers_index = 0;
  bool completed = false;
  bool solution_found = false;
  _SudokuGridSolver({
    required List<SudokuCellController> all_cell_controllers,
    required int min_cell_value,
    required int max_cell_value,
  }) {
    for (var cell_controller in all_cell_controllers) {
      if (!cell_controller.is_cell_pre_filled()) {
        // only need to find values of those cells which are not filled
        cell_value_brute_forcers.add(_SudokuCellValueBruteForcer(
          cell_controller: cell_controller,
          min_cell_value: min_cell_value,
          max_cell_value: max_cell_value,
        ));
      }
    }
    if (cell_value_brute_forcers.isEmpty) {
      // all the cells were already filled, so the solution has been found
      solution_found = true;
      completed = true;
    }
  }

  _SudokuCellValueBruteForcer get_current_cell_value_brute_forcer() {
    return cell_value_brute_forcers[cell_value_brute_forcers_index];
  }

  void next_cell_value_brute_forcer() {
    cell_value_brute_forcers_index += 1;
    if (cell_value_brute_forcers_index >= cell_value_brute_forcers.length) {
      // if a next cell does not exist that means that all the cells have been filled
      // so a solution is found
      solution_found = true;
      completed = true;
    }
  }

  void previous_cell_value_brute_forcer() {
    cell_value_brute_forcers_index -= 1;
    if (cell_value_brute_forcers_index < 0) {
      // if a previous does not exist that means that means all possibilities for cells have been tried and none of them are valid
      // so a solution is not found
      solution_found = false;
      completed = true;
    }
  }
}

class _SudokuCellValueBruteForcer {
  final SudokuCellController cell_controller;
  int min_cell_value; // inclusive
  int max_cell_value; // inclusive
  late int current_value;
  bool has_tried_all_possible_values = true;
  _SudokuCellValueBruteForcer({
    required this.cell_controller,
    required this.min_cell_value,
    required this.max_cell_value,
  });

  void start_new_attempt() {
    // prepare to find a valid value for cell using brute force
    current_value = min_cell_value;
    has_tried_all_possible_values = false;
  }

  bool try_next_value() {
    // returns whether the tried value was valid or not
    if (current_value <= max_cell_value) {
      cell_controller.set_value(cell_value: current_value.toString());
      current_value += 1;
      if (cell_controller.is_cell_valid()) {
        return true;
      }
      return false;
    } else {
      // all the possibilities for this cell has been tried and none of them are valid
      // so clear the cell
      cell_controller.clear_cell();
      has_tried_all_possible_values = true;
      return false;
    }
  }
}
