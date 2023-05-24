import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:kurskafedesktop/env_prop.dart';
import 'package:meta/meta.dart';

import '../model/dish_sub_type.dart';
import '../model/dishtype.dart';

part 'dish_type_state.dart';

class DishTypeCubit extends Cubit<DishTypeState> {
  DishTypeCubit() : super(DishTypeInitial());
}
