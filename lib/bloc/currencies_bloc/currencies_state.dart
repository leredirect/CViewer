import 'package:currencies_viewer_test/models/currencies.dart';

enum ConnectionStates { hasError, noError, offline }

class CurrenciesState {
  List<Currencies> currencies;
  ConnectionStates connectionState;
  String statusCode;

  CurrenciesState(this.currencies, this.connectionState, this.statusCode);
}
