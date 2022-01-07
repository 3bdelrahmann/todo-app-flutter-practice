import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, States>(
        listener: (BuildContext context, state) {
          if (state is AppInsertDataToDBState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, Object? state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              elevation: 0.0,
            ),
            body: Column(
              children: [
                appbarShape(context: context),
                SizedBox(
                  height: 10.0,
                ),
                ConditionalBuilder(
                  condition: state is! AppGetDatabaseLoadingState,
                  builder: (context) =>
                      Expanded(child: cubit.screens[cubit.index]),
                  fallback: (context) =>
                      Center(child: CircularProgressIndicator()),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(cubit.fabIcon),
              onPressed: () {
                if (cubit.isBotSheetShown) {
                  if (formKey.currentState!.validate()) {
                    // Here to insert in the database
                    cubit.insertDataToDatabase(
                      title: titleController.text,
                      description: descriptionController.text,
                      dueDate: dueDateController.text,
                    );
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) =>
                            defaultNavSheet(key: formKey, context: context),
                        elevation: 30.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBotSheet(
                      shown: false,
                      icon: Icons.edit,
                    );
                    formKey.currentState!.reset();
                  });
                  cubit.changeBotSheet(
                    shown: true,
                    icon: Icons.add,
                  );
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.index,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archived',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_outlined),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_alt),
                  label: 'Done',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
