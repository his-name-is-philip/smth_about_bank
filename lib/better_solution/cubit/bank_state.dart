import 'package:equatable/equatable.dart';
import 'package:smth_about_bank/card.dart';

class BankState extends Equatable {
  final bool loading;
  final String? error;
  final List<String> cardTypes;
  final Card? card;

  const BankState({
    required this.loading,
    required this.cardTypes,
    this.error,
    this.card,
  });

  factory BankState.initial() => const BankState(loading: false, cardTypes: []);

  BankState copyWith({
    bool? loading,
    String? error,
    List<String>? cardTypes,
    Card? card,
  }) =>
      BankState(
        loading: loading ?? this.loading,
        cardTypes: cardTypes ?? this.cardTypes,
        error: error ?? this.error,
        card: card ?? this.card,
      );

  @override
  List<Object?> get props => [loading, error, cardTypes, card];
}
