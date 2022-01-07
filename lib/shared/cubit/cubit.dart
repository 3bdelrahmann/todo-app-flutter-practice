import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<States> {
  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  int index = 1;

  List<Widget> screens = [
    ArchivedTasksScreen(),
    NewTasksScreen(),
    DoneTasksScreen(),
  ];

  List<String> titles = [
    'Archived Tasks',
    'New Tasks',
    'Done Tasks',
  ];

  void changeIndex(int index) {
    this.index = index;
    getDataFromDatabase(database);
    emit(AppChangeBotNavBarState());
  }

  Database? database;
  List<Map> archivedTasks = [];
  List<Map> newTasks = [];
  List<Map> doneTasks = [];

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      print('Database created');
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, desc TEXT, date TEXT, status TEXT, creationDay TEXT, creationMonth TEXT)')
          .then((value) => print('Table created'))
          .catchError((error) {
        print('Error happened when creating table ${error.toString()}');
      });
    }, onOpen: (database) {
      print('Database opened');
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      getDataFromDatabase(database);
      emit(AppCreateDBState());
    });
  }

  String todayDay = DateTime.now().day.toString();
  String todayMonth = DateFormat.MMM().format(DateTime.now()).toString();

  void insertDataToDatabase({
    required String title,
    required String description,
    required String dueDate,
  }) async {
    await database?.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title, desc, date, status, creationDay, creationMonth) VALUES("$title", "$description", "$dueDate", "new","$todayDay","$todayMonth" )')
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDataToDBState());

        // getDataFromDatabase(database);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }

  void getDataFromDatabase(data) {
    archivedTasks = [];
    newTasks = [];
    doneTasks = [];

    emit(AppGetDataFromDBState());

    database?.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(AppGetDataFromDBState());
    });
  }

  void updateTaskStatus({
    required String status,
    required int id,
  }) {
    database?.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateTaskStatusState());
    });
  }

  void updateData({
    required String title,
    required String description,
    required String dueDate,
    required int id,
  }) {
    database?.rawUpdate(
        'UPDATE tasks SET title = ?, desc = ? , date = ? WHERE id = ?',
        ['$title', '$description', '$dueDate', id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDBState());
    });
  }

  void deleteData({
    required int id,
  }) {
    database?.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDataFromDBState());
    });
  }

  bool isBotSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBotSheet({
    required bool shown,
    required IconData icon,
  }) {
    isBotSheetShown = shown;
    fabIcon = icon;
    getDataFromDatabase(database);
    emit(AppChangeBotSheetState());
  }

  bool editable = false;
  void enableEditForm({required bool editable}) {
    this.editable = editable;
    getDataFromDatabase(database);
    emit(AppEnableEditSheetState());
  }
}
