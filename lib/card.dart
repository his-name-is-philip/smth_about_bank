import 'package:equatable/equatable.dart';

class Card extends Equatable {
  const Card({
    required this.number,
    required this.name,
    required this.cvv,
    required this.pin,
    required this.date,
  });

  final String number;
  final String name;
  final String cvv;
  final String pin;
  final String date;

  @override
  List<Object?> get props => <Object?>[number, name, cvv, pin, date];
}
