import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smth_about_bank/better_solution/bank_screen.dart';
import 'package:smth_about_bank/better_solution/cubit/bank_cubit.dart';
import 'package:smth_about_bank/injection.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider<BankCubit>(
        create: (context) => getIt.get()..loadTypes(),
        child: const BankScreen(),
      ),
    );
  }
}
