import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../models/task_model.dart';
import '../providers/tour_app_provider.dart';
import '../services/app_tour_services.dart';
import './task_list_screen.dart';
import 'task_form_screen.dart';
import 'task_list_screen.dart' as main;

class TaskDetailsScreen extends StatefulWidget {
  TaskDetailsScreen({super.key, required this.task});

  Task task;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late DateTime? taskDateAdded;
  late DateTime? taskDeadline;
  //---------------
  final editKey = GlobalKey();
  final deleteKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

  //intialize my app tour for this page
  void _initTaskDetailsPageTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: taskDetailsTargets(
        editKey: editKey,
        deleteKey: deleteKey,
      ),
      hideSkip: true,
      paddingFocus: 10,
      useSafeArea: true,
      colorShadow: Theme.of(context).colorScheme.secondary,
      opacityShadow: 0.93,
      onFinish: () {
        //save status to show tour only in the first time
        if (!TourAppProvider.loadTaskDetailsPageTourStatusBox) {
          TourAppProvider.saveTaskDetailsPageTourStatusToBox = true;
          TourAppProvider.checkIfAllFinished();
        }
      },
    );
  }

  void _showTaskDetailsPageTour() {
    Future.delayed(const Duration(milliseconds: 500), () {
      tutorialCoachMark.show(context: context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initTaskDetailsPageTour();
    if (!TourAppProvider.taskDetailsStatus) _showTaskDetailsPageTour();
  }

  @override
  Widget build(BuildContext context) {
    String taskDateAsaString = widget.task.dateAdded!;
    taskDateAdded = main.DateToFormat.parseStringToDate(taskDateAsaString);
    String taskDeadLineAsaString = widget.task.deadline!;
    taskDeadline = main.DateToFormat.parseStringToDate(taskDeadLineAsaString);

    String date = main.DateToFormat.formatDate(taskDateAdded!, 'format2');
    String startTime = main.DateToFormat.formatDate(taskDateAdded!, 'format3');
    String endTime = main.DateToFormat.formatDate(taskDeadline!, 'format3');
    String isUrgent = widget.task.isVeryUrgent == 0 ? 'No' : 'Yes';
    String taskStatus =
        widget.task.isCompleted == 0 ? 'Not Completed' : 'Finished';

    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
          child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                widget.task.title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 25),
              _rowDesignForDisplayingSingleInfo(
                  context, date, 'Date:', Icons.date_range_rounded),
              const SizedBox(height: 13),
              _rowDesignForDisplayingSingleInfo(context,
                  '$startTime - $endTime', 'Time:', Icons.alarm_outlined),
              const SizedBox(height: 13),
              _rowDesignForDisplayingSingleInfo(
                  context,
                  widget.task.hasNotification == 0
                      ? 'No reminder set!'
                      : ' ${widget.task.remind} minutes early',
                  'Reminder:',
                  Icons.notification_add_rounded),
              const SizedBox(height: 13),
              _rowDesignForDisplayingSingleInfo(context, widget.task.category!,
                  'List Added To:', Icons.format_list_bulleted_add),
              const SizedBox(height: 13),
              _rowDesignForDisplayingSingleInfo(
                  context, isUrgent, 'Important:', Icons.star_rate_outlined),
              const SizedBox(height: 13),
              _rowDesignForDisplayingSingleInfo(
                  context, taskStatus, 'Status:', Icons.label_important),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Content',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      overflow: TextOverflow.clip,
                      widget.task.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(result: widget.task),
      ),
      title: const Text('Task Details'),
      actions: [
        GestureDetector(
          key: editKey,
          onTap: () async {
            var updatedTask =
                await Get.to(() => AddorEditTask(task: widget.task));
            setState(() {
              widget.task = updatedTask;
            });
          },
          child: myAppBarIcon(
            Icons.edit_document,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            key: deleteKey,
            onTap: () async {
              notifyHelper.cancelNotification(widget.task);
              await taskController.deleteTask(widget.task);
              Get.back(result: null);
            },
            child: myAppBarIcon(
              Icons.delete_outline_outlined,
            ),
          ),
        )
      ],
    );
  }

  Row _rowDesignForDisplayingSingleInfo(
      BuildContext context, String content, String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onSecondary,
          size: 24,
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  Container myAppBarIcon(IconData icon) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.transparent.withOpacity(0.05)),
      child: Icon(
        icon,
        size: 23,
      ),
    );
  }
}
