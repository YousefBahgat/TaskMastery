import 'package:sqflite/sqflite.dart';
import 'package:todo_app/models/category_model.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static const _databaseName = 'todoAppData._database';
  static const _databaseVersion = 5;

  static const tableTasks = 'tasks';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnDateAdded = 'dateAdded';
  static const columnDeadline = 'deadline';
  static const columnIsVeryUrgent = 'isVeryUrgent';
  static const columnIsCompleted = 'isCompleted';
  static const columnHasNotification = 'hasNotification';
  static const columnRemind = 'remind';
  static const columnTaskCategoryName = 'category';
  static const tableCategories = 'categories';
  static const columnCategoryName = 'name';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static Future<Database> get database async {
    if (_database != null) {
      print('Database already exists');
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  static _initDatabase() async {
    print('Database is beening intialized');
    String path = '${await getDatabasesPath()}/$_databaseName';
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version) async {
    print('Tables are beening created');
    await db.execute('''
      CREATE TABLE $tableCategories (
        $columnCategoryName TEXT PRIMARY KEY
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTasks (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnDateAdded TEXT NOT NULL,
        $columnDeadline TEXT NOT NULL,
        $columnIsVeryUrgent INTEGER NOT NULL,
        $columnIsCompleted INTEGER NOT NULL,
        $columnHasNotification INTEGER NOT NULL,
        $columnRemind INTEGER NOT NULL,
        $columnTaskCategoryName TEXT,
        FOREIGN KEY ($columnTaskCategoryName) REFERENCES $tableCategories ($columnCategoryName)
      )
    ''');
    print('table has been created');
  }

  static Future<List<Map<String, dynamic>>> getTasksByCategory(
      String categoryName) async {
    print('Tasks is being fetched by category name');
    return await _database!.query(tableTasks,
        where: '$columnTaskCategoryName = ?', whereArgs: [categoryName]);
  }

/*   static Future<int> getTaskCountByCategory(String categoryName) {
    print('Count of tasks is being fetched by category name');
    return _database!.rawQuery(
      'SELECT COUNT(*) FROM $tableTasks WHERE $columnTaskCategoryName = ?',
      [categoryName],
    ).then((List<Map<String, dynamic>> result) {
      return Sqflite.firstIntValue(result) ?? 0;
    });
  } */

  static Future<int> getTaskCountByCategory(String categoryName) {
    print('Count of incomplete tasks is being fetched by category name');
    return _database!.rawQuery(
      'SELECT COUNT(*) FROM $tableTasks WHERE $columnTaskCategoryName = ? AND $columnIsCompleted = 0',
      [categoryName],
    ).then((List<Map<String, dynamic>> result) {
      return Sqflite.firstIntValue(result) ?? 0;
    });
  }

  static Future<int> insertTask(Task task) async {
    print('in the insert task function');
    return await _database!.insert(tableTasks, task.toJson());
  }

  static Future<int> updateTask(Map<String, dynamic> row, int id) async {
    print('in the update task function');
    return await _database!
        .update(tableTasks, row, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> deleteTask(int id) async {
    print('in the delete task function');
    return await _database!
        .delete(tableTasks, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> insertCategory(String categoryName) async {
    print('in the insert category function');
    return await _database!
        .insert(tableCategories, {columnCategoryName: categoryName});
  }

  static Future<void> insertCategoriesIfEmpty(List<Category> categories) async {
    print('in the insert categories if the table is empty function');
    int? count = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM $tableCategories'));
    if (count == 0) {
      print('no item in the category list');
      for (var category in categories) {
        await _database!
            .insert(tableCategories, {columnCategoryName: category.name});
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getAllTasks() async {
    print('in the get all tasks table');
    return await _database!.query(tableTasks);
  }

  static Future<int> deleteAllTasks() async {
    print('in the delete all tasks table');
    return await _database!.delete(tableTasks);
  }

  static Future<int> deleteCategoryAndTasks(String categoryName) async {
    print('in the delete category and all the task inside it function');
    await _database!.delete(tableTasks,
        where: '$columnTaskCategoryName = ?', whereArgs: [categoryName]);
    return await _database!.delete(tableCategories,
        where: '$columnCategoryName = ?', whereArgs: [categoryName]);
  }

  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    print('in the get all categories function');
    return await _database!.query(tableCategories);
  }

  static Future<int> updateTaskCompletion(int taskId, int isCompleted) async {
    print('in the update task completion function');
    return await _database!.update(
      tableTasks,
      {'isCompleted': isCompleted},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  static Future<int> switchTaskisVeryUrgentStatus(
      int taskId, int isUrgent) async {
    print('in the update task important level function');
    return await _database!.update(
      tableTasks,
      {columnIsVeryUrgent: isUrgent},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}
