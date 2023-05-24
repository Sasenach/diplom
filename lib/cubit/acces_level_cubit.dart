import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'acces_level_state.dart';

class AccesLevelCubit extends Cubit<AccesLevelState> {
  AccesLevelCubit() : super(AccesLevelInitial());
}
