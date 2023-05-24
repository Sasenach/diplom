import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kurskafedesktop/cubit/acces_level_cubit.dart';
import 'package:kurskafedesktop/view/mainpage.dart';

import '../cubit/dish_type_cubit.dart';
import 'new_tables.dart';

class PageHome extends StatefulWidget {
  static const routeName = '/PageMain';
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const PageMain(),
    const PageNewtable(),
    // const PageProfile()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              context.read<DishTypeCubit>().emit(DishSubTypeLoaded());
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.table_bar_outlined),
              label: 'Открытый стол',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Новый счет',
            ),

            // BottomNavigationBarItem(
            //   icon: Icon(Icons.list_alt_rounded),
            //   label: 'Заметки',
            // ),
          ]),
      body: _pages[_currentIndex],
    );
  }
}
