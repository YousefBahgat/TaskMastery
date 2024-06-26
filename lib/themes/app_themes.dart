import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color color1 = const Color(0xFFE4E6D9);
Color color2 = const Color(0xFFC0CFB2); // Corrected Hexadecimal Value
Color color3 = const Color(0xFF6D8777);
Color color4 = const Color(0xFF45624E);
Color color5 = const Color(0xFF273526);

ColorScheme createColorScheme(Brightness brightness) {
  return ColorScheme(
    brightness: brightness,
    primary: brightness == Brightness.light ? color3 : color4,
    onPrimary: color1,
    secondary: brightness == Brightness.light ? color4 : color3,
    onSecondary: color1,
    // Use surface instead of background
    surface: brightness == Brightness.light ? color1 : color5,
    // Use onSurface instead of onBackground
    onSurface: brightness == Brightness.light ? color5 : color1,
    error: Colors.red,
    onError: brightness == Brightness.light ? Colors.white : Colors.black,
    surfaceTint: brightness == Brightness.light ? color3 : color4,
    // New tone-based surface colors
    surfaceBright: brightness == Brightness.light ? color1 : color2,
    surfaceDim: brightness == Brightness.light ? color2 : color1,
    surfaceContainer: brightness == Brightness.light ? color3 : color4,
    surfaceContainerLow: brightness == Brightness.light ? color4 : color3,
    surfaceContainerLowest: brightness == Brightness.light ? color5 : color1,
    surfaceContainerHigh: brightness == Brightness.light ? color1 : color5,
    surfaceContainerHighest: brightness == Brightness.light ? color2 : color3,
  );
}

TextTheme createTextTheme(ColorScheme colorScheme) {
  // Updated to use the latest GoogleFonts API
  return TextTheme(
    displayLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
      fontSize: 15,
    ),
    bodyMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
      fontSize: 17,
    ),
    bodyLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
      fontSize: 18,
    ),
    bodySmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
      fontSize: 13,
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
      fontSize: 23,
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
      fontSize: 20,
    ),
    displaySmall: GoogleFonts.ubuntuCondensed(
      color: colorScheme.onSurface,
    ),
    displayMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
  );
}

ThemeData createThemeData(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: createTextTheme(colorScheme),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      // New property for Material 3
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 6,
      titleTextStyle: GoogleFonts.ubuntuCondensed(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      shadowColor: colorScheme.surfaceContainerLow,
    ),
    // Updated ButtonTheme to ElevatedButtonTheme as ButtonTheme is deprecated
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        iconSize: WidgetStateProperty.all(20),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed))
              return colorScheme.secondary;
            return colorScheme.primary; // Use the component's default.
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.onSurface),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(color: colorScheme.primary),
          ),
        ),

        textStyle: WidgetStatePropertyAll(
          GoogleFonts.ubuntuCondensed().copyWith(
            fontSize: 19.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Add other properties as needed
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      iconSize: 25,
      shape: const CircleBorder(
        side: BorderSide(width: 2, color: Colors.black38),
      ),
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(4.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.secondary),
        borderRadius: BorderRadius.circular(4.0),
      ),
      hintStyle: GoogleFonts.ubuntuCondensed(
        color: colorScheme.onSurface.withOpacity(0.5),
      ),
      labelStyle: GoogleFonts.ubuntuCondensed(
        color: colorScheme.onSurface,
      ),
      prefixIconColor: colorScheme.surfaceContainerLowest,
      suffixIconColor: colorScheme.surfaceContainerLowest,
    ),
    // ListTileTheme is updated to ListTileThemeData
    listTileTheme: ListTileThemeData(
      tileColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      titleTextStyle: GoogleFonts.ubuntuCondensed().copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      subtitleTextStyle: GoogleFonts.ubuntuCondensed().copyWith(
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
      ),
      leadingAndTrailingTextStyle: GoogleFonts.ubuntuCondensed().copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: colorScheme.surface, // Drawer background color
      scrimColor: colorScheme.surfaceContainerLowest
          .withOpacity(0.5), // Scrim color when drawer is open
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.surface,
      contentTextStyle: GoogleFonts.ubuntuCondensed(
        color: colorScheme.onSurface,
      ),
      actionTextColor: colorScheme.primary,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(colorScheme.primary),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.ubuntuCondensed().copyWith(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    // Add other theme customizations as needed
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: colorScheme.surface,
      collapsedBackgroundColor: colorScheme.surface,
      iconColor: colorScheme.primary,
      collapsedIconColor: colorScheme.primary,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      checkColor: WidgetStateProperty.resolveWith((_) => Colors.teal.shade800),
      fillColor: WidgetStateProperty.resolveWith(
        (_) => colorScheme.onSurface.withOpacity(0.05),
      ),
    ),
  );
}
