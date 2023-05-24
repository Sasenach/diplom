import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kurskafedesktop/model/dish.dart';
import 'package:kurskafedesktop/model/dishtype.dart';
import 'package:kurskafedesktop/requests.dart';
import 'package:kurskafedesktop/view/home.dart';
import 'package:kurskafedesktop/view/mainpage.dart';

import '../cubit/acces_level_cubit.dart';
import '../cubit/dish_type_cubit.dart';
import '../model/dish_sub_type.dart';
import '../model/employee.dart';
import 'log_in_page.dart';

class PageAdminPannel extends StatefulWidget {
  const PageAdminPannel({super.key});
  static const routeName = '/PageAdminPannel';

  @override
  State<PageAdminPannel> createState() => _PageAdminPannelState();
}

DishType selectedDishType = DishType(id: -1, name: 'name');
DishSubType selectedDishSubType = DishSubType(id: -1, name: 'name');
TextEditingController txtDishTypeName = TextEditingController();
TextEditingController txtDishSubTypeName = TextEditingController();
TextEditingController txtDishName = TextEditingController();
TextEditingController txtDishCost = TextEditingController();
TextEditingController txtEmployeeSurname = TextEditingController();
TextEditingController txtEmployeeName = TextEditingController();
TextEditingController txtEmployeePassword = TextEditingController();
bool accessLevel = false;

class _PageAdminPannelState extends State<PageAdminPannel> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Employee;
    final double skWidth = MediaQuery.of(context).size.width;
    final double skHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: skWidth * 0.33,
            height: double.infinity,
            color: Colors.grey.shade200,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: const Text(
                                  'Введите название типа блюда',
                                  style: TextStyle(fontSize: 18),
                                ),
                                content: TextField(
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                      hintText: 'Наименование'),
                                  controller: txtDishTypeName,
                                ),
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
                                      if (txtDishTypeName.text.isEmpty) {
                                        const bar = SnackBar(
                                          content: Text('Введите наименование'),
                                          duration: Duration(seconds: 1),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(bar);
                                      } else {
                                        HTTPRequests()
                                            .saveDishType(txtDishTypeName.text);
                                        txtDishTypeName.text = '';
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              );
                            }));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: AutoSizeText(
                          'Добавить тип блюда',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                          maxLines: 1,
                          // overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<DishType>>(
                    future: HTTPRequests().getDishTypes(),
                    builder: ((context, snapshot) {
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
                      List<DishType> dishTypeList = snapshot.data!;
                      return Expanded(
                          flex: 8,
                          child: SingleChildScrollView(
                            child: Wrap(
                                runSpacing: 10,
                                children: List.generate(
                                    dishTypeList.length,
                                    (index) => Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: getColorForDishType(index,
                                                  dishTypeList[index].id),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedDishType =
                                                        (selectedDishType.id ==
                                                                dishTypeList[
                                                                        index]
                                                                    .id)
                                                            ? DishType(
                                                                id: -1,
                                                                name: 'name')
                                                            : selectedDishType =
                                                                dishTypeList[
                                                                    index];
                                                  });
                                                },
                                                child: Wrap(
                                                  direction: Axis.horizontal,
                                                  alignment: WrapAlignment
                                                      .spaceBetween,
                                                  runSpacing: 10,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        dishTypeList[index]
                                                            .name,
                                                        style: const TextStyle(
                                                            fontSize: 20),
                                                        maxLines: null,
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                    ),
                                                    IconButton(
                                                        onPressed: () async {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      "Подтверждение дествия"),
                                                                  content: Text(
                                                                      'Вы действительно хотите на всегда удалить тип блюда:\n${dishTypeList[index].name}.\nЭто приведет к удалению связанных подтипов и блюд.'),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Отмена')),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          int res =
                                                                              await HTTPRequests().deleteDishType(dishTypeList[index].id);
                                                                          if (res !=
                                                                              200) {
                                                                            Navigator.of(context).pop();
                                                                            setState(() {});
                                                                            const bar =
                                                                                SnackBar(content: Text('Упс что-то пошло не так'));
                                                                            ScaffoldMessenger.of(context).showSnackBar(bar);
                                                                          } else {
                                                                            Navigator.of(context).pop();
                                                                            setState(() {});
                                                                            const bar =
                                                                                SnackBar(content: Text('Тип блюда успешно удален'));
                                                                            ScaffoldMessenger.of(context).showSnackBar(bar);
                                                                          }
                                                                        },
                                                                        child: const Text(
                                                                            'Ок')),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        icon: const Icon(
                                                            Icons.delete))
                                                  ],
                                                )),
                                          ),
                                        ))),
                          ));
                    })),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      onPressed: () {
                        if (selectedDishType.id != -1) {
                          showDialog(
                              context: context,
                              builder: ((context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Введите название подтипа блюда',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  content: TextField(
                                    style: const TextStyle(fontSize: 14),
                                    decoration: const InputDecoration(
                                        hintText: 'Наименование'),
                                    controller: txtDishSubTypeName,
                                  ),
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
                                        if (txtDishSubTypeName.text.isEmpty) {
                                          const bar = SnackBar(
                                            content:
                                                Text('Введите наименование'),
                                            duration: Duration(seconds: 1),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(bar);
                                        } else {
                                          await HTTPRequests().saveDishSubType(
                                              txtDishSubTypeName.text,
                                              selectedDishType.id);
                                          txtDishTypeName.text = '';
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ],
                                );
                              }));
                        } else {
                          const bar = SnackBar(
                            content: Text(
                                'Выберите тип блюда!\nДля этого кликните по необходимой позиции в верхнем левом блоке, так чтобы она стала синей, для снятия выделения повторно кликнете на ту же позицию.'),
                            duration: Duration(seconds: 5),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(bar);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: AutoSizeText(
                          'Добавить подтип блюда',
                          style: TextStyle(fontSize: 22),
                          maxLines: null,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<DishSubType>>(
                    future: HTTPRequests().getAllDishSubTypes(),
                    builder: ((context, snapshot) {
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
                      List<DishSubType> dishSubTypeList = snapshot.data!;
                      return Expanded(
                          flex: 8,
                          child: SingleChildScrollView(
                            child: Wrap(
                                runSpacing: 10,
                                children: List.generate(
                                    dishSubTypeList.length,
                                    (index) => Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: getColorForDishSubType(
                                                  index,
                                                  dishSubTypeList[index].id),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    setState(() {
                                                      selectedDishSubType =
                                                          (selectedDishSubType
                                                                      .id ==
                                                                  dishSubTypeList[
                                                                          index]
                                                                      .id)
                                                              ? DishSubType(
                                                                  id: -1,
                                                                  name: 'name')
                                                              : selectedDishSubType =
                                                                  dishSubTypeList[
                                                                      index];
                                                    });
                                                  });
                                                },
                                                child: Wrap(
                                                  direction: Axis.horizontal,
                                                  alignment: WrapAlignment
                                                      .spaceBetween,
                                                  runSpacing: 10,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        dishSubTypeList[index]
                                                            .name,
                                                        style: const TextStyle(
                                                            fontSize: 20),
                                                        maxLines: null,
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                    ),
                                                    IconButton(
                                                        onPressed: () async {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      "Подтверждение дествия"),
                                                                  content: Text(
                                                                      'Вы действительно хотите на всегда удалить подтип блюда:\n${dishSubTypeList[index].name}.\nЭто приведет к удалению связанных блюд.'),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Отмена')),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          int res =
                                                                              await HTTPRequests().deleteDishSubType(dishSubTypeList[index].id);
                                                                          if (res !=
                                                                              200) {
                                                                            Navigator.of(context).pop();
                                                                            setState(() {});
                                                                            const bar =
                                                                                SnackBar(content: Text('Упс что-то пошло не так'));
                                                                            ScaffoldMessenger.of(context).showSnackBar(bar);
                                                                          } else {
                                                                            Navigator.of(context).pop();
                                                                            setState(() {});
                                                                            const bar =
                                                                                SnackBar(content: Text('Подтип блюда успешно удален'));
                                                                            ScaffoldMessenger.of(context).showSnackBar(bar);
                                                                          }
                                                                        },
                                                                        child: const Text(
                                                                            'Ок')),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        icon: const Icon(
                                                            Icons.delete))
                                                  ],
                                                )),
                                          ),
                                        ))),
                          ));
                    }))
              ],
            ),
          ),
          Container(
            width: skWidth * 0.33,
            height: double.infinity,
            color: Colors.grey.shade200,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                    ),
                    onPressed: () {
                      if (selectedDishSubType.id != -1) {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: const Text(
                                  'Добавление блюда',
                                  style: TextStyle(fontSize: 18),
                                ),
                                content: Wrap(
                                  children: [
                                    TextField(
                                      style: const TextStyle(fontSize: 14),
                                      decoration: const InputDecoration(
                                          labelText: 'Наименование'),
                                      controller: txtDishName,
                                    ),
                                    TextField(
                                      style: const TextStyle(fontSize: 14),
                                      decoration: const InputDecoration(
                                          labelText: 'Цена'),
                                      controller: txtDishCost,
                                    ),
                                  ],
                                ),
                                actions: [
                                  FloatingActionButton(
                                    child: const Text("Отмена"),
                                    onPressed: () {
                                      txtDishName.clear();
                                      txtDishCost.clear();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FloatingActionButton(
                                    child: const Text("Ок"),
                                    onPressed: () async {
                                      if (txtDishName.text.isEmpty ||
                                          txtDishCost.text.isEmpty) {
                                        const bar = SnackBar(
                                          content: Text(
                                              'Введите наименование и стоимость (целым числом)'),
                                          duration: Duration(seconds: 3),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(bar);
                                      } else {
                                        HTTPRequests().saveDish(
                                            Dish(
                                                cost:
                                                    int.parse(txtDishCost.text),
                                                name: txtDishName.text,
                                                status: true),
                                            selectedDishSubType.id);
                                        txtDishName.clear();
                                        txtDishCost.clear();
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              );
                            }));
                      } else {
                        const bar = SnackBar(
                          content: Text(
                              'Выделите подтип перед созданием блюда\nДля этого кликните по необходимой позиции в нижнем левом блоке экрана.\nДля снятие выделения кликните ту же позицию еще раз'),
                          duration: Duration(seconds: 5),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(bar);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: AutoSizeText(
                        'Добавить блюдо',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                        maxLines: 1,
                        // overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<Dish>>(
                    future: HTTPRequests().getAllDishes(),
                    builder: ((context, snapshot) {
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
                      List<Dish> dishList = snapshot.data!;
                      return Expanded(
                          child: SingleChildScrollView(
                        child: Wrap(
                            runSpacing: 10,
                            children: List.generate(
                                dishList.length,
                                (index) => IntrinsicHeight(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: getColorForDish(
                                                index, dishList[index].status!),
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                        child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Wrap(
                                              direction: Axis.horizontal,
                                              alignment:
                                                  WrapAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${dishList[index].name!} ${dishList[index].cost}₽',
                                                    style: const TextStyle(
                                                        fontSize: 20),
                                                    maxLines: null,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                                IntrinsicHeight(
                                                  child: Wrap(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Подтверждение действия'),
                                                                  content: Text(
                                                                      'Вы уверены что хотите безвозвратно удалить блюдо:\n${dishList[index].name}'),
                                                                  actions: [
                                                                    FloatingActionButton(
                                                                      child: const Text(
                                                                          "Отмена"),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                    ),
                                                                    FloatingActionButton(
                                                                      child: const Text(
                                                                          "Ок"),
                                                                      onPressed:
                                                                          () async {
                                                                        int res =
                                                                            await HTTPRequests().deleteDish(dishList[index].id!);
                                                                        if (res !=
                                                                            200) {
                                                                          const bar =
                                                                              SnackBar(content: Text('Упс.. Чтото пошло не так, попробуйте позже'));
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(bar);
                                                                        } else {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          setState(
                                                                              () {});
                                                                          const bar =
                                                                              SnackBar(content: Text('Блюдо успешно удалено'));
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(bar);
                                                                        }
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        icon: const Icon(
                                                            Icons.delete),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                txtDishName
                                                                        .text =
                                                                    dishList[
                                                                            index]
                                                                        .name!;
                                                                txtDishCost
                                                                    .text = dishList[
                                                                        index]
                                                                    .cost
                                                                    .toString();
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Изменение блюда:\n${dishList[index].name}'),
                                                                  content: Wrap(
                                                                    children: [
                                                                      TextField(
                                                                        decoration:
                                                                            const InputDecoration(labelText: 'Наименование'),
                                                                        controller:
                                                                            txtDishName,
                                                                      ),
                                                                      TextFormField(
                                                                        validator:
                                                                            (value) {
                                                                          return (value != null && int.tryParse(value) != null
                                                                              ? 'Введите целое число'
                                                                              : null);
                                                                        },
                                                                        decoration:
                                                                            const InputDecoration(labelText: 'Цена'),
                                                                        controller:
                                                                            txtDishCost,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    FloatingActionButton(
                                                                      child: const Text(
                                                                          "Отмена"),
                                                                      onPressed:
                                                                          () {
                                                                        txtDishName
                                                                            .clear();
                                                                        txtDishCost
                                                                            .clear();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                    ),
                                                                    FloatingActionButton(
                                                                      child: const Text(
                                                                          "Ок"),
                                                                      onPressed:
                                                                          () async {
                                                                        int res = await HTTPRequests().updateDish(dishList[index].copyWith(
                                                                            cost:
                                                                                int.parse(txtDishCost.text),
                                                                            name: txtDishName.text));
                                                                        if (res !=
                                                                            200) {
                                                                          const bar =
                                                                              SnackBar(content: Text('Упс.. Чтото пошло не так, попробуйте позже'));
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(bar);
                                                                        } else {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          setState(
                                                                              () {});
                                                                          const bar =
                                                                              SnackBar(content: Text('Блюдо успешно обновлено'));
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(bar);
                                                                          txtDishName
                                                                              .clear();
                                                                          txtDishCost
                                                                              .clear();
                                                                        }
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        icon: const Icon(
                                                            Icons.edit),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Подтверждение действия'),
                                                                  content:
                                                                      const Text(
                                                                          'Вы уверены что хотите добавить блюдо в стоп-лист'),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Отмена')),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          await HTTPRequests().updateDishStatus(
                                                                              dishList[index].id!,
                                                                              false);
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child: const Text(
                                                                            'Ок')),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        icon: const Icon(Icons
                                                            .not_interested_rounded),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Подтверждение действия'),
                                                                  content:
                                                                      const Text(
                                                                          'Вы уверены что хотите убрать блюдо из стоп-листа'),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Отмена')),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          await HTTPRequests().updateDishStatus(
                                                                              dishList[index].id!,
                                                                              true);
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child: const Text(
                                                                            'Ок')),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        icon: const Icon(Icons
                                                            .task_alt_outlined),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                    ))),
                      ));
                    })),
              ],
            ),
          ),
          Container(
            width: skWidth * 0.33,
            height: double.infinity,
            color: Colors.grey.shade200,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return StatefulBuilder(
                                builder: (context, alertDialogState) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Добавление официанта',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    content: Wrap(
                                      children: [
                                        TextField(
                                          style: const TextStyle(fontSize: 14),
                                          decoration: const InputDecoration(
                                              labelText: 'Фамилия'),
                                          controller: txtEmployeeSurname,
                                        ),
                                        TextField(
                                          style: const TextStyle(fontSize: 14),
                                          decoration: const InputDecoration(
                                              labelText: 'Имя'),
                                          controller: txtEmployeeName,
                                        ),
                                        TextField(
                                          style: const TextStyle(fontSize: 14),
                                          decoration: const InputDecoration(
                                              labelText: 'Пароль'),
                                          controller: txtEmployeePassword,
                                        ),
                                        Wrap(
                                          direction: Axis.horizontal,
                                          alignment: WrapAlignment.start,
                                          spacing: 10,
                                          runSpacing: 10,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          runAlignment: WrapAlignment.start,
                                          children: [
                                            const Text('Администратор'),
                                            Checkbox(
                                              value: accessLevel,
                                              onChanged: (newValue) {
                                                alertDialogState(() {
                                                  accessLevel =
                                                      newValue!; /////////////////////////////////////
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    actions: [
                                      FloatingActionButton(
                                        child: const Text("Отмена"),
                                        onPressed: () {
                                          txtEmployeeName.clear();
                                          txtEmployeeSurname.clear();
                                          txtEmployeePassword.clear();
                                          accessLevel = false;
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FloatingActionButton(
                                        child: const Text("Ок"),
                                        onPressed: () async {
                                          if (txtEmployeeName.text.isEmpty ||
                                              txtEmployeeSurname.text.isEmpty ||
                                              txtEmployeePassword
                                                  .text.isEmpty) {
                                            const bar = SnackBar(
                                              content: Text(
                                                  'Введите Фамилию, имя и пароль нового пользователя.\nПри необходимости предоставьте права администратора при помощи поля чекбокс'),
                                              duration: Duration(seconds: 3),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(bar);
                                          } else {
                                            int res = await HTTPRequests()
                                                .saveEmployee(Employee(
                                                    surname:
                                                        txtEmployeeSurname.text,
                                                    name: txtEmployeeName.text,
                                                    password:
                                                        txtEmployeePassword
                                                            .text,
                                                    accessLevel: accessLevel
                                                        ? '1'
                                                        : '2'));
                                            setState(() {});
                                            if (res == 200) {
                                              Navigator.of(context).pop();
                                              txtEmployeeName.clear();
                                              txtEmployeeSurname.clear();
                                              txtEmployeePassword.clear();
                                              accessLevel = false;
                                              const bar = SnackBar(
                                                content: Text(
                                                    'Новый пользователь успешно сохранён'),
                                                duration: Duration(seconds: 2),
                                              );
                                              setState(() {});
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(bar);
                                            } else {
                                              const bar = SnackBar(
                                                content: Text(
                                                    'Упс, что то пошло не так поробуйте позже'),
                                                duration: Duration(seconds: 2),
                                              );
                                              setState(() {});
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(bar);
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: AutoSizeText(
                            'Добавить официанта',
                            style: TextStyle(
                              fontSize: 22,
                            ),
                            maxLines: 1,
                            // overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: FutureBuilder<List<Employee>>(
                      future: HTTPRequests().getAllEmploees(),
                      builder: ((context, snapshot) {
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
                        List<Employee> employeeList = snapshot.data!;
                        return SingleChildScrollView(
                          child: Wrap(
                              runSpacing: 10,
                              children: List.generate(
                                  employeeList.length,
                                  (index) => IntrinsicHeight(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: index % 2 == 0
                                                  ? Colors.grey.shade300
                                                  : Colors.grey.shade400,
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: Wrap(
                                                direction: Axis.horizontal,
                                                alignment:
                                                    WrapAlignment.spaceBetween,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      '${employeeList[index].surname!} ${employeeList[index].name!} ${employeeList[index].accessLevel == '1' ? 'Админ' : 'Официант'}',
                                                      style: const TextStyle(
                                                          fontSize: 20),
                                                      maxLines: null,
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                  IntrinsicHeight(
                                                    child: Wrap(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () async {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Подтверждение действия'),
                                                                    content: Text(
                                                                        'Вы уверены что хотите удалить официанта:\n ${employeeList[index].surname} ${employeeList[index].name}'),
                                                                    actions: [
                                                                      ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text('Отмена')),
                                                                      ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            int res =
                                                                                await HTTPRequests().deleteEmployee(employeeList[index].id!);
                                                                            if (res ==
                                                                                200) {
                                                                              Navigator.of(context).pop();
                                                                              const bar = SnackBar(
                                                                                content: Text('Официант успешно удалён'),
                                                                              );
                                                                              ScaffoldMessenger.of(context).showSnackBar(bar);
                                                                            } else {
                                                                              const bar = SnackBar(
                                                                                content: Text('Упс. что-то пошло не так. попробуйте позже.'),
                                                                              );
                                                                              ScaffoldMessenger.of(context).showSnackBar(bar);
                                                                            }
                                                                            setState(() {});
                                                                          },
                                                                          child:
                                                                              const Text('Ок')),
                                                                    ],
                                                                  );
                                                                });
                                                          },
                                                          icon: const Icon(
                                                              Icons.delete),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              )),
                                        ),
                                      ))),
                        );
                      })),
                ),
                IntrinsicHeight(
                  child: Container(
                    color: Colors.grey.shade300,
                    width: double.infinity,
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0))),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  PageHome.routeName,
                                  arguments: args);
                            },
                            child: SizedBox(
                                height: skHeight * 0.09,
                                width: skHeight * 0.09,
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.undo_rounded,
                                      size: 32,
                                    ),
                                    Text(
                                      'Назад',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ))),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0))),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Подтверждение действия"),
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
                                              .emit(AccesLevelInitial());
                                          Navigator.of(context)
                                              .pushNamed(PageLogIn.routeName);
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      size: 32,
                                    ),
                                    Text('Выйти'),
                                  ],
                                ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Color getColorForDishSubType(int index, int id) {
    if (selectedDishSubType.id == id) {
      return Colors.blue.shade200;
    }
    return index % 2 == 0 ? Colors.grey.shade300 : Colors.grey.shade400;
  }

  Color getColorForDishType(int index, int id) {
    if (selectedDishType.id == id) {
      return Colors.blue.shade200;
    }
    return index % 2 == 0 ? Colors.grey.shade300 : Colors.grey.shade400;
  }

  Color getColorForDish(int index, bool status) {
    if (!status) {
      return Colors.red.shade200;
    }
    return index % 2 == 0 ? Colors.grey.shade300 : Colors.grey.shade400;
  }
}
