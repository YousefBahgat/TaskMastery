import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

class TourAppProvider {
  static final GetStorage _box = GetStorage();
  static const _homeKey = 'isHomeTourFinished';
  static const _taskTileKey = 'isTaskTileTourFinished';
  static const _addTaskKey = 'isAddTaskTourFinished';
  static const _drawerKey = 'isDrawerTourFinished';
  static const _taskDetailsKey = 'isTaskDetailsPageTourFinished';
  static const _taskUnderListKey = 'isTaskUnderListTourFinished';
  static const _isAllFinishedKey = 'isAllToursFinished';
  //------home page tour------
  static set saveHomePageTourStatusToBox(bool isFinishd) =>
      _box.write(_homeKey, isFinishd);
  static bool get loadHomePageTourStatusBox {
    return _box.read<bool>(_homeKey) ?? false;
  }

  static bool get homeTourStatus => loadHomePageTourStatusBox ? true : false;
  //-----task tile tour------
  static set saveTaskTileTourStatusToBox(bool isFinishd) =>
      _box.write(_taskTileKey, isFinishd);
  static bool get loadTaskTileTourStatusBox {
    return _box.read<bool>(_taskTileKey) ?? false;
  }

  static bool get taskTileStatus => loadTaskTileTourStatusBox ? true : false;
  //-----add task page tour------
  static set saveAddTaskPageTourStatusToBox(bool isFinishd) =>
      _box.write(_addTaskKey, isFinishd);
  static bool get loadAddTaskPageTourStatusBox {
    return _box.read<bool>(_addTaskKey) ?? false;
  }

  static bool get addtaskStatus => loadAddTaskPageTourStatusBox ? true : false;
  //-----drawer tour------
  static set saveDrawerTourStatusToBox(bool isFinishd) =>
      _box.write(_drawerKey, isFinishd);
  static bool get loadDrawerTourStatusBox {
    return _box.read<bool>(_drawerKey) ?? false;
  }

  static bool get drawerStatus => loadDrawerTourStatusBox ? true : false;
  //-----task details page tour------
  static set saveTaskDetailsPageTourStatusToBox(bool isFinishd) =>
      _box.write(_taskDetailsKey, isFinishd);
  static bool get loadTaskDetailsPageTourStatusBox {
    return _box.read<bool>(_taskDetailsKey) ?? false;
  }

  static bool get taskDetailsStatus =>
      loadTaskDetailsPageTourStatusBox ? true : false;
  //-----task under list page tour------
  static set saveTaskUnderListPageTourStatusToBox(bool isFinishd) =>
      _box.write(_taskUnderListKey, isFinishd);
  static bool get loadTaskUnderListPageTourStatusBox {
    return _box.read<bool>(_taskUnderListKey) ?? false;
  }

  static bool get taskUnderListStatus =>
      loadTaskUnderListPageTourStatusBox ? true : false;

  //----check if all tours are finished or not to change the prefferd ortienation--------------

  static bool get loadAllFinishedToursStatusBox {
    return _box.read<bool>(_isAllFinishedKey) ?? false;
  }

  static checkIfAllFinished() {
    if (homeTourStatus &&
        taskTileStatus &&
        drawerStatus &&
        taskDetailsStatus &&
        taskUnderListStatus) {
      _box.write(_isAllFinishedKey, true);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    } else {
      _box.write(_isAllFinishedKey, false);
    }
  }

  static bool get allFinishedStatus =>
      loadAllFinishedToursStatusBox ? true : false;
}
