import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/screens/tasks_under_list_screen.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../models/task_model.dart';
import '../providers/tour_app_provider.dart';
import '../screens/task_list_screen.dart' as main;
import '../services/app_tour_services.dart';

class TaskTile extends StatefulWidget {
  TaskTile({
    super.key,
    required this.task,
    this.isThisAList = false,
    this.categoryName,
  });
  String? categoryName;
  final Task task;
  bool isThisAList = false;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool isboxChecked;
  late DateTime? taskDateAdded;
  late DateTime? taskDeadline;
  late String startTime;
  late String endTime;
  bool isTourFinished = false;
  final taskTileKey = GlobalKey();
  final favoriteIconKey = GlobalKey();
  final checkBoxKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  void _initTaskTileTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: taskTileTargets(
        taskTileKey: taskTileKey,
        checkBoxkey: checkBoxKey,
        favoriteKey: favoriteIconKey,
      ),
      hideSkip: true,
      paddingFocus: 10,
      useSafeArea: true,
      colorShadow: Theme.of(context).colorScheme.secondary,
      opacityShadow: 0.93,
      onFinish: () {
        //save status to show tour only in the first time
        if (!TourAppProvider.loadTaskTileTourStatusBox) {
          TourAppProvider.saveTaskTileTourStatusToBox = true;
          TourAppProvider.checkIfAllFinished();
        }
      },
    );
  }

  void _showTaskTileTour() {
    Future.delayed(const Duration(milliseconds: 500), () {
      tutorialCoachMark.show(context: context);
    });
  }

  @override
  void initState() {
    isboxChecked = widget.task.isCompleted == 0 ? false : true;
    String taskDateAsaString = widget.task.dateAdded!;
    taskDateAdded = main.DateToFormat.parseStringToDate(taskDateAsaString);
    String taskDeadLineAsaString = widget.task.deadline!;
    taskDeadline = main.DateToFormat.parseStringToDate(taskDeadLineAsaString);
    startTime = DateFormat.jm().format(taskDateAdded!);
    endTime = DateFormat.jm().format(taskDeadline!);
    _controller = AnimationController(
      value: 1,
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: const Duration(seconds: 3),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _initTaskTileTour();

    if (!isTourFinished) {
      if (!TourAppProvider.taskTileStatus) _showTaskTileTour();
      isTourFinished = true;
    }

    String taskDateAsaString = widget.task.dateAdded!;
    taskDateAdded = main.DateToFormat.parseStringToDate(taskDateAsaString);
    String taskDeadLineAsaString = widget.task.deadline!;
    taskDeadline = main.DateToFormat.parseStringToDate(taskDeadLineAsaString);
    startTime = DateFormat.jm().format(taskDateAdded!);
    endTime = DateFormat.jm().format(taskDeadline!);
    return FadeTransition(
      opacity: _animation,
      child: tasktileContent(context, startTime, endTime),
    );
  }

  Container tasktileContent(
      BuildContext context, String startTime, String endTime) {
    return Container(
      key: taskTileKey,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.4,
            child: Checkbox(
              key: checkBoxKey,
              fillColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surface.withOpacity(0.5)),
              value: isboxChecked,
              onChanged: isboxChecked && widget.task.isCompleted == 1
                  ? (bool? newValue) {
                      setState(() {
                        isboxChecked = false;
                      });
                      Future.wait([
                        Future.delayed(const Duration(seconds: 1),
                            () => oncheckBoxChanged(context))
                      ]);
                    }
                  : !isboxChecked
                      ? (bool? newValue) async {
                          setState(() {
                            isboxChecked = true;
                          });
                          Future.wait([
                            Future.delayed(const Duration(seconds: 1),
                                () => oncheckBoxChanged(context))
                          ]);
                        }
                      : null,
            ),
          ),
          Container(
            height: 60,
            width: 1.5,
            margin: const EdgeInsets.only(right: 10),
            color: Colors.teal,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    widget.task.title!,
                    textStyle: GoogleFonts.ubuntuCondensed().copyWith(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
                pause: const Duration(milliseconds: 500),
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
              ),
              Text(
                '$startTime - $endTime',
                style: GoogleFonts.ubuntuCondensed().copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: taskDeadline!.isBefore(DateTime.now()) &&
                          widget.task.isCompleted == 0
                      ? Theme.of(context).colorScheme.error.withOpacity(0.65)
                      : Colors.teal,
                ),
              ),
              Text(
                widget.isThisAList
                    ? main.DateToFormat.formatDate(taskDateAdded!, 'format4')
                    : widget.task.category!,
                style: GoogleFonts.ubuntuCondensed().copyWith(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () async {
              setState(() {
                widget.task.isVeryUrgent =
                    widget.task.isVeryUrgent == 0 ? 1 : 0;
              });
              await main.taskController.isVeryUrgentChange(
                  widget.task.id!, widget.task.isVeryUrgent!);
              if (widget.task.isVeryUrgent == 0 &&
                  widget.categoryName == 'Important') {
                Future.delayed(
                  const Duration(seconds: 1),
                  () => setState(() {
                    Get.offAll(TasksUnderAListScreen(
                        categoryName: widget.categoryName!));
                  }),
                );
              }
            },
            child: CircleAvatar(
              key: favoriteIconKey,
              backgroundColor: Colors.teal.withOpacity(0.8),
              radius: 17,
              child: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: Tween<double>(begin: 0.9, end: 1).animate(animation),
                    child: child,
                  );
                },
                child: Icon(
                  widget.task.isVeryUrgent == 1
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.yellow[200],
                  key: ValueKey(widget.task.isVeryUrgent),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  void oncheckBoxChanged(BuildContext context) {
    setState(() {
      Get.showSnackbar(
        GetSnackBar(
          duration: const Duration(seconds: 2),
          /*  backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,  */
          backgroundColor: Theme.of(context).colorScheme.surface,
          titleText: Text(
            widget.task.isCompleted == 0
                ? ' Add to Finished Section:'
                : 'Add to Active Tasks:',
            style: GoogleFonts.ubuntuCondensed().copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          messageText: Text(
            'Are you sure you want to proceed?',
            style: GoogleFonts.ubuntuCondensed().copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          borderWidth: 2,
          borderColor: Theme.of(context).colorScheme.primary,
          mainButton: TextButton(
            child: const Text('Undo'),
            onPressed: () {
              setState(() {
                !isboxChecked && widget.task.isCompleted == 1
                    ? isboxChecked = true
                    : isboxChecked = false;
              });
              Get.back();
            },
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 3), () async {
        if (isboxChecked && widget.task.isCompleted == 0 ||
            !isboxChecked && widget.task.isCompleted == 1) {
          await _controller.animateTo(0);
          widget.task.isCompleted = widget.task.isCompleted == 0 ? 1 : 0;
          if (widget.task.isCompleted == 1) {
            main.notifyHelper.cancelNotification(widget.task);
          }
        }
        if (_controller.isCompleted) {
          print('true');
          await main.taskController
              .markedAsCompleted(widget.task.id!, widget.task.isCompleted!);
          if ((widget.categoryName == 'Today' ||
                  widget.categoryName == 'Important') &&
              isboxChecked == true) {
            setState(() {
              Get.offAll(
                  TasksUnderAListScreen(categoryName: widget.categoryName!));
            });
          }
        }
      });
    });
  }
}
