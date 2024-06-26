import 'package:get/get.dart';
import 'package:todo_app/database/db_helper.dart';
import 'package:todo_app/models/task_model.dart';
import '../models/category_model.dart';
import '../screens/task_list_screen.dart' as main;

class TaskController extends GetxController {
  RxList<Task> tasks = <Task>[].obs;
  List<Task> test = [];
  List<int> numberOfTasksUnderEachCategory = [];

  Future<int> addTask(Task task) async {
    return await DatabaseHelper.insertTask(task);
  }

  void updateTask(Task task) async {
    await DatabaseHelper.updateTask(task.toJson(), task.id!);
    await getAllTasks();
  }

  Future<void> getAllTasks() async {
    List<Map<String, dynamic>> tasksRetrived =
        await DatabaseHelper.getAllTasks();
    tasks.assignAll(tasksRetrived
        .map((taskinJsonForm) => Task.fromJson(taskinJsonForm))
        .toList());
    test = tasks;
  }

  Future deleteAllTasks() async {
    await DatabaseHelper.deleteAllTasks();
    await getAllTasks();
  }

  Future deleteTask(Task task) async {
    await DatabaseHelper.deleteTask(task.id!);
    await getAllTasks();
  }

  Future markedAsCompleted(int id, int isCompleted) async {
    await DatabaseHelper.updateTaskCompletion(id, isCompleted);
    await getAllTasks();
  }

  Future isVeryUrgentChange(int id, int isUrgent) async {
    await DatabaseHelper.switchTaskisVeryUrgentStatus(id, isUrgent);
    await getAllTasks();
  }

  Future<List<Task>> getAllTasksUnderThisCategory(String categoryName) async {
    List<Map<String, dynamic>> tasksRetrived =
        await DatabaseHelper.getTasksByCategory(categoryName);
    List<Task> tasksUnderTheList = tasksRetrived
        .map((taskinJsonForm) => Task.fromJson(taskinJsonForm))
        .toList();
    return tasksUnderTheList;
  }

  Future<int> getTasksCountUnderThisCategory(String categoryName) async {
    int tasksCountUnderTheList =
        await DatabaseHelper.getTaskCountByCategory(categoryName);
    return tasksCountUnderTheList;
  }

  Future getTasksCountUnderAllCategories() async {
    await main.categoryController.getAllCategories();
    main.categoryController.categories
        .sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    final categories = main.categoryController.categories.toList();
    numberOfTasksUnderEachCategory =
        await Future.wait(categories.map((Category category) async {
      return await getTasksCountUnderThisCategory(category.name!);
    }).toList());
  }
}

/*
List<Task> tasks = [
    Task(
      category: 'Personal',
      id: 0,
      title: 'Task1',
      description:
          'Veniam irure et laborum laborum do dolore quis adipisicing eiusmod. Exercitation consectetur pariatur cillum exercitation dolore qui dolor irure. Occaecat dolor do sunt sint amet occaecat aute consectetur. Consectetur consequat sunt do officia amet commodo nisi in incididunt magna cupidatat laboris excepteur. Commodo Lorem qui excepteur reprehenderit Lorem eiusmod. Cupidatat ipsum sit dolor proident. Quis exercitation minim ullamco culpa aliqua aliqua enim minim ad amet in nulla nisi pariatur.',
      dateAdded: DateTime.now().toString(),
      deadline: DateTime.now().add(const Duration(minutes: 15)).toString(),
      isVeryUrgent: 1,
      hasNotification: 1,
      isCompleted: 0,
      remind: 5,
    ),
    Task(
      category: 'Work',
      id: 0,
      title: 'Task2',
      description:
          'Reprehenderit aliquip ullamco esse officia ad Lorem. Exercitation enim sint exercitation enim. Laborum adipisicing mollit minim magna Lorem anim cillum nostrud officia.',
      dateAdded: DateTime.now().toString(),
      deadline: DateTime.now().add(const Duration(minutes: 20)).toString(),
      isVeryUrgent: 0,
      hasNotification: 0,
      isCompleted: 0,
      remind: 0,
    ),
  ]; */
