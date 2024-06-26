import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextFormField extends StatefulWidget {
  MyTextFormField({
    super.key,
    required this.title,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.validation,
    this.onsaved,
  });
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final String title;
  String hint;
  final TextEditingController? controller;
  String? Function(String? text)? validation;
  Function(String? text)? onsaved;
  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        validator: widget.validation,
        onSaved: widget.onsaved,
        autofocus: false,
        controller: widget.controller,
        readOnly: widget.suffixIcon == null ? false : true,
        decoration: InputDecoration(
          labelText: widget.title,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
        ),
        maxLines: widget.title == 'Note' ? 5 : 1,
        textAlign: widget.title == 'Note' ? TextAlign.justify : TextAlign.start,
        style: GoogleFonts.ubuntuCondensed(
          color: widget.suffixIcon == null
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}
