import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kurskafedesktop/cubit/acces_level_cubit.dart';
import 'package:kurskafedesktop/view/admin_page.dart';
import 'package:kurskafedesktop/view/home.dart';
import 'package:kurskafedesktop/view/log_in_page.dart';

import 'cubit/dish_in_chekk_cubit.dart';
import 'cubit/dish_type_cubit.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DishTypeCubit(),
      child: BlocProvider(
        create: (context) => DishInChekkCubit(),
        child: BlocProvider(
          create: (context) => AccesLevelCubit(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            routes: {
              PageHome.routeName: (context) => const PageHome(),
              PageLogIn.routeName: (context) => const PageLogIn(),
              PageAdminPannel.routeName: (context) => const PageAdminPannel(),
            },
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade400),
              useMaterial3: true,
            ),
            home: const PageLogIn(),
          ),
        ),
      ),
    );
  }
}
