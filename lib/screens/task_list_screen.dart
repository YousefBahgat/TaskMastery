import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/providers/tour_app_provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../controllers/category_contorller.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../providers/theme_provider.dart';
import '../services/app_tour_services.dart';
import '../services/notification_services.dart';
import '../size_config.dart';
import '../widgets/my_drawer.dart';
import '../widgets/task_tile.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';
import 'tasks_under_list_screen.dart';

final CategoryController categoryController = CategoryController();
final TaskController taskController = TaskController();

extension DateToFormat on DateTime {
  static DateTime parseStringToDate(String dateText) {
    DateFormat format1 = DateFormat('yyyy/MM/dd hh:mm a');
    return format1.parse(dateText);
  }

  static String formatDate(DateTime date, String format) {
    DateFormat format2 = DateFormat('yyyy/mm/dd');
    DateFormat format3 = DateFormat('hh:mm a');
    DateFormat format4 = DateFormat('EEEE, d MMMM yyyy');
    if (format == 'format2')
      return format2.format(date);
    else if (format == 'format3')
      return format3.format(date);
    else
      return format4.format(date);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

late NotifyHelper notifyHelper;

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DateTime _selectedDate = DateTime.now();
  //define Global keys for the app tour
  final themeKey = GlobalKey();
  final deleteAllIconKey = GlobalKey();
  final addTaskKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  //intialize my app tour for this page
  void _initHomePageTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: homePageTargets(
        addTaskKey: addTaskKey,
        deleteAllTasksKey: deleteAllIconKey,
        themeKey: themeKey,
      ),
      hideSkip: true,
      paddingFocus: 10,
      useSafeArea: true,
      colorShadow: Theme.of(context).colorScheme.secondary,
      opacityShadow: 0.93,
      onFinish: () {
        //save status to show tour only in the first time
        if (!TourAppProvider.loadHomePageTourStatusBox) {
          TourAppProvider.saveHomePageTourStatusToBox = true;
          TourAppProvider.checkIfAllFinished();
        }
      },
    );
  }

  void _showMyHomePageTour() {
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      tutorialCoachMark.show(context: context);
    });
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: DatePicker(
        DateTime.now(),
        width: 70,
        height: 100,
        initialSelectedDate: DateTime.now(),
        selectionColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        selectedTextColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        dateTextStyle: GoogleFonts.ubuntuCondensed(
          textStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            fontSize: 20,
          ),
        ),
        dayTextStyle: GoogleFonts.ubuntuCondensed(
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            fontSize: 16,
          ),
        ),
        monthTextStyle: GoogleFonts.ubuntuCondensed(
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            fontSize: 12,
          ),
        ),
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.requestAndroidPermission();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
    categoryController.addDefaultCategories();
    categoryController.getAllCategories();
    taskController.getAllTasks();
    taskController.getTasksCountUnderAllCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initHomePageTour();
    if (!TourAppProvider.homeTourStatus) _showMyHomePageTour();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            key: deleteAllIconKey,
            icon: const Icon(Icons.delete_forever),
            onPressed: showAlertDialogForDeletingTheTasks,
            iconSize: 23,
          ),
          IconButton(
            key: themeKey,
            icon: Icon(
              ThemeProvider.loadThemeFromBox
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: showDialogToChangeAppTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          _addDateBar(),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(
              () {
                List<Task?>? tasksThatAreCompletedorOverDue =
                    taskController.tasks.map((Task task) {
                  DateFormat inputFormat = DateFormat('yyyy/MM/dd hh:mm a');
                  String taskDeadLineAsString = task.deadline!;
                  DateTime taskDeadline =
                      inputFormat.parse(taskDeadLineAsString);
                  if ((!isSameDay(taskDeadline, DateTime.now()) &&
                          taskDeadline.isBefore(DateTime.now())) ||
                      task.isCompleted == 1) return task;
                }).toList();
                tasksThatAreCompletedorOverDue = tasksThatAreCompletedorOverDue
                    .where((element) => element != null)
                    .toList();
                if (taskController.tasks.isEmpty ||
                    (tasksThatAreCompletedorOverDue.isNotEmpty &&
                        tasksThatAreCompletedorOverDue.length ==
                            taskController.tasks.length)) {
                  return noTaskMsg(context, 'Home');
                } else {
                  return showTasks();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: addTaskKey,
        onPressed: () async {
          await Get.off(() => AddorEditTask());
          taskController.getAllTasks();
        },
        child: const Icon(Icons.add),
      ),
      drawer: MyDrawer(categorySelected: 'Home'),
    );
  }

  showAlertDialogForDeletingTheTasks() {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Remove all tasks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            content:
                const Text('Are You Sure you want to delete  all the tasks?'),
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
                      await notifyHelper.cancelAllNotification();
                      await taskController.deleteAllTasks();
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }

  showDialogToChangeAppTheme() {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Change App Theme',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            content: Text(
                'Are You Sure you want to switch to ${Get.isDarkMode ? 'Light' : 'Dark'} Theme?'),
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
                      'Switch',
                      style: GoogleFonts.ubuntuCondensed(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onPressed: () async {
                      await ThemeProvider.switchMode();
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }

  Widget showTasks() {
    return ListView.builder(
      itemCount: taskController.tasks.length,
      itemBuilder: (context, index) {
        final task = taskController.tasks[index];
        String taskDateAsaString = task.dateAdded!;
        DateTime taskDate = DateToFormat.parseStringToDate(taskDateAsaString);
        if (task.hasNotification == 1 && task.isCompleted == 0) {
          notifyHelper.scheduledNotification(task, taskDate);
        }
        return task.isCompleted == 1
            ? Container()
            : DateFormat.yMd().format(_selectedDate) ==
                    DateFormat.yMd().format(taskDate)
                ? InkWell(
                    onLongPress: () async {
                      await Get.to(() => TaskDetailsScreen(task: task));
                      taskController.getAllTasks();
                    },
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (ctx, child) => Padding(
                        padding:
                            EdgeInsets.only(top: 140 - _controller.value * 140),
                        child: child,
                      ),
                      child: TaskTile(task: task),
                    ),
                  )
                : Container();
      },
    );
  }
}

Widget noTaskMsg(BuildContext context, [String? name]) {
  return Stack(children: [
    AnimatedPositioned(
      duration: const Duration(milliseconds: 2000),
      child: SingleChildScrollView(
        child: Wrap(
          direction: SizeConfig.orientation == Orientation.landscape
              ? Axis.horizontal
              : Axis.vertical,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizeConfig.orientation == Orientation.landscape
                ? const SizedBox(height: 6)
                : const SizedBox(height: 220),
            SvgPicture.asset(
              'images/Liste.svg',
              height: 90,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  BlendMode.dstATop),
              semanticsLabel: 'Task',
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Text(
                name == 'Important'
                    ? " You don't have any task marked as Important!"
                    : name == 'Home'
                        ? 'You do not have any tasks yet!\nAdd new tasks to make your day productive.'
                        : name == 'Finished'
                            ? "You don't have any finished tasks!"
                            : name == 'Today'
                                ? "You don't have any tasks for the Day!"
                                : "You don't have any task in this section!",
                textAlign: TextAlign.center,
              ),
            ),
            SizeConfig.orientation == Orientation.landscape
                ? const SizedBox(height: 120)
                : const SizedBox(height: 180),
          ],
        ),
      ),
    ),
  ]);
}

Future<void> showDialogToAddNewList(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  var key = GlobalKey<FormState>();
  String? validation(String? text) {
    bool doesExists = false;
    for (var category in categoryController.categories) {
      print(category.name);
      if (category.name!.toLowerCase() == text!.trim().toLowerCase()) {
        doesExists = true;
      }
    }
    if (doesExists)
      return 'List already Exists!';
    else if (text!.trim().isEmpty) {
      return 'Please Enter a List name!';
    } else if (text.contains(regExp)) {
      return 'Please Enter only Letters and numbers!';
    } else {
      return null;
    }
  }

  void addNewList(String? text) {
    categoryController.addNewCategory(categoryName: text!);
    taskController.getTasksCountUnderAllCategories();
  }

  showSnackBar() {
    Get.showSnackbar(
      GetSnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.surface,
        titleText: Text(
          'Accepted!',
          style: GoogleFonts.ubuntuCondensed().copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        messageText: Text(
          'New List is added Successfully!',
          style: GoogleFonts.ubuntuCondensed().copyWith(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        borderWidth: 2,
        borderColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Add New List',
          style: GoogleFonts.ubuntuCondensed(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Form(
          key: key,
          child: TextFormField(
            validator: validation,
            onSaved: addNewList,
            decoration: const InputDecoration(),
            controller: controller,
            style: GoogleFonts.ubuntuCondensed(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
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
              'Add',
              style: GoogleFonts.ubuntuCondensed(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onPressed: () {
              // Add the new item to your data
              bool isAccepted = false;
              isAccepted = key.currentState!.validate();
              if (isAccepted) {
                key.currentState!.save();
                Get.back();
                Future.delayed(const Duration(milliseconds: 500), showSnackBar);
              }
            },
          ),
        ],
      );
    },
  );
}
