import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/modules/edit_task/edit_task_screen.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget appbarShape({
  required BuildContext context,
}) =>
    Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 30.0,
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80.0),
                bottomRight: Radius.circular(80.0),
              ),
            ),
            child: Center(
              child: Text(
                AppCubit.get(context).titles[AppCubit.get(context).index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );

Widget buildTaskItem({
  required Map model,
  required context,
  required bool isDone,
  required bool isNew,
}) =>
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditTaskScreen(model)),
        );
      },
      child: Dismissible(
        key: Key(model['id'].toString()),
        child: ListTile(
          leading: CircleAvatar(
            radius: 50.0,
            child: Text(
              '${model['creationDay']}\n${model['creationMonth']}',
              textAlign: TextAlign.center,
            ),
          ),
          title: Text(
            '${model['title']}',
            style: TextStyle(fontSize: 18.0),
          ),
          subtitle: Text('${model['date']}'),
          trailing: isNew
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        AppCubit.get(context).updateTaskStatus(
                          status: 'archive',
                          id: model['id'],
                        );
                      },
                      icon: Icon(Icons.archive),
                    ),
                    IconButton(
                      onPressed: () {
                        AppCubit.get(context).updateTaskStatus(
                          status: 'done',
                          id: model['id'],
                        );
                      },
                      icon: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )
              : IconButton(
                  onPressed: () {
                    isDone
                        ? AppCubit.get(context).updateTaskStatus(
                            status: 'done',
                            id: model['id'],
                          )
                        : AppCubit.get(context).updateTaskStatus(
                            status: 'archive',
                            id: model['id'],
                          );
                  },
                  icon: isDone
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                      : Icon(Icons.archive),
                ),
        ),
        onDismissed: (direction) =>
            AppCubit.get(context).deleteData(id: model['id']),
        background: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.delete,
                size: 25.0,
                color: Colors.white,
              ),
              Text(
                'Delete',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        direction: DismissDirection.startToEnd,
      ),
    );

Widget tasksListBuilder(
        {required List<Map> tasks,
        required bool isArchived,
        required bool isNew}) =>
    ConditionalBuilder(
      condition: tasks.length > 0,
      builder: (context) => ListView.separated(
          itemBuilder: (context, index) => buildTaskItem(
              model: tasks[index],
              context: context,
              isDone: isArchived,
              isNew: isNew),
          separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                ),
                child: Container(
                  width: double.infinity,
                  height: 1.0,
                  color: Colors.grey[400],
                ),
              ),
          itemCount: tasks.length),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_task,
              size: 100.0,
              color: Colors.grey,
            ),
            Text(
              'No Tasks Yet',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

var titleController = TextEditingController();
var descriptionController = TextEditingController();
var dueDateController = TextEditingController();

Widget defaultNavSheet({required var key, required BuildContext context}) =>
    Container(
      padding: EdgeInsets.all(30.0),
      child: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Task Tile',
                prefixIcon: Icon(
                  Icons.title,
                ),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a title';
                }
              },
            ),
            SizedBox(
              height: 15.0,
            ),
            TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Task Description',
                prefixIcon: Icon(
                  Icons.description,
                ),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a description';
                }
              },
            ),
            SizedBox(
              height: 15.0,
            ),
            TextFormField(
              controller: dueDateController,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                labelText: 'Due Date',
                prefixIcon: Icon(Icons.date_range),
                border: OutlineInputBorder(),
              ),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2032),
                ).then((value) {
                  dueDateController.text = DateFormat.yMMMd().format(value!);
                });
              },
              readOnly: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a Due date';
                }
              },
            ),
          ],
        ),
      ),
    );

Widget reusableEditTaskCard({
  Key? key,
  required List<Widget> children,
}) =>
    Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          padding: const EdgeInsets.all(30.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
