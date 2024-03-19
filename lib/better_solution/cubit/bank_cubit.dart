import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smth_about_bank/better_solution/cubit/bank_state.dart';
import 'package:smth_about_bank/loader.dart';

class BankCubit extends Cubit<BankState> {
  final IRandomService _service;

  BankCubit(this._service) : super(BankState.initial());

  Future<void> loadTypes() async {
    emit(state.copyWith(loading: true));
    final types = await _service.loadCardTypes();
    emit(state.copyWith(
      loading: false,
      cardTypes: types,
    ));
  }

  Future<void> getCard(String type) async {
    emit(state.copyWith(loading: true));
    final card = await _service.loadCard(type);
    emit(state.copyWith(
      loading: false,
      card: card,
    ));
  }
}
