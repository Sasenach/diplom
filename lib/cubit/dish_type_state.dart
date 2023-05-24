part of 'dish_type_cubit.dart';

@immutable
abstract class DishTypeState {
  
}

class DishTypeInitial extends DishTypeState {}
class DishTypeLoaded extends DishTypeState {}
class DishSubTypeLoaded extends DishTypeState {}
class DishesLoaded extends DishTypeState {}
