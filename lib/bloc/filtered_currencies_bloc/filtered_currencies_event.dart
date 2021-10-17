class FilteredCurrenciesEvent {}

class UpdateSettingsEvent extends FilteredCurrenciesEvent {
  List<String> enabledValuesAbbrs;

  UpdateSettingsEvent(this.enabledValuesAbbrs);
}
