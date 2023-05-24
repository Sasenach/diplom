import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kurskafedesktop/cubit/acces_level_cubit.dart';
import 'package:kurskafedesktop/model/employee.dart';
import 'package:kurskafedesktop/requests.dart';
import 'package:kurskafedesktop/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageLogIn extends StatefulWidget {
  const PageLogIn({super.key});
  static const routeName = '/PageLogIn';

  @override
  State<PageLogIn> createState() => _PageLogInState();
}

TextEditingController txtPassword = TextEditingController();
bool _obscureText = true;

class _PageLogInState extends State<PageLogIn> {
  @override
  Widget build(BuildContext context) {
    final double skWidth = MediaQuery.of(context).size.width;
    final double skHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: skWidth * 0.7,
              height: skHeight * 0.15,
              child: TextFormField(
                controller: txtPassword,
                keyboardType: TextInputType.number,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  Employee employee =
                      await HTTPRequests().signIn(txtPassword.text);
                  if (employee.id != 0) {
                    txtPassword.text = '';
                    if (employee.accessLevel == '1') {
                      context
                          .read<AccesLevelCubit>()
                          .emit(AccesLevelPrivilage());
                    }
                    Navigator.pushNamed(context, PageHome.routeName,
                        arguments: employee);
                  } else {
                    const bar = SnackBar(
                      content: Text('Что-то пошло не так, попробуйте еще раз'),
                      duration: Duration(seconds: 2),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(bar);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    "Войти",
                    style: TextStyle(fontSize: 22),
                  ),
                ))
          ],
        ),
      )),
    );
  }
}
