import 'package:currencies_viewer_test/models/currencies.dart';

class FilteredCurrenciesEvent {}

class UpdateSettingsEvent extends FilteredCurrenciesEvent {
  late String enabledValuesAbbr;
  UpdateSettingsEvent(this.enabledValuesAbbr);
}

