import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smth_about_bank/card.dart';
import 'dart:math';

import 'package:smth_about_bank/loader.dart';

class BankCubit extends Cubit<UIState> {
  BankCubit()
      : _typeFuture = _service.loadCardTypes(),
        super(UIState()) {
    _typeFuture.then((_) {}); // это чтоб наверняка вызвалось
  }

  static const RandomService _service = RandomService();
  CancelableOperation? _cardLoading;

  final Future<List<String>> _typeFuture;

  //todo запили кнопку для повтора попытки на случай ошибки
  Future<void> initTypes() async {
    state.isListLoading = true;
    state.unloaded = null;
    _refresh();
    try {
      _service.loadCardTypes();
      state.cardTypes.addAll(await _typeFuture);
      state.isListLoading = false;
      _refresh();
    } catch (e) {
      state.unhandledError = e;
      state.unloaded = Unloaded.list;
      state.isListLoading = false;
      _refresh();
    }
  }

  void genCard() {
    _cardLoading?.cancel();
    // надеюсь, оно вызовется
    _cardLoading = CancelableOperation.fromFuture(_cardFuture());
  }

  Future<void> _cardFuture() async {
    if (state.selected == null) throw Exception('Не выбран тип карты');
    state.isCardLoading = true;
    state.unloaded = null;
    _refresh();
    try {
      int n = state.selected!;
      // state.card = await _service.loadCard(n, state.cardTypes[n]);
      state.isCardLoading = false;
      _refresh();
    } catch (e) {
      state.unhandledError = e;
      state.unloaded = Unloaded.card;
      state.isCardLoading = false;
      _refresh();
    }
  }

  void onItemSelected(int? n) {
    state.selected = n;

    genCard();
  }

  void _refresh() => emit(state);
}

//==============================================================================

class UIState {
  Card? card;
  bool isCardLoading = false; //todo а им точно нужен false?
  bool isListLoading = true;
  var cardTypes = <String>[];
  int? selected; // for changing pic
  Object? unhandledError;
  Unloaded? unloaded;

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => Random().nextInt(0x7FFFFFFFFFFFFFFF);
}

enum Unloaded {
  list,
  card;
}
