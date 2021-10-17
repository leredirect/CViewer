import 'package:currencies_viewer_test/models/currencies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'currencies_event.dart';

class CurrenciesState {
  List<Currencies> currencies;
  ConnectionStates connectionState;
String statusCode;
  CurrenciesState(this.currencies, this.connectionState, this.statusCode);
}

enum ConnectionStates{
  hasError,
  noError,
  offline
}
