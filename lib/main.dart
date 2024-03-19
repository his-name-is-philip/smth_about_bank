// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smth_about_bank/bank_cubit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:smth_about_bank/better_solution/app.dart';
import 'package:smth_about_bank/card.dart';
import 'package:smth_about_bank/injection.dart';

void main() {
  initializeInjection();
  runApp(const App());
}

// <––––––––––––––––––––––––– LEGACY –––––––––––––––––––––––––>

//прочитал, что люди ее используют,
//только чем оно лучше глобальных переменных, я не понял
final GetIt _gi = GetIt.instance;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // debugPaintSizeEnabled = true;
    var digitTS = TextStyle(
        fontFamily: 'Credit',
        height: 2,
        fontSize: 16,
        color: Color.fromRGBO(0, 0, 0, 0.8));
    var customTextTheme = Theme.of(context).textTheme.copyWith(
          displayLarge: digitTS,
          displayMedium: digitTS.copyWith(fontSize: 12), // for card holder name
        );

    if (!_gi.isRegistered<TextTheme>()) {
      _gi.registerSingleton<TextTheme>(customTextTheme);
    }
    if (!_gi.isRegistered<BankCubit>()) {
      _gi.registerSingleton<BankCubit>(BankCubit());
    }
    return BlocProvider<BankCubit>(
      create: (_) => _gi.get<BankCubit>()..initTypes(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
            textTheme: customTextTheme),
        home: const HomelessPage(),
      ),
    );
  }
}

//============================================================

class HomelessPage extends StatelessWidget {
  const HomelessPage({super.key});

  static const _reservePath = 'images/no_name_bank.png';
  static const _cardAssets = [
    'images/Visa.svg',
    'images/Mastercard.svg',
    'images/Discover.svg',
    'images/JCB.svg',
    'images/AmericanExpress.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocConsumer<BankCubit, UIState>(
        listenWhen: (previous, current) => current.unhandledError != null,
        listener: (BuildContext context, UIState state) {
          _showToast(state.unhandledError.toString());
          state.unhandledError = null;
        },
        builder: (BuildContext ctx, state) {
          String bankPath;
          if (state.card != null) {
            // bankPath = 'images/${state.cardTypes[state.card!.type]}.svg';
          } else {
            if (state.selected != null) {
              bankPath = 'images/${state.cardTypes[state.selected!]}.svg';
            } else {
              bankPath = _reservePath;
            }
          }

          switch ((state.isListLoading, state.unloaded == Unloaded.list)) {
            case (true, true):
              throw Exception(
                  "list marked as unloaded, but loading wasn't complete");
            case (true, false):
              return Center(child: CircularProgressIndicator());
            case (false, true):
              //region 'try again' block
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      'Loading error occurred.\n'
                      'Please check your internet connection and try again',
                      textAlign: TextAlign.center,
                      style: _gi.get<TextTheme>().bodyLarge,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _gi.get<BankCubit>().initTypes(),
                    child: Text('try again'),
                  )
                ],
              );
            //endregion
            case (false, false):
              Card card;
              if (state.unloaded == Unloaded.card) {
                // card = Card.error();
              } else {
                // card = state.card ?? Card.empty();
              }
              const fabSize = 60.0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(flex: 3),
                  if (state.isCardLoading)
                    //region Load Indicator
                    SizedBox(
                        height: _cardSize(ctx).height + fabSize / 2,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeAlign:
                                CircularProgressIndicator.strokeAlignCenter,
                          ),
                        ))
                  //endregion
                  else
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: fabSize / 2),
                          // child: _card(card, _cardSize(ctx), bankPath),
                        ),
                        if (state.unloaded == Unloaded.card)
                          Positioned(
                            bottom: 0,
                            right: 30,
                            child: SizedBox(
                              width: fabSize,
                              height: fabSize,
                              child: FloatingActionButton(
                                shape: const CircleBorder(),
                                elevation: 0,
                                onPressed: () => _gi.get<BankCubit>().genCard(),
                                child: Icon(
                                  Icons.restart_alt_rounded,
                                  size: fabSize * 5 / 8,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  Spacer(),
                  _typeRadios(state),
                  Spacer(flex: 3),
                ],
              );
          }
        },
      ),
    );
  }

  Widget _card(Card c, ({double width, double height}) size, String bankPath) =>
      Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
            color: Colors.lightGreen[200],
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(flex: 4),
            Expanded(
              flex: 8,
              child: Container(color: Colors.black),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 2, 0, 0),
                child: Text(
                  c.number,
                  style: _gi.get<TextTheme>().displayLarge, // digit text theme
                ),
              ),
            ),
            Expanded(
              flex: 16,
              child: Padding(
                padding: EdgeInsets.only(left: 18, right: 5),
                child: SizedBox(
                  width: size.width,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _dateCvvPin(c),
                            ),
                            Expanded(
                                flex: 2,
                                child: Text(c.name,
                                    style: _gi.get<TextTheme>().displayMedium)),
                            Spacer(),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Image.asset('images/chip.png',
                                    fit: BoxFit.fitHeight)),
                            Expanded(
                                flex: 5,
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: _bankImage(bankPath)))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Column _typeRadios(UIState state) => Column(
        children: [
          for (final (index, title) in state.cardTypes.indexed)
            RadioListTile<int>(
                value: index,
                groupValue: state.selected,
                title: Text(title),
                onChanged: _gi.get<BankCubit>().onItemSelected),
        ],
      );

  ({double width, double height}) _cardSize(BuildContext ctx) {
    double width = MediaQuery.of(ctx).size.width;
    width -= 60;
    double height = width * 53.98 / 85.6;
    return (width: width, height: height);
  }

  Row _dateCvvPin(Card card) {
    return Row(
      children: [
        _labelAndValue('VALID THRU', card.date),
        SizedBox(width: 15),
        _labelAndValue('CVV', card.cvv),
        SizedBox(width: 15),
        _labelAndValue('PIN', card.pin)
      ],
    );
  }

  Column _labelAndValue(String label, String value) {
    var labelStyle = _gi.get<TextTheme>().labelSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: labelStyle,
        ),
        Text(
          value,
          style: _gi.get<TextTheme>().displayLarge, // digit text theme
        ),
      ],
    );
  }

  Widget _bankImage(String path) {
    return switch (_cardAssets.contains(path)) {
      true => SvgPicture.asset(path, fit: BoxFit.contain),
      false => Image.asset(_reservePath, fit: BoxFit.contain)
    };
  }

  void _showToast(String msg) => Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 5,
      textColor: Colors.white,
      fontSize: 16.0);
}
