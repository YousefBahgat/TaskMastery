import 'package:get/get.dart';
import 'package:todo_app/database/db_helper.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  List<Category> categories = <Category>[].obs;
  List<Category> defaultCategories = <Category>[
    Category(name: 'General'),
    Category(name: 'Personal'),
    Category(name: 'Work'),
    Category(name: 'Courses'),
    Category(name: 'Communication'),
    Category(name: 'Entertainment'),
    Category(name: 'Financial'),
    Category(name: 'Collaboration'),
    Category(name: 'Organization'),
  ];

  addDefaultCategories() async {
    await DatabaseHelper.insertCategoriesIfEmpty(defaultCategories);
    await getAllCategories();
  }

  Future deleteCategoryandTasksUnderIt(String categoryName) async {
    await DatabaseHelper.deleteCategoryAndTasks(categoryName);
    await getAllCategories();
  }

  Future getAllCategories() async {
    List<Map<String, dynamic>> retrivedCategories =
        await DatabaseHelper.getAllCategories();
    categories.assignAll(retrivedCategories.map((categoryinJsonForm) {
      //print(categoryinJsonForm);
      return Category.fromjson(categoryinJsonForm);
    }).toList());
  }

  addNewCategory({required String categoryName}) async {
    await DatabaseHelper.insertCategory(categoryName);
    await getAllCategories();
  }

  void deleteCategory(String categoryName) async {
    await DatabaseHelper.deleteCategoryAndTasks(categoryName);
    getAllCategories();
  }
}
