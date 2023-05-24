import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kurskafedesktop/model/chekk.dart';
import 'package:kurskafedesktop/model/dish.dart';
import 'package:kurskafedesktop/model/dishtype.dart';
import 'package:kurskafedesktop/model/employee.dart';

import 'model/dish_sub_type.dart';
import 'model/todo.dart';
import 'env_prop.dart';

class HTTPRequests {
  final BaseOptions options = BaseOptions(
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 10), // 60 seconds
    receiveTimeout: const Duration(seconds: 10), // 60 seconds
    headers: {
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=500" "max=1000"
    },
  );
  final dio = Dio();

  Future<Employee> signIn(String password) async {
    Employee employee = Employee(id: 0);
    try {
      dio.options = options;
      var result =
          await dio.get("http://${Env.localhost}:8080/emp/auth/${password}");
      var data = Employee.fromJson(result.data);
      if (result.statusCode == 200) {
        employee = data;
      }
    } on DioError catch (e) {
      print("${e.error}\n${e.message}");
    }
    return employee;
  }

  Future<List<Employee>> getAllEmploees() async {
    List<Employee> listEmployee = [];
    dio.options = options;
    var result = await dio.get("http://${Env.localhost}:8080/emp/getAll");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      listEmployee = jsonList.map((json) => Employee.fromJson(json)).toList();
    }
    return listEmployee;
  }

  Future<int> saveEmployee(Employee employee) async {
    dio.options = options;
    dynamic result;
    try {
      result = await dio.post("http://${Env.localhost}:8080/emp/save",
          data: employee.toJson());
      return result.statusCode!;
    } on DioError catch (e) {}
    return 0;
  }

  Future<int> deleteEmployee(int id) async {
    dio.options = options;
    dynamic result;
    try {
      result = await dio.put("http://${Env.localhost}:8080/emp/delete/$id");
      return result.statusCode!;
    } on DioError catch (e) {}
    return 0;
  }

  Future<int> createChekk(int persons, String table, int id) async {
    try {
    var result = await dio.post(
        "http://${Env.localhost}:8080/chekk/add/${persons}/${table}/${id}");
    if (result.statusCode == 200) {
      return 0;
    }
    } on DioError catch (e) {
      print("${e.error}\n${e.message}");
      return 1;
    }
    return 0;
  }

  Future<List<Chekk>> getAllChekks(int id) async {
    List<Chekk> chekkList = [];
    // try {
    var result =
        await dio.get("http://${Env.localhost}:8080/chekk/getAll/${id}");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      chekkList = jsonList.map((json) => Chekk.fromJson(json)).toList();
    }
    // } on DioError catch (e) {
    //   print("${e.error}\n${e.message}");
    // }
    return chekkList;
  }

  Future<List<Chekk>> getAllChekksForAdmin() async {
    List<Chekk> chekkList = [];
    // try {
    var result = await dio.get("http://${Env.localhost}:8080/chekk/getAll");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      chekkList = jsonList.map((json) => Chekk.fromJson(json)).toList();
    }
    // } on DioError catch (e) {
    //   print("${e.error}\n${e.message}");
    // }
    return chekkList;
  }

  Future<Chekk> getCurentChekk(int id) async {
    Chekk chekk = Chekk();
    // try {
    var result =
        await dio.get("http://${Env.localhost}:8080/chekk/getCurent/${id}");
    if (result.statusCode == 200) {
      chekk = Chekk.fromJson(result.data);
    }
    // } on DioError catch (e) {
    //   print("${e.error}\n${e.message}");
    // }
    return chekk;
  }

  Future<List<DishType>> getDishTypes() async {
    List<DishType> disTypehList = [];
    var result = await dio.get("http://${Env.localhost}:8080/dishType/getAll");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      disTypehList = jsonList.map((json) => DishType.fromJson(json)).toList();
    }
    return disTypehList;
  }

  Future<int> deleteDishType(int id) async {
    var result =
        await dio.put("http://${Env.localhost}:8080/dishType/delete/$id");
    return result.statusCode!;
  }

  Future<void> saveDishType(String dishtype) async {
    try {
      await dio.post(
        "http://${Env.localhost}:8080/saveDishType",
        data: dishtype,
      );
    } on DioError catch (e) {}
  }

  Future<void> saveDishSubType(String dishSubType, int id) async {
    try {
      await dio.post(
        "http://${Env.localhost}:8080/saveDishSubType/${id}",
        data: dishSubType,
      );
    } on DioError catch (e) {}
  }

  Future<int> deleteDishSubType(int id) async {
    var result =
        await dio.put("http://${Env.localhost}:8080/dishSubType/delete/$id");
    return result.statusCode!;
  }

  Future<List<DishSubType>> getDishSubTypes(int id) async {
    List<DishSubType> dishSubTypehList = [];
    var result =
        await dio.get("http://${Env.localhost}:8080/dishSubType/get/$id");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      dishSubTypehList =
          jsonList.map((json) => DishSubType.fromJson(json)).toList();
    }
    return dishSubTypehList;
  }

  Future<List<DishSubType>> getAllDishSubTypes() async {
    List<DishSubType> dishSubTypehList = [];
    var result =
        await dio.get("http://${Env.localhost}:8080/dishSubType/getAll");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      dishSubTypehList =
          jsonList.map((json) => DishSubType.fromJson(json)).toList();
    }
    return dishSubTypehList;
  }

  Future<List<Dish>> getDishes(int id) async {
    List<Dish> dishList = [];
    var result = await dio.get("http://${Env.localhost}:8080/dish/get/$id");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      dishList = jsonList.map((json) => Dish.fromJson(json)).toList();
    }
    return dishList;
  }

  Future<int> saveDish(Dish dish, int id) async {
    try {
      var result = await dio.post(
          "http://${Env.localhost}:8080/dish/saveWithSubType/$id",
          data: dish.toJson());
      return result.statusCode!;
    } on DioError catch (e) {}
    return 0;
  }

  Future<int> deleteDish(int id) async {
    try {
      var result =
          await dio.put("http://${Env.localhost}:8080/dish/DeleteById/$id");
      return result.statusCode!;
    } on DioError catch (e) {}
    return 0;
  }

  Future<int> updateDish(Dish dish) async {
    try {
      var result = await dio.put("http://${Env.localhost}:8080/dish/update",
          data: dish.toJson());
      return result.statusCode!;
    } on DioError catch (e) {}
    return 0;
  }

  Future<int> updateDishStatus(int id, bool status) async {
    try {
      var result = await dio
          .put("http://${Env.localhost}:8080/dish/updateStatus/$id/$status");
      return result.statusCode!;
    } on DioError catch (e) {}
    return 0;
  }

  Future<List<Dish>> getAllDishes() async {
    List<Dish> dishList = [];
    var result = await dio.get("http://${Env.localhost}:8080/dish/getAll");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      dishList = jsonList.map((json) => Dish.fromJson(json)).toList();
    }
    return dishList;
  }

  Future<List<Dish>> getDishesInChekk(int chekkId) async {
    List<Dish> dishList = [];
    var result = await dio
        .get("http://${Env.localhost}:8080/dish/getDishesInChekk/$chekkId");
    if (result.statusCode == 200) {
      List<dynamic> jsonList = result.data;
      dishList = jsonList.map((json) => Dish.fromJson(json)).toList();
    }
    return dishList;
  }

  Future<void> saveChekkEdit(int id, List<Dish> dishes) async {
    List<Dish> dishesForSave = [];
    for (var element in dishes) {
      if (!element.status!) {
        dishesForSave.add(element);
      }
    }
    await dio.put(
      "http://${Env.localhost}:8080/chekkUpdateChekk/$id",
      data: dishesForSave.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> saveToDo(String toDo, int id) async {
    await dio.post(
      "http://${Env.localhost}:8080/saveToDo/$id",
      data: toDo,
    );
  }

  Future<List<ToDo>> getAllToDoes(int id) async {
    var result = await dio.get("http://${Env.localhost}:8080/getAllTodoes/$id");
    List<dynamic> jsonList = result.data;
    List<ToDo> todoes = jsonList.map((json) => ToDo.fromJson(json)).toList();
    return todoes;
  }

  Future<void> deleteToDo(int id) async {
    await dio.post(
      "http://${Env.localhost}:8080/deleteToDo/$id",
    );
  }
}
