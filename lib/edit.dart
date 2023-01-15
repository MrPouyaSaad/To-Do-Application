// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/data.dart';
import 'package:todo/main.dart';

class EditTaskScreen extends StatefulWidget {
  EditTaskScreen({
    Key? key,
    required this.task,
  }) : super(key: key);
  final Task task;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.task.name);
  bool isEmptyTextField = false;
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: themeData.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: themeData.colorScheme.surface,
          foregroundColor: themeData.colorScheme.onSurface,
          elevation: 0.0,
          title: isNew ? Text('New Task') : Text('Edit Task'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _controller.text.isEmpty
                  ? isEmptyTextField = true
                  : isEmptyTextField = false;

              if (isEmptyTextField == false) {
                widget.task.name = _controller.text.capitalize.toString();

                if (widget.task.isInBox) {
                  widget.task.save();
                } else {
                  final Box<Task> box = Hive.box(taskBoxName);
                  box.add(widget.task);
                }
                if (!isNew) {
                  Get.back();
                  Get.back();
                } else
                  Get.back();
                isNew = false;
              } else {
                setState(() {});
              }
            },
            label: Row(
              children: [
                Text('Save Changes'),
                SizedBox(width: 4),
                Icon(
                  Icons.task_alt_rounded,
                )
              ],
            )),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                      flex: 1,
                      child: PrioritySelect(
                        lable: 'High',
                        color: primaryColor,
                        isSelect: widget.task.priority == Priority.high,
                        onTap: () {
                          setState(() {
                            widget.task.priority = Priority.high;
                          });
                        },
                      )),
                  SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: PrioritySelect(
                      lable: 'Normal',
                      color: normalPriorityColor,
                      isSelect: widget.task.priority == Priority.normal,
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.normal;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: PrioritySelect(
                      lable: 'Low',
                      color: lowPriorityColor,
                      isSelect: widget.task.priority == Priority.low,
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.low;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 8),
                  width: Get.width,
                  decoration: isEmptyTextField
                      ? BoxDecoration(
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(8.0),
                        )
                      : null,
                  child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      cursorHeight: 24,
                      controller: _controller,
                      decoration: InputDecoration(
                        errorText: isEmptyTextField
                            ? 'The task title is empty !'
                            : null,
                        label: Text('Add a task for today...'),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PrioritySelect extends StatelessWidget {
  final String lable;
  final Color color;
  final bool isSelect;
  final GestureTapCallback onTap;
  const PrioritySelect({
    Key? key,
    required this.lable,
    required this.color,
    required this.isSelect,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            width: 2.0,
            color: isSelect
                ? primaryColor.withOpacity(0.75)
                : secondryTextColor.withOpacity(0.20),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(lable),
            ),
            Positioned(
              right: 8,
              bottom: 0,
              top: 0,
              child: Center(
                  child: CheckBoxPriority(value: isSelect, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckBoxPriority extends StatelessWidget {
  final bool value;
  final Color color;
  const CheckBoxPriority({
    Key? key,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: value
          ? Icon(
              CupertinoIcons.check_mark,
              color: Colors.white,
              size: 12,
            )
          : null,
    );
  }
}
