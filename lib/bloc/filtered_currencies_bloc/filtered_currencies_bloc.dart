import 'package:flutter_bloc/flutter_bloc.dart';

import 'filtered_currencies_event.dart';

class FilteredCurrenciesBloc
    extends Bloc<FilteredCurrenciesEvent, List<String>> {
  FilteredCurrenciesBloc() : super([]);

  @override
  Stream<List<String>> mapEventToState(FilteredCurrenciesEvent event) async* {
    if (event is UpdateSettingsEvent) {
      yield event.enabledValuesAbbrs;
    }
  }
}
