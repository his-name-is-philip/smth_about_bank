import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smth_about_bank/better_solution/cubit/bank_cubit.dart';
import 'package:smth_about_bank/better_solution/cubit/bank_state.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  String? cardType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankCubit, BankState>(builder: (context, state) {
      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Gen a card'),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.cardTypes.length,
                    itemBuilder: (context, index) {
                      final type = state.cardTypes[index];
                      return TextButton(
                        onPressed: () {
                          cardType = type;
                          context.read<BankCubit>().getCard(type);
                        },
                        child: Text(type),
                      );
                    },
                  ),
                ),
                if (state.card != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('''
$cardType

${state.card?.number}
${state.card?.date}   ${state.card?.cvv}
                  '''),
                  ),
              ],
            ),
          ),
          Visibility(
            visible: state.loading,
            child: Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      );
    });
  }
}
