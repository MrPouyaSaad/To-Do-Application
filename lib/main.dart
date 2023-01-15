// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:todo/data.dart';

import 'edit.dart';

const taskBoxName = 'tasks';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  // SystemChrome.setSystemUIOverlayStyle(
  //   SystemUiOverlayStyle(statusBarColor: Colors.black),
  // );
  runApp(const MyApp());
}

const backgroundColor = Color(0xffF3F5F8);
const primaryColor = Color(0xff794CFF);
const primaryTextColor = Color(0xff1D2830);
const secondryTextColor = Color(0xffAFBED0);
const normalPriorityColor = Color(0XFFF09819);
const lowPriorityColor = Color(0XFF3BE1F1);
const highPriorityColor = Color(0xff794CFF);
Color priorityColor = Colors.black;
bool isNew = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        textTheme: TextTheme(
          headline6: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: primaryTextColor,
          textColor: primaryTextColor,
          horizontalTitleGap: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: InputBorder.none,
          iconColor: secondryTextColor,
        ),
        hintColor: secondryTextColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          // ignore: deprecated_member_use
          primaryVariant: Color(0xff5C0AFF),
          background: backgroundColor,
          onSurface: primaryTextColor,
          onBackground: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> search = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>(taskBoxName);
    final themeData = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            isNew = true;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    EditTaskScreen(task: Task(priority: Priority.normal)),
              ),
            );
          },
          label: Row(
            children: [
              Text('Add New Task '),
              Icon(
                CupertinoIcons.add_circled,
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeData.colorScheme.primary,
                    // ignore: deprecated_member_use
                    themeData.colorScheme.primaryVariant,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'To Do List',
                          style: themeData.textTheme.headline6!
                              .apply(color: themeData.colorScheme.onPrimary),
                        ),
                        Spacer(),
                        Icon(
                          CupertinoIcons.share,
                          color: themeData.colorScheme.onPrimary,
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 16),
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          search.value = controller.text;
                        },
                        controller: controller,
                        cursorHeight: 18,
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: search,
                builder: (context, value, child) {
                  return ValueListenableBuilder<Box<Task>>(
                    valueListenable: box.listenable(),
                    builder: (context, box, child) {
                      final items;
                      if (controller.text.isEmpty) {
                        items = box.values.toList();
                      } else {
                        items = box.values
                            .where(
                                (task) => task.name.contains(controller.text))
                            .toList();
                      }
                      if (items.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/empty.png',
                              width: 180,
                            ),
                            Text(
                              'Your task list is empty !',
                              style: themeData.textTheme.headline6!
                                  .apply(fontSizeFactor: 0.75),
                            )
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tasks',
                                        style: themeData.textTheme.headline6!
                                            .apply(fontSizeFactor: 0.85),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        width: 65,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(1.50),
                                          color: primaryColor,
                                        ),
                                      )
                                    ],
                                  ),
                                  MaterialButton(
                                    elevation: 0.0,
                                    //color: Color(0xffEAEFF5),
                                    textColor: secondryTextColor,
                                    onPressed: () {
                                      dialog(themeData, box);
                                    },
                                    child: Row(
                                      children: [
                                        Text('Delete All'),
                                        SizedBox(width: 4),
                                        Icon(CupertinoIcons.delete_solid,
                                            size: 18)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, bottom: 100, top: 8),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final Task task = items[index];
                                  return TaskData(
                                    task: task,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> dialog(ThemeData themeData, Box<Task> box) {
    return Get.defaultDialog(
        title: 'Delete All',
        middleText: 'Are you sure you want to delete all tasks?',
        textCancel: 'No',
        textConfirm: 'Yes',
        titleStyle: themeData.textTheme.headline6!.apply(fontSizeFactor: 0.85),
        middleTextStyle: themeData.textTheme.bodyText2,
        confirmTextColor: themeData.colorScheme.onPrimary,
        onConfirm: () {
          box.clear();
          Get.back();
        });
  }
}

//? Task data
class TaskData extends StatefulWidget {
  const TaskData({
    Key? key,
    required this.task,
  }) : super(key: key);

  final Task task;

  @override
  State<TaskData> createState() => _TaskDataState();
}

class _TaskDataState extends State<TaskData> {
  double boxHeight = 74;
  double borderRadius = 8;
  @override
  Widget build(BuildContext context) {
    final ThemeData themData = Theme.of(context);

    switch (widget.task.priority) {
      case Priority.normal:
        priorityColor = normalPriorityColor;
        break;
      case Priority.high:
        priorityColor = highPriorityColor;
        break;
      case Priority.low:
        priorityColor = lowPriorityColor;
        break;
    }

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () {
            setState(
              () {
                if (!widget.task.isCompleted) {
                  snackBar(themData);
                }
                widget.task.isCompleted = !widget.task.isCompleted;
              },
            );
            widget.task.save();
          },
          onLongPress: () {
            bottonSheet(themData);
          },
          child: Container(
            height: boxHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: themData.colorScheme.surface,
            ),
            child: Row(
              children: [
                MyCheckBox(
                  value: widget.task.isCompleted,
                ),
                Expanded(
                  child: Text(
                    widget.task.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: widget.task.isCompleted
                            ? Colors.black.withOpacity(0.6)
                            : Colors.black,
                        decoration: widget.task.isCompleted
                            ? TextDecoration.lineThrough
                            : null),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                ),
                Container(
                  width: 6,
                  height: boxHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                    color: priorityColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Future<dynamic> bottonSheet(ThemeData themData) {
    return Get.bottomSheet(
      Container(
        height: 185,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
        ),
        child: Wrap(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 8),
                  width: 35,
                  height: 4,
                  decoration: BoxDecoration(
                      color: primaryTextColor,
                      borderRadius: BorderRadius.circular(2)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 0, 12),
              child: Text(
                widget.task.name,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(color: primaryTextColor.withOpacity(0.65)),
              ),
            ),
            Divider(
              color: secondryTextColor,
              height: 1,
            ),
            ListTile(
              leading: Icon(CupertinoIcons.pencil),
              title: Text('Edit task'),
              onTap: () => Get.to(EditTaskScreen(task: widget.task)),
            ),
            ListTile(
              leading: Icon(CupertinoIcons.delete),
              title: Text('Delete'),
              onTap: () {
                Get.defaultDialog(
                  title: widget.task.name,
                  middleText: 'Are you sure you want to delete the task?',
                  textCancel: 'No',
                  textConfirm: 'Yes',
                  titleStyle:
                      themData.textTheme.headline6!.apply(fontSizeFactor: 0.85),
                  middleTextStyle: themData.textTheme.bodyText2,
                  onConfirm: () {
                    widget.task.delete();
                    Get.back();
                    Get.back();
                  },
                  confirmTextColor: themData.colorScheme.onPrimary,
                  backgroundColor: backgroundColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SnackbarController snackBar(ThemeData themData) {
    return Get.snackbar(
      widget.task.name,
      'Task Completed',
      colorText: themData.colorScheme.surface,
      animationDuration: Duration(seconds: 1),
      duration: Duration(seconds: 2),
      margin: EdgeInsets.only(top: 8, left: 16, right: 16),
      barBlur: 20.0,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      reverseAnimationCurve: Curves.fastLinearToSlowEaseIn,
      icon: Icon(
        CupertinoIcons.checkmark_circle_fill,
        color: themData.colorScheme.surface,
      ),
      shouldIconPulse: false,
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;

  const MyCheckBox({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return value
        ? Padding(
            padding: const EdgeInsets.only(left: 8, right: 14),
            child: Icon(
              Icons.task_alt_rounded,
              color: primaryColor,
              size: 22,
            ),
          )
        : Container(
            margin: EdgeInsets.only(left: 8, right: 16),
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.5),
              border: Border.all(
                color: secondryTextColor,
                width: 1.5,
              ),
            ),
          );
  }
}
