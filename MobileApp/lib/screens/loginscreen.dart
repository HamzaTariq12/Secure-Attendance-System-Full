// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:start/Widgets/palette.dart';
import 'package:start/models/base_api_response.dart';
import '../Widgets/passwordinput.dart';
import '../Widgets/textinput.dart';
import 'package:start/newscreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String token;
  final String username;

  User({required this.token, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'],
      username: json['username'],
    );
  }
}

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<void> onLogin() async {
      const String url = 'auth/login/';
      var body = {
        "email": emailcontroller.text,
        "password": passwordcontroller.text,
        "is_student": true
      };
      setState(() {
        isLoading = true;
      });

      var response = await ApiService.postRequest(url, body);
      if (_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('login Successfull')),
        );
      }
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Access the token
        String token = jsonResponse['data']['token']['access_token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access_token', token);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('User Login Sccessfull'),
              );
            });
        print("Success");
        // print("Access Token: $token");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SecondScreen()));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                    'User Login failed ! \n Email or Password is Incorrect'),
              );
            });
        // AlertDialog(
        //   title: Text("user Login failed"),
        // );
        print("Failed");
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Backgroundimage(),
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height,
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        "ATTENDANCE",
                        style: hHeading,
                      ),
                    ),
                  ),
                  // Icon(
                  //   Icons.food_bank_rounded,
                  //   color: Colors.green,
                  //   size: 100,
                  // ),
                  const Image(
                    height: 120,
                    // color: Colors.amber,
                    image: AssetImage('assets/images/kfueit_logo.jpg'),

                    // NetworkImage(
                    //       'https://freepngimg.com/thumb/healthy_food/5-2-healthy-food-png-image.png'),
                  ),

                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 30),
                              ),
                              Text(
                                "Email",
                                style: labelText,
                              ),
                              Textinput(
                                controller: emailcontroller,
                                icon: FontAwesomeIcons.solidEnvelope,
                                hint: " Enter your Email",
                                inputType: TextInputType.emailAddress,
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is Required';
                                  }
                                  if (!value.isValidEmail()) {
                                    return 'Please Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                              ),
                              Text(
                                "Password",
                                style: labelText,
                              ),
                              Passwordinput(
                                controller: passwordcontroller,
                                icon: FontAwesomeIcons.lock,
                                hint: " Enter your Password",
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is Required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              // Text(
                              //   "Forgot Password ?",
                              //   style: bodytext,
                              //   selectionColor: Colors.black,
                              // )
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 40,
                              ),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 35, 161, 73),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      onLogin();
                                    } else {
                                      return;
                                    }
                                  },
                                  child: isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          "Login",
                                          style: buttonText,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 130,
                  // ),
                  // Spacer(),
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 30),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(20),
                  //     gradient: LinearGradient(
                  //       begin: Alignment.topRight,
                  //       end: Alignment.bottomLeft,
                  //       colors: [
                  //         Colors.black,
                  //         Colors.blue.shade100,
                  //       ],
                  //     ),
                  //     // border: Border(
                  //     //   bottom: BorderSide(
                  //     //     color: const Color.fromARGB(255, 76, 175, 150),
                  //     //   ),
                  //     // ),
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         "Create a new Account ? ",
                  //         style: bodytext,
                  //       ),
                  //       InkWell(
                  //         onTap: () => {moveToNextScreen()},
                  //         child: Text(
                  //           "Sign up",
                  //           style: TextStyle(
                  //             color: Color.fromARGB(255, 76, 179, 131),
                  //             fontSize: 19,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
