import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/widgets/my_drawer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/task_model.dart';
import '../providers/tour_app_provider.dart';
import '../services/app_tour_services.dart';
import '../widgets/task_tile.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';
import 'task_list_screen.dart' as main;

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class TasksUnderAListScreen extends StatefulWidget {
  TasksUnderAListScreen({super.key, required this.categoryName});
  String categoryName;

  @override
  State<TasksUnderAListScreen> createState() => _TasksUnderAListScreenState();
}

class _TasksUnderAListScreenState extends State<TasksUnderAListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Future<List<Task>> tasksUnderThisCategory;
  List<bool> checkIfTasksWidgetsExistOrNot = [false, false, false];
  //------------------------------
  final deleteListKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  //intialize my app tour for this page
  void _initTaskUnderListPageTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: taskUnderListPageTargets(
        deleteListKey: deleteListKey,
      ),
      hideSkip: true,
      paddingFocus: 10,
      useSafeArea: true,
      colorShadow: Theme.of(context).colorScheme.secondary,
      opacityShadow: 0.93,
      onFinish: () {
        //save status to show tour only in the first time
        if (!TourAppProvider.loadTaskUnderListPageTourStatusBox) {
          TourAppProvider.saveTaskUnderListPageTourStatusToBox = true;
          TourAppProvider.checkIfAllFinished();
        }
      },
    );
  }

  void _showTaskUnderListPageTour() {
    Future.delayed(const Duration(milliseconds: 500), () {
      tutorialCoachMark.show(context: context);
    });
  }

  @override
  void initState() {
    tasksUnderThisCategory =
        main.taskController.getAllTasksUnderThisCategory(widget.categoryName);
    main.taskController.getAllTasks();
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.categoryName != 'General' &&
        widget.categoryName != 'Today' &&
        widget.categoryName != 'Important' &&
        widget.categoryName != 'Finished') _initTaskUnderListPageTour();
    if (!TourAppProvider.taskUnderListStatus) _showTaskUnderListPageTour();
  }

  Future<void> onRefresh() async {
    await main.taskController.getAllTasks();
    setState(() {
      tasksUnderThisCategory =
          main.taskController.getAllTasksUnderThisCategory(widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<bool> checkIfTasksWidgetsExistOrNot = [false, false, false];
    othercategories();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
          actions: [
            widget.categoryName != 'General' &&
                    widget.categoryName != 'Important' &&
                    widget.categoryName != 'Finished' &&
                    widget.categoryName != 'Today'
                ? IconButton(
                    key: deleteListKey,
                    icon: const Icon(Icons.delete_forever),
                    onPressed: showAlertDialogForDeletingTheList,
                    iconSize: 23,
                  )
                : Container(),
          ],
        ),
        body: _myScreenContent(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Get.off(() => AddorEditTask());
          },
          child: const Icon(Icons.add),
        ),
        drawer: MyDrawer(categorySelected: widget.categoryName),
      ),
    );
  }

  Padding _myScreenContent() {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: Align(
          alignment: Alignment.topCenter,
          child: ListView(
            children: widget.categoryName == 'Today'
                ? getAllTasksForToday()
                : widget.categoryName == 'Finished'
                    ? getAllCompletedtasks()
                    : theRemainingCategories(),
          ),
        ),
      ),
    );
  }

  List<Widget> theRemainingCategories() {
    //print(checkIfTasksWidgetsExistOrNot);
    if (!checkIfTasksWidgetsExistOrNot.contains(false))
      return [Center(child: main.noTaskMsg(context, widget.categoryName))];
    else {
      return [
        tasksthatAreOverDue(),
        tasksthatAreToday(),
        tasksthatAreLater(),
      ];
    }
  }

  othercategories() {
    tasksthatAreOverDue();
    tasksthatAreToday();
    tasksthatAreLater();
  }

  getAllTasksForToday() {
    List<Widget> tasksWidgets = [];
    main.taskController.tasks.map(
      (Task task) {
        String taskStartDateAsString = task.dateAdded!;
        DateTime taskDateAdded =
            main.DateToFormat.parseStringToDate(taskStartDateAsString);
        if (isSameDay(taskDateAdded, DateTime.now()) && task.isCompleted == 0) {
          tasksWidgets.add(AnimatedBuilder(
              animation: _controller,
              builder: (ctx, child) => Padding(
                    padding:
                        EdgeInsets.only(top: 140 - _controller.value * 140),
                    child: child,
                  ),
              child: _myTaskItem(task, false,
                  widget.categoryName.trim() == 'Today' ? 'Today' : null)));
        }
      },
    ).toList();
    if (tasksWidgets.isEmpty) {
      return <Widget>[Center(child: main.noTaskMsg(context, 'Today'))];
    } else {
      return tasksWidgets;
    }
  }

  getAllCompletedtasks() {
    List<Widget> tasksWidgets = [];
    main.taskController.tasks.map(
      (Task task) {
        if (task.isCompleted == 1) {
          return tasksWidgets.add(AnimatedBuilder(
              animation: _controller,
              builder: (ctx, child) => Padding(
                    padding:
                        EdgeInsets.only(top: 140 - _controller.value * 140),
                    child: child,
                  ),
              child: _myTaskItem(task)));
        }
      },
    ).toList();
    if (tasksWidgets.isEmpty) {
      return <Widget>[Center(child: main.noTaskMsg(context, 'Finished'))];
    } else {
      return tasksWidgets;
    }
  }

  Widget tasksthatAreOverDue() {
    // Function to build task widgets from a list of tasks
    List<Widget> buildTaskWidgets(List<Task> tasks) {
      return tasks.map((task) {
        String taskDeadLineAsString = task.deadline!;
        DateTime taskDeadline =
            main.DateToFormat.parseStringToDate(taskDeadLineAsString);
        return taskDeadline.isBefore(DateTime.now()) &&
                task.isCompleted == 0 &&
                (widget.categoryName.trim() != 'Important' ||
                    task.isVeryUrgent == 1)
            ? _myTaskItem(
                task,
                widget.categoryName.trim() != 'Important' ? true : false,
                widget.categoryName.trim() == 'Important' ? 'Important' : null)
            : Container();
      }).toList();
    }

    // Check if the 'Important' category has any tasks
    List<Widget> importantTasksWidgets = [];
    if (widget.categoryName.trim() == 'Important') {
      importantTasksWidgets = buildTaskWidgets(main.taskController.tasks);
      importantTasksWidgets = importantTasksWidgets
          .where((element) => element is! Container)
          .toList();
    }

    // If there are no tasks to display for 'Important', return an empty SizedBox
    if (widget.categoryName.trim() == 'Important' &&
        importantTasksWidgets.isEmpty) {
      setState(() {
        checkIfTasksWidgetsExistOrNot[0] = true;
      });
      // return main.noTaskMsg(context, 'Important');
      return const SizedBox();
    }

    // Function to handle the FutureBuilder logic for other categories
    Widget buildFutureTasks() {
      return FutureBuilder<List<Task>>(
        future: tasksUnderThisCategory,
        builder: (context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show loading indicator while waiting
          } else if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot.error}'); // Show error if something went wrong
          } else if (snapshot.hasData) {
            List<Widget> taskWidgets = buildTaskWidgets(snapshot.data!);
            // Remove any Container() that might have been added
            taskWidgets =
                taskWidgets.where((element) => element is! Container).toList();

            // If there are no tasks to display, return an empty SizedBox
            if (taskWidgets.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    checkIfTasksWidgetsExistOrNot[0] = true;
                  });
                }
              });
              //   return main.noTaskMsg(context);
              return const SizedBox();
            }

            // Otherwise, return the ExpansionTile with the tasks
            return Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                textColor: Theme.of(context).colorScheme.error.withOpacity(0.5),
                title: const Text('OverDue'),
                leading: const Icon(Icons.list_alt_sharp),
                childrenPadding: const EdgeInsets.only(left: 5.0),
                children: taskWidgets,
              ),
            );
          } else {
            return const Text(
                'No data'); // Handle the case where there's no data
          }
        },
      );
    }

    // Return the appropriate widget based on categoryName
    return widget.categoryName.trim() == 'Important'
        ? Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              textColor: Theme.of(context).colorScheme.error.withOpacity(0.5),
              title: const Text('OverDue'),
              leading: const Icon(Icons.list_alt_sharp),
              childrenPadding: const EdgeInsets.only(left: 5.0),
              children: importantTasksWidgets,
            ),
          )
        : buildFutureTasks();
  }

  Widget tasksthatAreToday() {
    // Function to build task widgets from a list of tasks
    List<Widget> buildTaskWidgets(List<Task> tasks) {
      return tasks.map((task) {
        String taskStartDateAsString = task.dateAdded!;
        DateTime taskDateAdded =
            main.DateToFormat.parseStringToDate(taskStartDateAsString);
        String taskDeadLineAsString = task.deadline!;
        DateTime taskDeadline =
            main.DateToFormat.parseStringToDate(taskDeadLineAsString);
        return isSameDay(taskDateAdded, DateTime.now()) &&
                !taskDeadline.isBefore(DateTime.now()) &&
                task.isCompleted == 0 &&
                (widget.categoryName.trim() != 'Important' ||
                    task.isVeryUrgent == 1)
            ? _myTaskItem(
                task,
                widget.categoryName.trim() != 'Important' ? true : false,
                widget.categoryName.trim() == 'Important' ? 'Important' : null)
            : Container();
      }).toList();
    }

    // Check if the 'Important' category has any tasks due today and are very urgent
    List<Widget> importantTasksWidgets = [];
    if (widget.categoryName.trim() == 'Important') {
      importantTasksWidgets = buildTaskWidgets(main.taskController.tasks);
      importantTasksWidgets = importantTasksWidgets
          .where((element) => element is! Container)
          .toList();
    }

    // If there are no very urgent tasks due today for 'Important', return an empty SizedBox
    if (widget.categoryName.trim() == 'Important' &&
        importantTasksWidgets.isEmpty) {
      setState(() {
        checkIfTasksWidgetsExistOrNot[1] = true;
      });
      // return main.noTaskMsg(context, 'Important');
      return const SizedBox();
    }

    // Function to handle the FutureBuilder logic for other categories
    Widget buildFutureTasks() {
      return FutureBuilder<List<Task>>(
        future: tasksUnderThisCategory,
        builder: (context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show loading indicator while waiting
          } else if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot.error}'); // Show error if something went wrong
          } else if (snapshot.hasData) {
            List<Widget> taskWidgets = buildTaskWidgets(snapshot.data!);
            // Remove any Container() that might have been added
            taskWidgets =
                taskWidgets.where((element) => element is! Container).toList();
            // If there are no tasks to display, return an empty SizedBox
            if (taskWidgets.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    checkIfTasksWidgetsExistOrNot[1] = true;
                  });
                }
              });

              return const SizedBox();
              // return main.noTaskMsg(context);
            }

            // Otherwise, return the ExpansionTile with the tasks
            return Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                textColor: Colors.teal.shade700,
                title: const Text('Today'),
                leading: const Icon(Icons.list_alt_sharp),
                childrenPadding: const EdgeInsets.only(left: 5.0),
                children: taskWidgets,
              ),
            );
          } else {
            return const Text(
                'No data'); // Handle the case where there's no data
          }
        },
      );
    }

    // Return the appropriate widget based on categoryName
    return widget.categoryName.trim() == 'Important'
        ? Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              textColor: Colors.teal.shade700,
              title: const Text('Today'),
              leading: const Icon(Icons.list_alt_sharp),
              childrenPadding: const EdgeInsets.only(left: 5.0),
              children: importantTasksWidgets,
            ),
          )
        : buildFutureTasks();
  }

  Widget tasksthatAreLater() {
    // Function to build task widgets from a list of tasks
    List<Widget> buildTaskWidgets(List<Task> tasks) {
      return tasks.map((task) {
        String taskStartDateAsString = task.dateAdded!;
        DateTime taskDateAdded =
            main.DateToFormat.parseStringToDate(taskStartDateAsString);
        String taskDeadLineAsString = task.deadline!;
        DateTime taskDeadline =
            main.DateToFormat.parseStringToDate(taskDeadLineAsString);
        return !isSameDay(taskDateAdded, DateTime.now()) &&
                taskDeadline.isAfter(DateTime.now()) &&
                task.isCompleted == 0 &&
                (widget.categoryName.trim() != 'Important' ||
                    task.isVeryUrgent == 1)
            ? _myTaskItem(
                task,
                widget.categoryName.trim() != 'Important' ? true : false,
                widget.categoryName.trim() == 'Important' ? 'Important' : null)
            : Container();
      }).toList();
    }

    // Check if the 'Important' category has any tasks due today and are very urgent
    List<Widget> importantTasksWidgets = [];
    if (widget.categoryName.trim() == 'Important') {
      importantTasksWidgets = buildTaskWidgets(main.taskController.tasks);
      importantTasksWidgets = importantTasksWidgets
          .where((element) => element is! Container)
          .toList();
    }

    // If there are no very urgent tasks due today for 'Important', return an empty SizedBox
    if (widget.categoryName.trim() == 'Important' &&
        importantTasksWidgets.isEmpty) {
      setState(() {
        checkIfTasksWidgetsExistOrNot[2] = true;
      });
      // return main.noTaskMsg(context, 'Important');
      return const SizedBox();
    }

    // Function to handle the FutureBuilder logic for other categories
    Widget buildFutureTasks() {
      return FutureBuilder<List<Task>>(
        future:
            tasksUnderThisCategory, // Make sure this future fetches 'later' tasks
        builder: (context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List<Widget> taskWidgets = buildTaskWidgets(snapshot.data!);
            taskWidgets =
                taskWidgets.where((element) => element is! Container).toList();

            // If there are no tasks to display, return an empty SizedBox
            if (taskWidgets.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    checkIfTasksWidgetsExistOrNot[2] = true;
                  });
                }
              });

              // return main.noTaskMsg(context);

              return const SizedBox();
            }

            // Otherwise, return the ExpansionTile with the tasks
            return Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                textColor: Colors.grey,
                title: const Text('Later'),
                leading: const Icon(Icons.list_alt_sharp),
                childrenPadding: const EdgeInsets.only(left: 5.0),
                children: taskWidgets,
              ),
            );
          } else {
            return const Text(
                'No data'); // Handle the case where there's no data
          }
        },
      );
    }

    // Return the appropriate widget based on categoryName
    return widget.categoryName.trim() == 'Important'
        ? Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              textColor: Colors.grey,
              title: const Text('Later'),
              leading: const Icon(Icons.list_alt_sharp),
              childrenPadding: const EdgeInsets.only(left: 5.0),
              children: importantTasksWidgets,
            ),
          )
        : buildFutureTasks();
  }

  Widget _myTaskItem(Task? task,
      [bool isAlistItem = false, String? categroyName]) {
    return InkWell(
      onTap: () async {
        await main.taskController.getAllTasks();
        setState(() {
          tasksUnderThisCategory = main.taskController
              .getAllTasksUnderThisCategory(widget.categoryName);
        });
      },
      onLongPress: () async {
        var updatedTask = await Get.to(() => TaskDetailsScreen(task: task!));
        main.taskController.getAllTasks();
        tasksUnderThisCategory = main.taskController
            .getAllTasksUnderThisCategory(widget.categoryName);
        setState(() {
          task = updatedTask;
        });
      },
      child: TaskTile(
        task: task!,
        isThisAList: isAlistItem,
        categoryName: categroyName,
      ),
    );
  }

  showAlertDialogForDeletingTheList() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remove the list',
            style: GoogleFonts.ubuntuCondensed(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: const Text(
              'Are You Sure you want to delete the list and all the tasks under it?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.ubuntuCondensed(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
                ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Text(
                    'Delete',
                    style: GoogleFonts.ubuntuCondensed(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onPressed: () async {
                    for (Task task in main.taskController.tasks) {
                      if (task.category == widget.categoryName) {
                        await main.notifyHelper.cancelNotification(task);
                      }
                    }
                    await main.categoryController
                        .deleteCategoryandTasksUnderIt(widget.categoryName);
                    await main.taskController.getAllTasks();
                    Get.offAll(const main.HomeScreen());
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
