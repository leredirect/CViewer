import 'package:flutter_bloc/flutter_bloc.dart';

import 'filtered_currencies_event.dart';

class FilteredCurrenciesBloc
    extends Bloc<FilteredCurrenciesEvent, List<String>> {
  FilteredCurrenciesBloc() : super([]);

  @override
  Stream<List<String>> mapEventToState(FilteredCurrenciesEvent event) async* {
    if (event is UpdateSettingsEvent) {
      List<String> list = List.from(state);
      if (state.contains(event.enabledValuesAbbr)) {
        list.removeWhere((element) => element == event.enabledValuesAbbr);
        yield list;
      } else {
        list.add(event.enabledValuesAbbr);
        yield list;
      }
    }
  }
}
