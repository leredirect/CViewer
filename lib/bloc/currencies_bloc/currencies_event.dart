import 'package:currencies_viewer_test/models/currencies.dart';

class CurrenciesEvent {}

class UpdateEvent extends CurrenciesEvent {
  late List<Currencies> currencies;
  UpdateEvent(this.currencies);
}

class ErrorEvent extends CurrenciesEvent {

}
