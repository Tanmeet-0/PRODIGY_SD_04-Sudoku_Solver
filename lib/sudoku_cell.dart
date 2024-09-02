import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import "package:sudoku_solver/styles.dart" as styles;

class SudokuCell extends StatefulWidget {
  const SudokuCell(
      {super.key,
      required this.sudoku_cell_controller,
      required this.check_collision_of_cell_callback});
  final SudokuCellController sudoku_cell_controller;
  final void Function() check_collision_of_cell_callback;
  @override
  State<SudokuCell> createState() => _SudokuCellState();
}

class _SudokuCellState extends State<SudokuCell> {
  late final TextEditingController text_editing_controller;
  FocusNode? f;
  bool _is_input_enabled = true;
  bool _is_cell_valid = true;
  bool _is_cell_pre_filled = false;
  List<SudokuCellController> cell_controllers_of_colliding_neighbours = [];
  // colliding neighbours means the neighbours which have the same value as the cell
  // neighbours include
  // all the other cells in the same sub grid as the cell
  // all the other cells in the same row and column as the cell

  @override
  void initState() {
    super.initState();
    initialize_my_controller();
    text_editing_controller = TextEditingController();
    f = FocusNode();
  }

  @override
  void dispose() {
    text_editing_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var container_color = styles.container_color;
    var text_style = styles.body_text_style;
    var cursor_color = styles.all_text_color;
    if (!_is_cell_valid) {
      container_color = styles.invalid_cell_container_color;
      text_style = styles.invalid_cell_text_style;
      cursor_color = styles.invalid_cell_color;
    }
    if (_is_cell_pre_filled) {
      // this will only be executed when
      // cell has some value
      // AND input is disabled
      // AND sudoku is currently being solved
      // this text style highlights the cell which were pre filled while the sudoku is being solved
      text_style = styles.pre_filled_cell_text_style;
    }
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: container_color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: styles.container_border_color, width: 2),
        ),
        width: 52,
        child: TextField(
          enabled: _is_input_enabled,
          controller: text_editing_controller,
          focusNode: f,
          textAlign: TextAlign.center,
          style: text_style,
          cursorColor: cursor_color,
          decoration: InputDecoration(border: InputBorder.none),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"^[1-9]{1}"))
          ],
          onChanged: (cell_value) {
            widget.check_collision_of_cell_callback();
          },
        ),
      ),
    );
  }

  void initialize_my_controller() {
    widget.sudoku_cell_controller.get_value = get_value;
    widget.sudoku_cell_controller.set_value = set_value;
    widget.sudoku_cell_controller.clear_cell = clear_cell;
    widget.sudoku_cell_controller.disable_input = disable_input;
    widget.sudoku_cell_controller.enable_input = enable_input;
    widget.sudoku_cell_controller.is_cell_valid = is_cell_valid;
    widget.sudoku_cell_controller.is_cell_pre_filled = is_cell_pre_filled;
    widget.sudoku_cell_controller.add_colliding_neighbour =
        add_colliding_neighbour;
    widget.sudoku_cell_controller.remove_colliding_neighbour =
        remove_colliding_neighbour;
    widget.sudoku_cell_controller.remove_all_colliding_neighbours =
        remove_all_colliding_neighbours;
    widget.sudoku_cell_controller.initialized = true;
  }

  String get_value() {
    return text_editing_controller.text;
  }

  void set_value({required String cell_value}) {
    text_editing_controller.text = cell_value;
    widget.check_collision_of_cell_callback();
  }

  void clear_cell() {
    text_editing_controller.clear();
    remove_all_colliding_neighbours();
  }

  void disable_input() {
    setState(() {
      _is_input_enabled = false;
      // after input is disabled remember the cells which are filled
      _is_cell_pre_filled = get_value().isNotEmpty;
    });
  }

  void enable_input() {
    setState(() {
      _is_input_enabled = true;
      // if input is enabled then cell is in editing mode so it cannot be prefilled
      _is_cell_pre_filled = false;
    });
  }

  bool is_cell_valid() {
    return _is_cell_valid;
  }

  bool is_cell_pre_filled() {
    return _is_cell_pre_filled;
  }

  void add_colliding_neighbour(
      {required SudokuCellController cell_controller_of_neighbour}) {
    cell_controllers_of_colliding_neighbours.add(cell_controller_of_neighbour);
    if (cell_controllers_of_colliding_neighbours.length == 1) {
      // when the first colliding neighbour is added, the cell becomes invalid
      // when more colliding neighbours are added, the cell remains invalid
      setState(() {
        _is_cell_valid = false;
      });
    }
  }

  void remove_colliding_neighbour(
      {required SudokuCellController cell_controller_of_neighbour}) {
    cell_controllers_of_colliding_neighbours
        .remove(cell_controller_of_neighbour);
    if (cell_controllers_of_colliding_neighbours.isEmpty) {
      // there are no colliding neighbours, the cell becomes valid
      setState(() {
        _is_cell_valid = true;
      });
    }
  }

  void remove_all_colliding_neighbours() {
    for (var cell_controller_of_neighbour
        in cell_controllers_of_colliding_neighbours) {
      cell_controller_of_neighbour.remove_colliding_neighbour(
          cell_controller_of_neighbour: widget.sudoku_cell_controller);
    }
    cell_controllers_of_colliding_neighbours.clear();
    // there are no colliding neighbours, the cell becomes valid
    setState(() {
      _is_cell_valid = true;
    });
  }
}

class SudokuCellController {
  bool initialized = false;
  late String Function() get_value;
  late void Function({required String cell_value}) set_value;
  late VoidCallback clear_cell;
  late VoidCallback disable_input;
  late VoidCallback enable_input;
  late bool Function() is_cell_valid;
  late bool Function() is_cell_pre_filled;
  late void Function(
          {required SudokuCellController cell_controller_of_neighbour})
      add_colliding_neighbour;
  late void Function(
          {required SudokuCellController cell_controller_of_neighbour})
      remove_colliding_neighbour;
  late VoidCallback remove_all_colliding_neighbours;
}
