import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as date;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
//import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/category_model.dart';

import '../models/task_model.dart';
//import '../providers/tour_app_provider.dart';
//import '../services/app_tour_services.dart';
import '../size_config.dart';
import 'task_list_screen.dart' as main;
import '../widgets/input_feild.dart';
import 'task_list_screen.dart';

final regExp = RegExp(
    r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+=' // <-- Notice the escaped symbols
    "'" // <-- ' is added to the expression
    ']');

class AddorEditTask extends StatefulWidget {
  AddorEditTask({
    super.key,
    this.task,
  });
  Task? task;
  @override
  State<AddorEditTask> createState() => _AddorEditTaskState();
}

extension StringExtensions on String {
  String capitalizeFirstLetter() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class _AddorEditTaskState extends State<AddorEditTask> {
  SizeConfig sizeConfig = SizeConfig();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool edit;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final TextEditingController _dateController = TextEditingController();
  late DateTime _selectedDate;
  late List<Category> categories;
  late bool notify;
  late bool isUrgent;
  late int _selectedDuration;
  late String _selectedCategory;
  late int _selectedRemind;
  DateFormat inputFormat = DateFormat('yyyy/MM/dd hh:mm a');
  List<int> remindList = [5, 10, 15, 20];
  List<int> durationList = [10, 20, 30, 40, 50, 60, 2, 3, 4, 5, 6];
  //---------------
  /*  final durationKey = GlobalKey();
  final listKey = GlobalKey();
  final addNewList = GlobalKey();
  final notifyKey = GlobalKey();
  final favoriteKey = GlobalKey();
  final remindKey = GlobalKey();
  final addKey = GlobalKey();
  final titlekey = GlobalKey();
  final noteKey = GlobalKey();
  final dateKey = GlobalKey(); */
  //--------------
  /*  late TutorialCoachMark tutorialCoachMark;
  //intialize my app tour for this page
  void _initAddTaskPageTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: addTaskPageTargets(
          addKey: addKey,
          addNewList: addNewList,
          dateKey: dateKey,
          listKey: listKey,
          notifyKey: notifyKey,
          noteKey: noteKey,
          titleKey: titlekey,
          remindKey: remindKey,
          favoriteKey: favoriteKey,
          durationKey: durationKey),
      hideSkip: true,
      paddingFocus: 10,
      useSafeArea: true,
      colorShadow: Theme.of(context).colorScheme.secondary,
      opacityShadow: 0.93,
      onFinish: () {
        //save status to show tour only in the first time
        if (!TourAppProvider.loadAddTaskPageTourStatusBox) {
          TourAppProvider.saveAddTaskPageTourStatusToBox = true;
          TourAppProvider.checkIfAllFinished();
        }
      },
    );
  }

  void _showAddTaskPageTour() {
    Future.delayed(const Duration(seconds: 2), () {
      tutorialCoachMark.show(context: context);
    });
  } */

  @override
  void initState() {
    super.initState();
    main.categoryController.getAllCategories();
    main.categoryController.categories
        .sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    categories = main.categoryController.categories.toList();

    edit = widget.task == null ? false : true;
    _titleController =
        TextEditingController(text: edit ? widget.task!.title : null);
    _contentController =
        TextEditingController(text: edit ? widget.task!.description : null);
    if (edit) {
      DateTime taskDate = inputFormat.parse(widget.task!.dateAdded!);
      _selectedDate = taskDate;
      _dateController.text = inputFormat.format(_selectedDate);
      DateTime startTime = inputFormat.parse(widget.task!.dateAdded!);
      DateTime endTime = inputFormat.parse(widget.task!.deadline!);

      int taskDuration = endTime.difference(startTime).inMinutes;
      if (taskDuration > 60) {
        _selectedDuration = taskDuration ~/ 60;
      } else {
        _selectedDuration = taskDuration;
      }

      _selectedCategory = widget.task!.category!;
      if (widget.task!.hasNotification == 1) {
        _selectedRemind = widget.task!.remind!;
        notify = true;
      } else {
        _selectedRemind = 5;
        notify = false;
      }
      isUrgent = widget.task!.isVeryUrgent == 0 ? false : true;
    } else {
      notify = false;
      isUrgent = false;
      _selectedDate = DateTime.now();
      _dateController.text = inputFormat.format(_selectedDate);
      _selectedDuration = 10;
      _selectedCategory = 'General';
      _selectedRemind = 5;
    }
  }

  /*  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAddTaskPageTour();
    if (!TourAppProvider.addtaskStatus) _showAddTaskPageTour();
  } */

  @override
  dispose() {
    _dateController.dispose();
    //_taskController.dispose();
    _contentController.dispose();
    //_listController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    main.categoryController.getAllCategories();
    main.categoryController.categories
        .sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    categories = main.categoryController.categories.toList();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(context),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Container(
                    //key: titlekey,
                    child: MyTextFormField(
                      validation: _formValidation,
                      title: 'Title',
                      hint: 'Enter the task title...',
                      controller: _titleController,
                      prefixIcon: const Icon(Icons.title_rounded),
                    ),
                  ),
                  Container(
                    //key: noteKey,
                    child: MyTextFormField(
                      title: 'Note',
                      validation: _formValidation,
                      hint: 'Enter Task Description...',
                      controller: _contentController,
                      prefixIcon: const Icon(Icons.description_rounded),
                    ),
                  ),
                  Container(
                    // key: dateKey,
                    child: MyTextFormField(
                      controller: _dateController,
                      title: 'Date',
                      hint: DateFormat.yMd().format(_selectedDate),
                      suffixIcon: IconButton(
                        onPressed: _getDateandStartTimeFromUser,
                        icon: const Icon(Icons.date_range_rounded),
                      ),
                    ),
                  ),
                  _buildDurationDropDownButton(context),
                  _buildCategorySelectionDropDownButton(context),
                  _mycheckBox(context),
                  _buildRemindDropDownButton(context),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          //key: addKey,
          onPressed: () {
            bool isAccepted = false;
            isAccepted = _formKey.currentState!.validate();
            if (isAccepted) {
              _formOnSaved();
            }
          },
          child: const Icon(Icons.check),
        ),
      ),
    );
  }

  Container _buildRemindDropDownButton(BuildContext context) {
    return Container(
      width: getProportionateScreenWidth(SizeConfig.screenWidth),
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      padding: const EdgeInsets.only(left: 3, right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Remind:',
            style: GoogleFonts.ubuntuCondensed(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 15),
          DropdownButton(
            //key: remindKey,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: GoogleFonts.ubuntuCondensed(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            hint: Text('$_selectedRemind Minutes Early'),
            dropdownColor: Theme.of(context).colorScheme.surface,
            itemHeight: 50,
            items: [
              ...remindList.map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item.toString()),
                ),
              ),
            ],
            onChanged: notify == true
                ? (int? newSelectedItem) {
                    setState(() {
                      _selectedRemind = newSelectedItem!;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Container _buildCategorySelectionDropDownButton(BuildContext context) {
    return Container(
      width: getProportionateScreenWidth(SizeConfig.screenWidth),
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      padding: const EdgeInsets.only(left: 3, right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Add To List:',
            style: GoogleFonts.ubuntuCondensed(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton(
            // key: listKey,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: GoogleFonts.ubuntuCondensed(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            hint: Text(_selectedCategory),
            dropdownColor: Theme.of(context).colorScheme.surface,
            itemHeight: 50,
            items: [
              ...categories.map(
                (item) => DropdownMenuItem(
                  value: item.name,
                  child: Text(item.name!),
                ),
              ),
            ],
            onChanged: (newSelectedItem) {
              setState(() {
                print(newSelectedItem);
                _selectedCategory = newSelectedItem!;
              });
            },
          ),
          IconButton(
            //key: addNewList,
            icon: Icon(
              Icons.format_list_bulleted_add,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => showDialogToAddNewList(context),
          ),
        ],
      ),
    );
  }

  Container _buildDurationDropDownButton(BuildContext context) {
    return Container(
      width: getProportionateScreenWidth(SizeConfig.screenWidth),
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      padding: const EdgeInsets.only(left: 3, right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
      ),
      child: Row(
        //key: durationKey,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Duration:',
            style: GoogleFonts.ubuntuCondensed(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 15),
          DropdownButton(
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: GoogleFonts.ubuntuCondensed(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            hint: Text(_selectedDuration < 10
                ? '$_selectedDuration hours'
                : '$_selectedDuration Minutes'),
            dropdownColor: Theme.of(context).colorScheme.surface,
            itemHeight: 50,
            items: [
              ...durationList.map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                      '${item.toString()} ${item < 10 ? 'hours' : 'Minutes'}'),
                ),
              ),
            ],
            onChanged: (int? newSelectedItem) {
              setState(() {
                print(newSelectedItem);
                _selectedDuration = newSelectedItem!;
              });
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(edit ? 'Edit Task' : 'Add New Task'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (!edit) {
            Get.off(() => const main.HomeScreen());
          } else {
            Get.back();
          }
        },
      ),
      actions: [
        IconButton(
          // key: favoriteKey,
          onPressed: () {
            setState(() {
              isUrgent = !isUrgent;
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isUrgent
                      ? 'Marked as an Important Task!'
                      : 'Task is no longer important.'),
                ),
              );
            });
          },
          icon: AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween<double>(begin: 0.9, end: 1).animate(animation),
                child: child,
              );
            },
            child: Icon(
              isUrgent ? Icons.star : Icons.star_border_outlined,
              color: Colors.amber.withOpacity(0.65),
              key: ValueKey(isUrgent),
            ),
          ),
        ),
      ],
    );
  }

  void _formOnSaved() {
    if (edit) {
      // edit the task
      Task updatedTask = Task(
        id: widget.task!.id,
        category: _selectedCategory,
        title: _titleController.text,
        description: _contentController.text,
        dateAdded: inputFormat.format(_selectedDate),
        deadline: _calculateDeadLine(),
        isVeryUrgent: isUrgent ? 1 : 0,
        hasNotification: notify ? 1 : 0,
        remind: notify ? _selectedRemind : 0,
        isCompleted: 0,
      );
      main.taskController.updateTask(updatedTask);
      Get.back(result: updatedTask);
    } else {
      // add new task
      main.taskController.addTask(
        Task(
          isCompleted: 0,
          category: _selectedCategory,
          title: _titleController.text,
          description: _contentController.text,
          dateAdded: inputFormat.format(_selectedDate),
          deadline: _calculateDeadLine(),
          isVeryUrgent: isUrgent ? 1 : 0,
          hasNotification: notify ? 1 : 0,
          remind: notify ? _selectedRemind : 0,
        ),
      );
      Get.off(() => const main.HomeScreen());
    }
  }

  String _calculateDeadLine() {
    if (_selectedDuration < 10) {
      return inputFormat.format(
        _selectedDate.add(
          Duration(hours: _selectedDuration),
        ),
      );
    } else {
      return inputFormat.format(
        _selectedDate.add(
          Duration(minutes: _selectedDuration),
        ),
      );
    }
  }

  String? _formValidation(String? text) {
    if (text!.trim().isEmpty)
      return 'This Field is Required!';
    else if (_titleController.text.trim() == text.trim() &&
        text.trim().contains(regExp)) {
      return "Title shouldn't contain any special characters!";
    } else {
      return null;
    }
  }

  _getDateandStartTimeFromUser() async {
    DateTime? pickedDateTime = await date.DatePicker.showDateTimePicker(
      context,
      currentTime: DateTime.now(),
    );
    if (pickedDateTime != null) {
      setState(() {
        _selectedDate = pickedDateTime;
        _dateController.text =
            DateFormat('yyyy/MM/dd hh:mm a').format(_selectedDate);
        print(pickedDateTime);
      });
    }
  }

  Container _mycheckBox(BuildContext context) {
    return Container(
        // key: notifyKey,
        width: getProportionateScreenWidth(SizeConfig.screenWidth),
        margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notification_add),
            const SizedBox(width: 1),
            Text(
              'Notify',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                shape: RoundedRectangleBorder(
                    side:
                        BorderSide(color: Colors.blueAccent.shade400, width: 2),
                    borderRadius: BorderRadius.circular(5)),
                value: notify,
                onChanged: (bool? newValue) {
                  setState(() {
                    notify = newValue!;
                  });
                },
              ),
            ),
          ],
        ));
  }
}
