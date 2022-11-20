import 'package:dark_todo/app/data/schema.dart';
import 'package:dark_todo/app/widgets/todos_ce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class TodosList extends StatefulWidget {
  const TodosList({
    super.key,
    required this.isLoaded,
    required this.todos,
    required this.deleteTodo,
    required this.getTodo,
    required this.toggleValue,
  });
  final bool isLoaded;
  final int toggleValue;
  final List<Todos> todos;
  final Function(Object) deleteTodo;
  final Function() getTodo;

  @override
  State<TodosList> createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  late TextEditingController titleTodoEdit;
  late TextEditingController descTodoEdit;
  late TextEditingController timeTodoEdit;

  updateTodoCheck(todo) async {
    await isar.writeTxn(() async => isar.todos.put(todo));
    widget.getTodo();
  }

  updateTodo(todo) async {
    await isar.writeTxn(() async {
      todo.name = titleTodoEdit.text;
      todo.description = descTodoEdit.text;
      todo.todoCompletedTime = DateTime.tryParse(timeTodoEdit.text);
      await isar.todos.put(todo);
    });
    EasyLoading.showSuccess('Задача изменена',
        duration: const Duration(milliseconds: 500));
    widget.getTodo();
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      <MaterialState>{
        MaterialState.pressed,
      };
      return Colors.black;
    }

    return Expanded(
      child: Visibility(
        visible: widget.isLoaded,
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
        child: Visibility(
          visible: widget.todos.isNotEmpty,
          replacement: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/AddTasks.png',
                    scale: 5,
                  ),
                  Text(
                    widget.toggleValue == 0
                        ? 'Добавьте задачу'
                        : 'Выполните задачу',
                    style: context.theme.textTheme.headline4?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: widget.todos.length,
            itemBuilder: (BuildContext context, int index) {
              final todo = widget.todos[index];
              return Dismissible(
                key: ObjectKey(todo),
                direction: DismissDirection.endToStart,
                confirmDismiss: (DismissDirection direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: context.theme.primaryColor,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        title: Text(
                          "Удаление задачи",
                          style: context.theme.textTheme.headline4,
                        ),
                        content: Text("Вы уверены что хотите удалить задачу?",
                            style: context.theme.textTheme.headline6),
                        actions: [
                          TextButton(
                              onPressed: () => Get.back(result: true),
                              child: Text("Удалить",
                                  style: context.theme.textTheme.headline6
                                      ?.copyWith(color: Colors.red))),
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text("Отмена",
                                style: context.theme.textTheme.headline6
                                    ?.copyWith(color: Colors.blueAccent)),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (DismissDirection direction) {
                  widget.deleteTodo(todo);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(
                      right: 15,
                    ),
                    child: Icon(
                      Iconsax.trush_square,
                      color: Colors.red,
                    ),
                  ),
                ),
                child: Container(
                  margin:
                      const EdgeInsets.only(right: 20, left: 20, bottom: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // color: Colors.white,
                  ),
                  child: CupertinoButton(
                    minSize: double.minPositive,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showModalBottomSheet(
                        enableDrag: false,
                        backgroundColor: context.theme.scaffoldBackgroundColor,
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext context) {
                          titleTodoEdit =
                              TextEditingController(text: todo.name);
                          descTodoEdit =
                              TextEditingController(text: todo.description);
                          timeTodoEdit = TextEditingController(
                              text: todo.todoCompletedTime != null
                                  ? todo.todoCompletedTime.toString()
                                  : '');
                          return TodosCe(
                            text: 'Редактирование',
                            save: () {
                              updateTodo(todo);
                            },
                            titleEdit: titleTodoEdit,
                            descEdit: descTodoEdit,
                            timeEdit: timeTodoEdit,
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    MaterialStateProperty.resolveWith(getColor),
                                value: todo.done,
                                shape: const CircleBorder(),
                                onChanged: (val) {
                                  setState(() {
                                    todo.done = val!;
                                  });
                                  todo.done = val!;
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    updateTodoCheck(todo);
                                  });
                                },
                              ),
                              Expanded(
                                child: todo.description.isNotEmpty
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              todo.name,
                                              style: context
                                                  .theme.textTheme.headline4
                                                  ?.copyWith(
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              todo.description,
                                              style: context
                                                  .theme.textTheme.subtitle2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(
                                        todo.name,
                                        style: context.theme.textTheme.headline4
                                            ?.copyWith(
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          todo.todoCompletedTime != null
                              ? '${todo.todoCompletedTime?.hour.toString().padLeft(2, '0')}:${todo.todoCompletedTime?.minute.toString().padLeft(2, '0')}\n${todo.todoCompletedTime?.day.toString().padLeft(2, '0')}/${todo.todoCompletedTime?.month.toString().padLeft(2, '0')}/${todo.todoCompletedTime?.year.toString().substring(2)} '
                              : '',
                          style: context.theme.textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
