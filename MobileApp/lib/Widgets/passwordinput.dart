import 'package:flutter/material.dart';
import 'package:start/Widgets/Palette.dart';

class Passwordinput extends StatefulWidget {
  const Passwordinput({
    required this.hint,
    required this.icon,
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
  State<Passwordinput> createState() => _PasswordinputState();
}

class _PasswordinputState extends State<Passwordinput> {
  bool _passwordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10)),
      child: TextFormField(
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.2),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            // border: InputBorder.none,
            // border: OutlineInputBorder(
            //     borderRadius: BorderRadius.circular(10),
            //     borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            hintText: widget.hint,
            hintStyle: bodytext,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                widget.icon,
                color: Colors.green,
                size: 20,
              ),
            )),
        obscureText: !_passwordVisible,
        style: bodytext,
        keyboardType: widget.inputType,
        textInputAction: widget.inputAction,
        validator: widget.validator,
        controller: widget.controller,
      ),
    );
  }
}
