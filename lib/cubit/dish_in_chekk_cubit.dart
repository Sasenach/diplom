import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dish_in_chekk_state.dart';

class DishInChekkCubit extends Cubit<DishInChekkState> {
  DishInChekkCubit() : super(DishInChekkInitial());
}
