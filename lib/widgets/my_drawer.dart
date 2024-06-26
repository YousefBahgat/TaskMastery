import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../controllers/task_controller.dart';
import '../models/category_model.dart';
import '../providers/tour_app_provider.dart';
import '../screens/task_list_screen.dart' as main;
import '../screens/tasks_under_list_screen.dart';
import '../services/app_tour_services.dart';

class MyDrawer extends StatefulWidget {
  MyDrawer({super.key, this.categorySelected});
  String? categorySelected;

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late List<Category> categories;
  final expansionTileController = ExpansionTileController();

  final TaskController _taskController = Get.put(TaskController());

  //define Global keys for the app tour
  final todayKey = GlobalKey();

  final importantKey = GlobalKey();

  final finishedKey = GlobalKey();

  final listsKey = GlobalKey();

  final addListKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  //intialize my app tour for this page
  void _initDrawerTour(BuildContext context) {
    tutorialCoachMark = TutorialCoachMark(
      targets: drawerTargets(
        todayKey: todayKey,
        importantKey: importantKey,
        finishedKey: finishedKey,
        listsKey: listsKey,
        addListkey: addListKey,
      ),
      hideSkip: true,
      paddingFocus: 10,
      useSafeArea: true,
      colorShadow: Theme.of(context).colorScheme.secondary,
      opacityShadow: 0.93,
      onFinish: () {
        //save status to show tour only in the first time
        if (!TourAppProvider.loadDrawerTourStatusBox) {
          TourAppProvider.saveDrawerTourStatusToBox = true;
          TourAppProvider.checkIfAllFinished();
        }
      },
    );
  }

  void _showDrawerTour(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      tutorialCoachMark.show(context: context);
    });
  }

  @override
  void initState() {
    super.initState();
    _taskController.getTasksCountUnderAllCategories();
    main.categoryController.getAllCategories();
    main.categoryController.categories
        .sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    categories = main.categoryController.categories.toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initDrawerTour(context);
    if (!TourAppProvider.drawerStatus) _showDrawerTour(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            _myDrawerHeader(context),
            Container(
              color: widget.categorySelected == 'Home'
                  ? Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.8)
                  : Theme.of(context).colorScheme.surface,
              child: _myListTile(context, () {
                Get.offAll(() => const main.HomeScreen());
              }, 'Home', Icons.home),
            ),
            Container(
              key: todayKey,
              color: widget.categorySelected == 'Today'
                  ? Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.8)
                  : Theme.of(context).colorScheme.surface,
              child: _myListTile(context, () {
                Get.off(
                  () => TasksUnderAListScreen(categoryName: 'Today'),
                  preventDuplicates: false,
                );
              }, 'Today', Icons.today_rounded),
            ),
            Container(
              key: importantKey,
              color: widget.categorySelected == 'Important'
                  ? Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.8)
                  : Theme.of(context).colorScheme.surface,
              child: _myListTile(context, () {
                Get.off(
                  () => TasksUnderAListScreen(categoryName: 'Important'),
                  preventDuplicates: false,
                );
              }, 'Important', Icons.star),
            ),
            Container(
              key: finishedKey,
              color: widget.categorySelected == 'Finished'
                  ? Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.8)
                  : Theme.of(context).colorScheme.surface,
              child: _myListTile(context, () {
                Get.off(
                  () => TasksUnderAListScreen(categoryName: 'Finished'),
                  preventDuplicates: false,
                );
              }, 'Finished', Icons.done),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor:
                    Colors.transparent, // Removes the divider when expanded
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ExpansionTile(
                      controller: expansionTileController,
                      onExpansionChanged: (value) {
                        setState(() {
                          _taskController.getTasksCountUnderAllCategories();
                          main.categoryController.getAllCategories();
                          main.categoryController.categories.sort((a, b) => a
                              .name!
                              .toLowerCase()
                              .compareTo(b.name!.toLowerCase()));
                          categories =
                              main.categoryController.categories.toList();
                        });
                      },
                      key: listsKey,
                      title: const Text('Your Lists'),
                      leading: const Icon(Icons.list_alt_sharp),
                      childrenPadding: const EdgeInsets.only(left: 20.0),
                      children: categories.map((Category category) {
                        Widget trailingWidget = _taskController
                                    .numberOfTasksUnderEachCategory.isEmpty ||
                                _taskController.numberOfTasksUnderEachCategory
                                        .length !=
                                    categories.length
                            ? const CircularProgressIndicator()
                            : Text(_taskController
                                .numberOfTasksUnderEachCategory[
                                    categories.indexOf(category)]
                                .toString());
                        return Container(
                          color: widget.categorySelected == category.name
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.8)
                              : Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            leading: const Icon(Icons.list_rounded),
                            title: Text(category.name!),
                            trailing: trailingWidget,
                            onTap: () {
                              Get.off(
                                  () => TasksUnderAListScreen(
                                      categoryName: category.name!),
                                  preventDuplicates: false);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18, right: 15),
                    child: GestureDetector(
                      onTap: () async {
                        await main.showDialogToAddNewList(context);

                        setState(() {
                          expansionTileController.collapse();
                          _taskController.getTasksCountUnderAllCategories();
                          main.categoryController.getAllCategories();
                          main.categoryController.categories.sort((a, b) => a
                              .name!
                              .toLowerCase()
                              .compareTo(b.name!.toLowerCase()));
                          categories =
                              main.categoryController.categories.toList();
                        });
                      },
                      child: Icon(
                        key: addListKey,
                        Icons.add,
                        size: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              // Add other ListTile widgets as needed
            ),
          ],
        ),
      ),
    );
  }

  DrawerHeader _myDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Header background color
      ),
      child: Row(
        children: [
          Icon(
            Icons.all_inbox, // Replace with your desired icon
            size: 48.0,
            color: Theme.of(context).colorScheme.onPrimary, // Icon color
          ),
          const SizedBox(width: 18.0), // Spacing between icon and text
          Text(
            'Tasks',
            style: GoogleFonts.ubuntuCondensed(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).colorScheme.onPrimary, // Header text color
            ),
          ),
        ],
      ),
    );
  }

  ListTile _myListTile(
      BuildContext context, Function()? ontap, String text, IconData myIcon) {
    return ListTile(
      leading: Icon(myIcon,
          color: Theme.of(context).colorScheme.onSurface), // Icon color
      title: Text(
        text,
        style: GoogleFonts.ubuntuCondensed().copyWith(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color:
              Theme.of(context).colorScheme.onSurface, // List tile text color
        ),
      ),
      onTap: ontap,
    );
  }
}



 /* FutureBuilder<int>(
                          future: _taskController
                              .getTasksCountUnderThisCategory(category.name!),
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            Widget trailingWidget;

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              trailingWidget =
                                  const CircularProgressIndicator(); // Show loading indicator while waiting
                            } else if (snapshot.hasError) {
                              trailingWidget = const Text(
                                  'Error'); // Show error if something went wrong
                            } else if (snapshot.hasData) {
                              trailingWidget = Text(
                                  '${snapshot.data}'); // Display the task count
                            } else {
                              trailingWidget = const Text(
                                  'No data'); // Handle the case where there's no data
                            }

                           
                          },
                        ); */