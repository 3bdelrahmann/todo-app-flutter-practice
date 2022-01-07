import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/layout/home_layout.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class EditTaskScreen extends StatelessWidget {
  final Map model;
  final formGlobalKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var dueDateController = TextEditingController();
  var statusController = TextEditingController();

  EditTaskScreen(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    titleController.text = model['title'].toString();
    descriptionController.text = model['desc'].toString();
    dueDateController.text = model['date'].toString();
    statusController.text = model['status'].toString().toUpperCase();

    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, States>(
        listener: (BuildContext context, state) {},
        builder: (BuildContext context, Object? state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            backgroundColor: Colors.blue,
            body: reusableEditTaskCard(
              key: formGlobalKey,
              children: [
                Text(
                  'ID: ${model['id']}',
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextFormField(
                  controller: titleController,
                  enabled: cubit.editable,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(
                      Icons.title,
                    ),
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
                  enabled: cubit.editable,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(
                      Icons.description,
                    ),
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
                  enabled: cubit.editable,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    prefixIcon: Icon(
                      Icons.date_range,
                    ),
                  ),
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2032),
                    ).then((value) {
                      dueDateController.text =
                          DateFormat.yMMMd().format(value!);
                    });
                  },
                  readOnly: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a Due date';
                    }
                  },
                ),
                SizedBox(
                  height: 15.0,
                ),
                Container(
                  color: model['status'] == 'done'
                      ? Colors.green
                      : (model['status'] == 'new'
                          ? Colors.white
                          : Colors.grey[700]),
                  child: TextFormField(
                    style: TextStyle(
                      color: model['status'] == 'new'
                          ? Colors.black
                          : Colors.white,
                      fontSize: 20.0,
                    ),
                    controller: statusController,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(
                        color: model['status'] == 'new'
                            ? Colors.black
                            : Colors.white,
                        fontSize: 20.0,
                      ),
                      prefixIcon: model['status'] == 'new'
                          ? Icon(
                              Icons.fiber_new,
                              size: 30.0,
                            )
                          : (model['status'] == 'done'
                              ? Icon(
                                  Icons.task_alt,
                                  size: 30.0,
                                )
                              : Icon(
                                  Icons.archive_outlined,
                                  size: 30.0,
                                )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("You can edit fields now"),
                        ));
                        AppCubit.get(context).enableEditForm(editable: true);
                      },
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      color: Colors.blue,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: () {
                          if (formGlobalKey.currentState!.validate()) {
                            cubit.updateData(
                                title: titleController.text,
                                description: descriptionController.text,
                                dueDate: dueDateController.text,
                                id: model['id']);

                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.SUCCES,
                              animType: AnimType.BOTTOMSLIDE,
                              headerAnimationLoop: false,
                              title: 'Saved',
                              desc: 'You updated your tasks successfully',
                              btnOkOnPress: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeLayout()),
                                    (route) => false);
                              },
                            ).show();
                          }
                        },
                        child: Text(
                          'save',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
