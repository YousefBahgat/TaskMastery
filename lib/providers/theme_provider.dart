import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider {
  //getStorage must be intialized in main
  static final GetStorage _box = GetStorage(); //used to store the theme value.
  static const _key = 'isDarkMode';
  //function to store the new theme value using the key (either true or false);
  static set saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

// first time called the value of the key will be null so return false(default light mode).
  static bool get loadThemeFromBox {
    return _box.read<bool>(_key) ?? false;
  }

//getter for the themeMode Based on the stored bool value in the box.
  static ThemeMode get theme =>
      loadThemeFromBox ? ThemeMode.dark : ThemeMode.light;
  //change the theme using get, and switch the theme bool value stored in the box
  static switchMode() {
    Get.changeThemeMode(loadThemeFromBox ? ThemeMode.light : ThemeMode.dark);
    saveThemeToBox = !loadThemeFromBox;
  }
}
