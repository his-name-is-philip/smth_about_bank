import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smth_about_bank/bank_cubit.dart';

//https://randommer.io/api/swagger-docs/index.html
enum NameType {
  firstName('firstname'),
  surname('surname'),
  fullName('fullname');

  const NameType(this.value);

  final String value;
}

sealed class HttpException implements Exception {
  @override
  String toString() => switch (this) {
        RequestFailed() => 'Ошибка запроса. Проверьте параметры запроса!!',
        Forbidden() =>
          'Пользователь ограничен в доступе к указанному ресурсу!!',
        NotFound() => 'Ошибка в написании адреса Web-страницы!!',
        UnknownException() => 'Неизвестная ошибка!'
      };
}

final class RequestFailed extends HttpException {} // 400 - ошибка запроса

final class Forbidden extends HttpException {} // 403 – доступ запрещен

final class NotFound extends HttpException {} //404 – не найдено

final class UnknownException extends HttpException {} // != 200

abstract interface class IRandomService {
  Future<List<String>> loadCardTypes();

  Future<Card> loadCard(int typeIndex, String type);
}

final class RandomService implements IRandomService {
  const RandomService();

  static const _apiKey = 'f8f010f6e888495dbce7cc9c02c6cd65';

  static get _headersMap => {'x-api-key': _apiKey};

  /*Future<String> loadName(String nameType) async {
    var dynamics = await _loadRandom('Name', {
      'nameType': nameType,
      'quantity': '1',
    }) as List;
    return dynamics[0].toString();
  }*/

  @override
  Future<List<String>> loadCardTypes() async {
    var dynamics = await _loadRandom('Card/Types', {}) as List;

    var cardTypes = <String>[];
    for (dynamic e in dynamics) {
      cardTypes.add(e.toString());
    }
    return cardTypes;
  }

  @override
  Future<Card> loadCard(int typeIndex, String type) async {
    var cardMap = await _loadRandom('Card', {
      'type': type,
    }) as Map<String, dynamic>;
    var date = DateTime.parse(cardMap['date']);
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString().substring(2);
    return Card(
        number: _formatCardNumber(cardMap),
        name: cardMap['fullName'].toString().toUpperCase(),
        cvv: cardMap['cvv'],
        pin: cardMap['pin'].toString(),
        date: '$month/$year',
        type: typeIndex);
  }

  String _formatCardNumber(Map<String, dynamic> cardMap) {
    String s = cardMap['cardNumber'];
    return '${s.substring(0, 4)} ${s.substring(4, 9)} ${s.substring(8, 13)} ${s.substring(12)}';
  }

  ///returns raw decoded json
  Future<dynamic> _loadRandom(
      String pathName, Map<String, String>? params) async {
    http.Response response;
    response = await http.get(
        Uri.https('randommer.io', '/api/$pathName', params),
        headers: _headersMap);
    _handleError(response.statusCode);
    return jsonDecode(response.body);
  }

  void _handleError(int statusCode) {
    if (statusCode == 400) {
      throw RequestFailed();
    } else if (statusCode == 403) {
      throw Forbidden();
    } else if (statusCode == 404) {
      throw NotFound();
    } else if (statusCode != 200) {
      throw UnknownException();
    }
  }
}
