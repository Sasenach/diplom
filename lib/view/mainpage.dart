import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kurskafedesktop/view/admin_page.dart';
import 'package:kurskafedesktop/view/log_in_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../cubit/acces_level_cubit.dart';
import '../cubit/dish_in_chekk_cubit.dart';
import '../cubit/dish_type_cubit.dart';
import '../model/chekk.dart';
import '../model/dish.dart';
import '../model/dish_sub_type.dart';
import '../model/dishtype.dart';
import '../model/employee.dart';
import '../model/todo.dart';
import '../requests.dart';

class PageMain extends StatefulWidget {
  const PageMain({super.key});

  @override
  State<PageMain> createState() => _PageMainState();
}

late List<DishType> dishTypeList = [];
late List<DishSubType> dishSubTypeList = [];
late List<Dish> dishInChekkList = [];
late int selectedType = 0;
late int selectedSubType = 0;
late String storedName = "";
late Chekk storedChekk;

class _PageMainState extends State<PageMain> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedName = prefs.getString('selectedTable') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Employee;

    final double skWidth = MediaQuery.of(context).size.width;
    final double skHeight = MediaQuery.of(context).size.height;
    if (storedName == '') {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()));
    } else {
      return Scaffold(
        body: FutureBuilder<Chekk>(
          future: HTTPRequests().getCurentChekk(int.parse(storedName)),
          builder: (BuildContext context, AsyncSnapshot<Chekk> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.data!.toString().isEmpty) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            storedChekk = snapshot.data!;
            return SafeArea(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: skWidth * 0.33,
                  height: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                flex: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.person),
                                    Text(snapshot.data!.persons.toString()),
                                    Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        child: const Icon(
                                            Icons.table_bar_outlined)),
                                    Text(
                                      snapshot.data!.tablee.toString(),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Итог:",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            snapshot.data!.amount.toString(),
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                            Flexible(
                              flex:
                                  1, // задаем flex значение 0 для остальных элементов
                              child: Text(
                                DateFormat(
                                  'HH:mm dd.MM.yyyy',
                                ).format(snapshot.data!.curentDate!).toString(),
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<DishInChekkCubit, DishInChekkState>(
                        builder: (context, state) {
                          if (dishInChekkList.isEmpty) {
                            return FutureBuilder(
                                future: HTTPRequests()
                                    .getDishesInChekk(int.parse(storedName)),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Dish>> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: Text(
                                            'В этом чеке еще нет позиций'));
                                  }
                                  if (snapshot.data.toString().isEmpty) {
                                    return const Center(
                                        child: Text(
                                            'В этом чеке еще нет позиций'));
                                  }

                                  dishInChekkList = snapshot.data!;
                                  return Expanded(
                                      child: SingleChildScrollView(
                                    child: Wrap(
                                      spacing:
                                          8.0, // расстояние между элементами
                                      runSpacing:
                                          4.0, // расстояние между строками элементов
                                      runAlignment: WrapAlignment
                                          .start, // выравнивание элементов в начале каждой строки
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: List.generate(
                                        dishInChekkList.length,
                                        (index) => SizedBox(
                                          width: double.infinity,
                                          child: GestureDetector(
                                            onDoubleTap: () {
                                              if (dishInChekkList[index]
                                                  .status!) {
                                                const bar = SnackBar(
                                                  content: Text(
                                                      'Нельзя удалить позицию, отправленную на кухню.\nОбратитесь к администратору'),
                                                  duration:
                                                      Duration(seconds: 4),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(bar);
                                              } else {
                                                dishInChekkList.removeAt(index);
                                                context
                                                    .read<DishInChekkCubit>()
                                                    .emit(DishInChekkUpdated());
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0,
                                                      vertical: 5.0),
                                              decoration: BoxDecoration(
                                                color: dishInChekkList[index]
                                                        .status!
                                                    ? Colors.grey.shade300
                                                    : Colors.blue.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    dishInChekkList[index]
                                                        .name!,
                                                    style: const TextStyle(
                                                        fontSize: 18.0),
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    '${dishInChekkList[index].cost.toString()}₽',
                                                    style: const TextStyle(
                                                        fontSize: 18.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                                });
                          }
                          return Expanded(
                              child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8.0, // расстояние между элементами
                              runSpacing:
                                  4.0, // расстояние между строками элементов
                              runAlignment: WrapAlignment
                                  .start, // выравнивание элементов в начале каждой строки
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: List.generate(
                                dishInChekkList.length,
                                (index) => SizedBox(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onDoubleTap: () {
                                      if (dishInChekkList[index].status!) {
                                        const bar = SnackBar(
                                          content: Text(
                                              'Нельзя удалить позицию, отправленную на кухню.\nОбратитесь к администратору'),
                                          duration: Duration(seconds: 4),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(bar);
                                      } else {
                                        dishInChekkList.removeAt(index);
                                        context
                                            .read<DishInChekkCubit>()
                                            .emit(DishInChekkUpdated());
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0, vertical: 5.0),
                                      decoration: BoxDecoration(
                                        color: dishInChekkList[index].status!
                                            ? Colors.grey.shade300
                                            : Colors.blue.shade100,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dishInChekkList[index].name!,
                                            style:
                                                const TextStyle(fontSize: 18.0),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            '${dishInChekkList[index].cost.toString()}₽',
                                            style:
                                                const TextStyle(fontSize: 18.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ));
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0))),
                            onPressed: () async {
                              if (context.read<DishInChekkCubit>().state
                                  is DishInChekkInitial) {
                                const bar = SnackBar(
                                    content: Text('В чеке нет изменений'));
                                ScaffoldMessenger.of(context).showSnackBar(bar);
                              } else {
                                await HTTPRequests().saveChekkEdit(
                                    snapshot.data!.id!, dishInChekkList);
                                context
                                    .read<DishInChekkCubit>()
                                    .emit(DishInChekkInitial());
                                dishInChekkList = [];
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              child: const Text(
                                'Отправить на кухню',
                                style: TextStyle(fontSize: 20),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: skWidth * 0.33,
                    height: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0))),
                              onPressed: () {
                                if (context.read<DishTypeCubit>().state
                                    is DishesLoaded) {
                                  context
                                      .read<DishTypeCubit>()
                                      .emit(DishSubTypeLoaded());
                                } else if (context.read<DishTypeCubit>().state
                                    is DishSubTypeLoaded) {
                                  dishSubTypeList = [];
                                  context
                                      .read<DishTypeCubit>()
                                      .emit(DishTypeLoaded());
                                }
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(15),
                                  child: const Text(
                                    'Назад',
                                    style: TextStyle(fontSize: 20),
                                  ))),
                        ),
                        BlocBuilder<DishTypeCubit, DishTypeState>(
                            builder: (context, state) {
                          if (state is DishesLoaded) {
                            return FutureBuilder(
                                future:
                                    HTTPRequests().getDishes(selectedSubType),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Dish>> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    );
                                  }
                                  if (snapshot.data!.isEmpty) {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    );
                                  }
                                  return Expanded(
                                    child: ListView.builder(
                                        itemCount: snapshot.data!.length % 3 ==
                                                0
                                            ? (snapshot.data!.length ~/ 3)
                                                .toInt()
                                            : (snapshot.data!.length ~/ 3 + 1)
                                                .toInt(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          int i = index * 3;
                                          if (i + 2 < snapshot.data!.length) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  width: skWidth * 0.3 * 0.3,
                                                  height: skWidth * 0.3 * 0.3,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    onPressed: snapshot
                                                            .data![i].status!
                                                        ? () {
                                                            Dish dish = snapshot
                                                                .data![i];
                                                            dishInChekkList.add(
                                                                dish.copyWith(
                                                                    status:
                                                                        false));
                                                            context
                                                                .read<
                                                                    DishInChekkCubit>()
                                                                .emit(
                                                                    DishInChekkUpdated()); //////////////////////////
                                                          }
                                                        : null,
                                                    child: Text(
                                                      '${snapshot.data![i].name.toString()} \n ${snapshot.data![i].cost.toString()}₽',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  width: skWidth * 0.3 * 0.3,
                                                  height: skWidth * 0.3 * 0.3,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    onPressed: snapshot
                                                            .data![i].status!
                                                        ? () {
                                                            Dish dish = snapshot
                                                                .data![i + 1];
                                                            dishInChekkList.add(
                                                                dish.copyWith(
                                                                    status:
                                                                        false));
                                                            context
                                                                .read<
                                                                    DishInChekkCubit>()
                                                                .emit(
                                                                    DishInChekkUpdated());
                                                          }
                                                        : null,
                                                    child: Text(
                                                      '${snapshot.data![i + 1].name.toString()} \n ${snapshot.data![i + 1].cost.toString()}₽',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  width: skWidth * 0.3 * 0.3,
                                                  height: skWidth * 0.3 * 0.3,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    onPressed: snapshot
                                                            .data![i].status!
                                                        ? () {
                                                            Dish dish = snapshot
                                                                .data![i + 2];
                                                            dishInChekkList.add(
                                                                dish.copyWith(
                                                                    status:
                                                                        false));
                                                            context
                                                                .read<
                                                                    DishInChekkCubit>()
                                                                .emit(
                                                                    DishInChekkUpdated());
                                                          }
                                                        : null,
                                                    child: Text(
                                                      '${snapshot.data![i + 2].name.toString()} \n ${snapshot.data![i + 2].cost.toString()}₽',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else if (i + 1 <
                                              snapshot.data!.length) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  width: skWidth * 0.3 * 0.3,
                                                  height: skWidth * 0.3 * 0.3,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    onPressed: snapshot
                                                            .data![i].status!
                                                        ? () {
                                                            Dish dish = snapshot
                                                                .data![i];
                                                            dishInChekkList.add(
                                                                dish.copyWith(
                                                                    status:
                                                                        false));
                                                            context
                                                                .read<
                                                                    DishInChekkCubit>()
                                                                .emit(
                                                                    DishInChekkUpdated());
                                                          }
                                                        : null,
                                                    child: Text(
                                                      '${snapshot.data![i].name.toString()} \n ${snapshot.data![i].cost.toString()}₽',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  width: skWidth * 0.3 * 0.3,
                                                  height: skWidth * 0.3 * 0.3,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    onPressed: snapshot
                                                            .data![i].status!
                                                        ? () {
                                                            Dish dish = snapshot
                                                                .data![i + 1];
                                                            dishInChekkList.add(
                                                                dish.copyWith(
                                                                    status:
                                                                        false));
                                                            context
                                                                .read<
                                                                    DishInChekkCubit>()
                                                                .emit(
                                                                    DishInChekkUpdated());
                                                          }
                                                        : null,
                                                    child: Text(
                                                      '${snapshot.data![i + 1].name.toString()} \n ${snapshot.data![i + 1].cost.toString()}₽',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  width: skWidth * 0.3 * 0.3,
                                                  height: skWidth * 0.3 * 0.3,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    onPressed: snapshot
                                                            .data![i].status!
                                                        ? () {
                                                            Dish dish = snapshot
                                                                .data![i];
                                                            dishInChekkList.add(
                                                                dish.copyWith(
                                                                    status:
                                                                        false));
                                                            context
                                                                .read<
                                                                    DishInChekkCubit>()
                                                                .emit(
                                                                    DishInChekkUpdated());
                                                          }
                                                        : null,
                                                    child: Text(
                                                      '${snapshot.data![i].name.toString()} \n ${snapshot.data![i].cost.toString()}₽',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        }),
                                  );
                                });
                          }
                          //богииии
                          if (state is DishSubTypeLoaded) {
                            if (dishSubTypeList.isEmpty) {
                              return FutureBuilder(
                                  future: HTTPRequests()
                                      .getDishSubTypes(selectedType), //ToDo
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<DishSubType>>
                                          snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      );
                                    } else if (snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      );
                                    } else {
                                      dishSubTypeList = snapshot.data!;
                                      return Expanded(
                                        child: ListView.builder(
                                            itemCount: dishSubTypeList.length %
                                                        3 ==
                                                    0
                                                ? (dishSubTypeList.length ~/ 3)
                                                    .toInt()
                                                : (dishSubTypeList.length ~/ 3 +
                                                        1)
                                                    .toInt(),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              int i = index * 3;
                                              if (i + 2 <
                                                  dishSubTypeList.length) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      width:
                                                          skWidth * 0.3 * 0.3,
                                                      height:
                                                          skWidth * 0.3 * 0.3,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  DishTypeCubit>()
                                                              .emit(
                                                                  DishesLoaded());
                                                          selectedSubType =
                                                              dishSubTypeList[i]
                                                                  .id;
                                                        },
                                                        child: Text(
                                                          dishSubTypeList[i]
                                                              .name
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      width:
                                                          skWidth * 0.3 * 0.3,
                                                      height:
                                                          skWidth * 0.3 * 0.3,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  DishTypeCubit>()
                                                              .emit(
                                                                  DishesLoaded());
                                                          selectedSubType =
                                                              dishSubTypeList[
                                                                      i + 1]
                                                                  .id;
                                                        },
                                                        child: Text(
                                                          dishSubTypeList[i + 1]
                                                              .name
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      width:
                                                          skWidth * 0.3 * 0.3,
                                                      height:
                                                          skWidth * 0.3 * 0.3,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  DishTypeCubit>()
                                                              .emit(
                                                                  DishesLoaded());
                                                          selectedSubType =
                                                              dishSubTypeList[
                                                                      i + 2]
                                                                  .id;
                                                        },
                                                        child: Text(
                                                          dishSubTypeList[i + 2]
                                                              .name
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else if (i + 1 <
                                                  dishSubTypeList.length) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      width:
                                                          skWidth * 0.3 * 0.3,
                                                      height:
                                                          skWidth * 0.3 * 0.3,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  DishTypeCubit>()
                                                              .emit(
                                                                  DishesLoaded());
                                                          selectedSubType =
                                                              dishSubTypeList[i]
                                                                  .id;
                                                        },
                                                        child: Text(
                                                          dishSubTypeList[i]
                                                              .name
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      width:
                                                          skWidth * 0.3 * 0.3,
                                                      height:
                                                          skWidth * 0.3 * 0.3,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  DishTypeCubit>()
                                                              .emit(
                                                                  DishesLoaded());
                                                          selectedSubType =
                                                              dishSubTypeList[
                                                                      i + 1]
                                                                  .id;
                                                        },
                                                        child: Text(
                                                          dishSubTypeList[i + 1]
                                                              .name
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      width:
                                                          skWidth * 0.3 * 0.3,
                                                      height:
                                                          skWidth * 0.3 * 0.3,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  DishTypeCubit>()
                                                              .emit(
                                                                  DishesLoaded());
                                                          selectedSubType =
                                                              dishSubTypeList[i]
                                                                  .id;
                                                        },
                                                        child: Text(
                                                          dishSubTypeList[i]
                                                              .name
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            }),
                                      );
                                    }
                                  });
                            } else {
                              return Expanded(
                                child: ListView.builder(
                                    itemCount: dishSubTypeList.length % 3 == 0
                                        ? (dishSubTypeList.length ~/ 3).toInt()
                                        : (dishSubTypeList.length ~/ 3 + 1)
                                            .toInt(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      int i = index * 3;
                                      if (i + 2 < dishSubTypeList.length) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(5),
                                              width: skWidth * 0.3 * 0.3,
                                              height: skWidth * 0.3 * 0.3,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<DishTypeCubit>()
                                                      .emit(DishesLoaded());
                                                  selectedSubType =
                                                      dishSubTypeList[i].id;
                                                },
                                                child: Text(
                                                  dishSubTypeList[i]
                                                      .name
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.all(5),
                                              width: skWidth * 0.3 * 0.3,
                                              height: skWidth * 0.3 * 0.3,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<DishTypeCubit>()
                                                      .emit(DishesLoaded());
                                                  selectedSubType =
                                                      dishSubTypeList[i + 1].id;
                                                },
                                                child: Text(
                                                  dishSubTypeList[i + 1]
                                                      .name
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.all(5),
                                              width: skWidth * 0.3 * 0.3,
                                              height: skWidth * 0.3 * 0.3,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<DishTypeCubit>()
                                                      .emit(DishesLoaded());
                                                  selectedSubType =
                                                      dishSubTypeList[i + 2].id;
                                                },
                                                child: Text(
                                                  dishSubTypeList[i + 2]
                                                      .name
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else if (i + 1 <
                                          dishSubTypeList.length) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(5),
                                              width: skWidth * 0.3 * 0.3,
                                              height: skWidth * 0.3 * 0.3,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<DishTypeCubit>()
                                                      .emit(DishesLoaded());
                                                  selectedSubType =
                                                      dishSubTypeList[i].id;
                                                },
                                                child: Text(
                                                  dishSubTypeList[i]
                                                      .name
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.all(5),
                                              width: skWidth * 0.3 * 0.3,
                                              height: skWidth * 0.3 * 0.3,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<DishTypeCubit>()
                                                      .emit(DishesLoaded());
                                                  selectedSubType =
                                                      dishSubTypeList[i + 1].id;
                                                },
                                                child: Text(
                                                  dishSubTypeList[i + 1]
                                                      .name
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(5),
                                              width: skWidth * 0.3 * 0.3,
                                              height: skWidth * 0.3 * 0.3,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<DishTypeCubit>()
                                                      .emit(DishesLoaded());
                                                  selectedSubType =
                                                      dishSubTypeList[i].id;
                                                },
                                                child: Text(
                                                  dishSubTypeList[i]
                                                      .name
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    }),
                              );
                            }
                          }
                          //о боже
                          if (dishTypeList.isEmpty) {
                            return FutureBuilder(
                                future: HTTPRequests().getDishTypes(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<DishType>> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    );
                                  } else if (snapshot.data!.isEmpty) {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    );
                                  } else {
                                    dishTypeList = snapshot.data!;
                                    return Expanded(
                                      child: ListView.builder(
                                          itemCount: dishTypeList.length % 3 ==
                                                  0
                                              ? (dishTypeList.length ~/ 3)
                                                  .toInt()
                                              : (dishTypeList.length ~/ 3 + 1)
                                                  .toInt(),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            int i = index * 3;
                                            if (i + 2 < dishTypeList.length) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    width: skWidth * 0.3 * 0.3,
                                                    height: skWidth * 0.3 * 0.3,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                DishTypeCubit>()
                                                            .emit(
                                                                DishSubTypeLoaded());
                                                        selectedType =
                                                            dishTypeList[i].id;
                                                      },
                                                      child: Text(
                                                        dishTypeList[i]
                                                            .name
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    width: skWidth * 0.3 * 0.3,
                                                    height: skWidth * 0.3 * 0.3,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                DishTypeCubit>()
                                                            .emit(
                                                                DishSubTypeLoaded());
                                                        selectedType =
                                                            dishTypeList[i + 1]
                                                                .id;
                                                      },
                                                      child: Text(
                                                        dishTypeList[i + 1]
                                                            .name
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    width: skWidth * 0.3 * 0.3,
                                                    height: skWidth * 0.3 * 0.3,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                DishTypeCubit>()
                                                            .emit(
                                                                DishSubTypeLoaded());
                                                        selectedType =
                                                            dishTypeList[i + 2]
                                                                .id;
                                                      },
                                                      child: Text(
                                                        dishTypeList[i + 2]
                                                            .name
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else if (i + 1 <
                                                dishTypeList.length) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    width: skWidth * 0.3 * 0.3,
                                                    height: skWidth * 0.3 * 0.3,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                DishTypeCubit>()
                                                            .emit(
                                                                DishSubTypeLoaded());
                                                        selectedType =
                                                            dishTypeList[i].id;
                                                      },
                                                      child: Text(
                                                        dishTypeList[i]
                                                            .name
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    width: skWidth * 0.3 * 0.3,
                                                    height: skWidth * 0.3 * 0.3,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                DishTypeCubit>()
                                                            .emit(
                                                                DishSubTypeLoaded());
                                                        selectedType =
                                                            dishTypeList[i + 1]
                                                                .id;
                                                      },
                                                      child: Text(
                                                        dishTypeList[i + 1]
                                                            .name
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    width: skWidth * 0.3 * 0.3,
                                                    height: skWidth * 0.3 * 0.3,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                DishTypeCubit>()
                                                            .emit(
                                                                DishSubTypeLoaded());
                                                        selectedType =
                                                            dishTypeList[i].id;
                                                      },
                                                      child: Text(
                                                        dishTypeList[i]
                                                            .name
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          }),
                                    );
                                  }
                                });
                          } else {
                            return Expanded(
                              child: ListView.builder(
                                  itemCount: dishTypeList.length % 3 == 0
                                      ? (dishTypeList.length ~/ 3).toInt()
                                      : (dishTypeList.length ~/ 3 + 1).toInt(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    int i = index * 3;
                                    if (i + 2 < dishTypeList.length) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(5),
                                            width: skWidth * 0.3 * 0.3,
                                            height: skWidth * 0.3 * 0.3,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<DishTypeCubit>()
                                                    .emit(DishSubTypeLoaded());
                                                selectedType =
                                                    dishTypeList[i].id;
                                              },
                                              child: Text(
                                                dishTypeList[i].name.toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.all(5),
                                            width: skWidth * 0.3 * 0.3,
                                            height: skWidth * 0.3 * 0.3,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<DishTypeCubit>()
                                                    .emit(DishSubTypeLoaded());
                                                selectedType =
                                                    dishTypeList[i + 1].id;
                                              },
                                              child: Text(
                                                dishTypeList[i + 1]
                                                    .name
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.all(5),
                                            width: skWidth * 0.3 * 0.3,
                                            height: skWidth * 0.3 * 0.3,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<DishTypeCubit>()
                                                    .emit(DishSubTypeLoaded());
                                                selectedType =
                                                    dishTypeList[i + 2].id;
                                              },
                                              child: Text(
                                                dishTypeList[i + 2]
                                                    .name
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else if (i + 1 < dishTypeList.length) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(5),
                                            width: skWidth * 0.3 * 0.3,
                                            height: skWidth * 0.3 * 0.3,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<DishTypeCubit>()
                                                    .emit(DishSubTypeLoaded());
                                                selectedType =
                                                    dishTypeList[i].id;
                                              },
                                              child: Text(
                                                dishTypeList[i].name.toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.all(5),
                                            width: skWidth * 0.3 * 0.3,
                                            height: skWidth * 0.3 * 0.3,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<DishTypeCubit>()
                                                    .emit(DishSubTypeLoaded());
                                                selectedType =
                                                    dishTypeList[i + 1].id;
                                              },
                                              child: Text(
                                                dishTypeList[i + 1]
                                                    .name
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(5),
                                            width: skWidth * 0.3 * 0.3,
                                            height: skWidth * 0.3 * 0.3,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<DishTypeCubit>()
                                                    .emit(DishSubTypeLoaded());
                                                selectedType =
                                                    dishTypeList[i].id;
                                              },
                                              child: Text(
                                                dishTypeList[i].name.toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  }),
                            );
                          }

                          // return Center(
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       context
                          //           .read<DishTypeCubit>()
                          //           .emit(DishTypeLoaded());
                          //     },
                          //     child: const Text('Добавить блюдо'),
                          //   ),
                          // );
                        }),
                      ],
                    )),
                Container(
                  height: double.infinity,
                  width: skWidth * 0.33,
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: FutureBuilder(
                              future: HTTPRequests().getAllToDoes(args.id!),
                              builder: (context,
                                  AsyncSnapshot<List<ToDo>> snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  );
                                }
                                if (snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  );
                                }
                                return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      ToDo toDo = snapshot.data![index];
                                      return ListTile(
                                        onLongPress: () async {
                                          await HTTPRequests()
                                              .deleteToDo(toDo.id);
                                          setState(() {});
                                        },
                                        title: Container(
                                          padding: const EdgeInsets.all(20),
                                          width: skWidth * 0.8,
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.shade100,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            toDo.toDo,
                                            maxLines: null,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      );
                                    });
                              })),
                      IntrinsicHeight(
                        child: Container(
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.end,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (context.read<AccesLevelCubit>().state
                                    is AccesLevelPrivilage)
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0))),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            PageAdminPannel.routeName,
                                            arguments: args);
                                      },
                                      child: SizedBox(
                                          height: skHeight * 0.09,
                                          width: skHeight * 0.09,
                                          child: const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.settings,
                                                size: 32,
                                              ),
                                              Text(
                                                'Администратор',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          )))
                                else
                                  const SizedBox.shrink(),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0))),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text("Пeчать предчека"),
                                            content: const Text(
                                                "Вы уверены что хотите распечатать предчек и закрыть счёт?"),
                                            actions: [
                                              FloatingActionButton(
                                                child: const Text("Отмена"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              FloatingActionButton(
                                                child: const Text("Ок"),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  printChekk(storedChekk);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: SizedBox(
                                        height: skHeight * 0.09,
                                        width: skHeight * 0.09,
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.print_rounded,
                                              size: 32,
                                            ),
                                            Text('Предчек'),
                                          ],
                                        ))),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0))),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                "Подтверждение действия"),
                                            content: const Text(
                                                "Вы уверены что хотите выйти?"),
                                            actions: [
                                              FloatingActionButton(
                                                child: const Text("Отмена"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              FloatingActionButton(
                                                child: const Text("Ок"),
                                                onPressed: () {
                                                  context
                                                      .read<DishTypeCubit>()
                                                      .emit(DishTypeLoaded());
                                                  context
                                                      .read<AccesLevelCubit>()
                                                      .emit(
                                                          AccesLevelInitial());
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          PageLogIn.routeName);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: SizedBox(
                                        height: skHeight * 0.09,
                                        width: skHeight * 0.09,
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.logout_rounded,
                                              size: 32,
                                            ),
                                            Text('Выйти'),
                                          ],
                                        ))),
                              ],
                            )),
                      ),
                    ],
                  ),
                )
              ],
            ));
          },
        ),
      );
    }
  }

  Future<void> printChekk(Chekk storedChekk) async {
    // final doc = pw.Document();
    // doc.addPage(pw.Page(
    //     pageFormat: PdfPageFormat.a4,
    //     build: (pw.Context context) {
    //       DateTime now = DateTime.now();
    //       String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(now);
    //       return pw.Column(children: [
    //         pw.Text(storedChekk.orgName!,
    //             style: const pw.TextStyle(fontSize: 14)),
    //         pw.Text(storedChekk.orgINN!,
    //             style: const pw.TextStyle(fontSize: 14)),
    //         pw.Text(storedChekk.orgAddress!,
    //             style: const pw.TextStyle(fontSize: 14)),
    //         pw.Text(formattedDate, style: const pw.TextStyle(fontSize: 14)),
    //         pw.Text('Стол №${storedChekk.tablee!}',
    //             style: const pw.TextStyle(fontSize: 14)),
    //         pw.Text('Чек №${storedChekk.id!.toString().padLeft(9, '0')}',
    //             style: const pw.TextStyle(fontSize: 14)),
    //         pw.Text('----------', style: const pw.TextStyle(fontSize: 14)),
    //       ]);
    //     }));

    // final printer = await Printing.pickPrinter(context: context);
    // Printing.directPrintPdf(
    //   onLayout: (format) => doc.save(),
    //   name: 'MyDocument.pdf',
    //   printer: printer!,
    // );
  }
}
