import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> homePageTargets({
  required GlobalKey themeKey,
  required GlobalKey addTaskKey,
  required GlobalKey deleteAllTasksKey,
}) {
  List<TargetFocus> targets = [];
  targets.add(
    _myTargetFocus(addTaskKey, 'Tap here to add a new task'),
  );
  targets.add(
    _myTargetFocus(
      deleteAllTasksKey,
      'Tap here to delete all your tasks',
      ContentAlign.custom,
    ),
  );
  targets.add(
    _myTargetFocus(
      themeKey,
      'Tap here to switch the app theme between Dark & light',
      ContentAlign.custom,
    ),
  );

  return targets;
}

List<TargetFocus> taskTileTargets({
  required GlobalKey checkBoxkey,
  required GlobalKey taskTileKey,
  required GlobalKey favoriteKey,
}) {
  List<TargetFocus> targets = [];
  targets.add(
    _myTargetFocus(
      taskTileKey,
      'This is your task, Long-press to display your task Details',
      ContentAlign.bottom,
    ),
  );
  targets.add(
    _myTargetFocus(
      checkBoxkey,
      'Check here to mark the task as completed',
      ContentAlign.bottom,
    ),
  );
  targets.add(
    _myTargetFocus(
      favoriteKey,
      'Switch the task to Important or Vice Versa ',
      ContentAlign.bottom,
    ),
  );

  return targets;
}

List<TargetFocus> addTaskPageTargets({
  required GlobalKey durationKey,
  required GlobalKey listKey,
  required GlobalKey addNewList,
  required GlobalKey notifyKey,
  required GlobalKey favoriteKey,
  required GlobalKey remindKey,
  required GlobalKey titleKey,
  required GlobalKey noteKey,
  required GlobalKey dateKey,
  required GlobalKey addKey,
}) {
  List<TargetFocus> targets = [];
  targets.add(
    _myTargetFocus(
      titleKey,
      'Enter your task title',
      ContentAlign.bottom,
    ),
  );
  targets.add(
    _myTargetFocus(
      noteKey,
      'Enter your task details',
      ContentAlign.bottom,
    ),
  );
  targets.add(
    _myTargetFocus(
      dateKey,
      'Set the task date and start time',
      ContentAlign.bottom,
    ),
  );
  targets.add(
    _myTargetFocus(
      durationKey,
      'Choose the task duration',
      ContentAlign.top,
    ),
  );
  targets.add(
    _myTargetFocus(
      listKey,
      'Add the task to a list',
      ContentAlign.top,
    ),
  );
  targets.add(
    _myTargetFocus(
      addNewList,
      'Create new list',
    ),
  );
  targets.add(
    _myTargetFocus(
      notifyKey,
      'Check the box if you want to receive a notification',
      ContentAlign.top,
    ),
  );
  targets.add(
    _myTargetFocus(
      remindKey,
      'Choose task reminder time',
      ContentAlign.top,
    ),
  );
  targets.add(
    _myTargetFocus(
      favoriteKey,
      'Mark the task as important',
      ContentAlign.custom,
    ),
  );
  targets.add(
    _myTargetFocus(
      addKey,
      'Add the task to your tasks list',
    ),
  );

  return targets;
}

List<TargetFocus> drawerTargets({
  required GlobalKey todayKey,
  required GlobalKey importantKey,
  required GlobalKey addListkey,
  required GlobalKey listsKey,
  required GlobalKey finishedKey,
}) {
  List<TargetFocus> targets = [];
  targets.add(
    _myTargetFocus(
      todayKey,
      'Check your tasks for the day',
      ContentAlign.bottom,
    ),
  );
  targets.add(
    _myTargetFocus(
      importantKey,
      'Follow up on your important tasks.',
      ContentAlign.bottom,
    ),
  );
  targets.add(
    _myTargetFocus(
      finishedKey,
      'Tap here to see all the tasks marked as completed.',
      ContentAlign.top,
    ),
  );
  targets.add(
    _myTargetFocus(
      listsKey,
      'Here you can find all your lists. and all the tasks under each list, Choose a list for more details.',
      ContentAlign.top,
    ),
  );
  targets.add(
    _myTargetFocus(
      addListkey,
      'Create a new List',
      ContentAlign.top,
    ),
  );
  return targets;
}

List<TargetFocus> taskDetailsTargets({
  required GlobalKey editKey,
  required GlobalKey deleteKey,
}) {
  List<TargetFocus> targets = [];
  targets.add(
    _myTargetFocus(
      editKey,
      'Tap here to edit your task',
      ContentAlign.bottom,
    ),
  );
  targets.add(
    _myTargetFocus(
      deleteKey,
      'Tap here to delete the task',
      ContentAlign.bottom,
    ),
  );
  return targets;
}

List<TargetFocus> taskUnderListPageTargets({
  required GlobalKey deleteListKey,
}) {
  List<TargetFocus> targets = [];
  targets.add(
    _myTargetFocus(
      deleteListKey,
      'Tap here to delete the list and all the tasks under it',
      ContentAlign.bottom,
    ),
  );
  return targets;
}

TargetFocus _myTargetFocus(GlobalKey key, String content,
    [ContentAlign align = ContentAlign.left]) {
  return TargetFocus(
    enableOverlayTab: true,
    keyTarget: key,
    //alignSkip: Alignment.topLeft,
    radius: 10,
    shape: ShapeLightFocus.RRect,
    contents: [
      TargetContent(
        align: align,
        customPosition:
            CustomTargetContentPosition(top: 180, right: 10, left: 10),
        builder: (context, controller) {
          return Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}
