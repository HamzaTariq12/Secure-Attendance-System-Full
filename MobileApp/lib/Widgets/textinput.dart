import 'package:flutter/material.dart';
import 'package:start/Widgets/Palette.dart';

class Textinput extends StatelessWidget {
  const Textinput({
    required this.icon,
    required this.hint,
    required this.inputAction,
    required this.inputType,
    required this.controller,
    required this.validator,
    super.key,
  });
  final IconData icon;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: BoxDecoration(
            // color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10)),
        child: TextFormField(
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.2),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              hintText: hint,
              hintStyle: bodytext,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  icon,
                  color: Colors.green,
                  size: 20,
                ),
              )),
          style: bodytext,
          keyboardType: inputType,
          textInputAction: inputAction,
          controller: controller,
          validator: validator,
        ),
      ),
    );
  }
}
