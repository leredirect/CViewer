import 'package:flutter_bloc/flutter_bloc.dart';

import 'currencies_event.dart';
import 'currencies_state.dart';

class CurrenciesBloc extends Bloc<CurrenciesEvent, CurrenciesState> {
  CurrenciesBloc() : super(CurrenciesState([], ConnectionStates.noError, ""));

  @override
  Stream<CurrenciesState> mapEventToState(CurrenciesEvent event) async* {
    if (event is UpdateEvent) {
      yield CurrenciesState(event.currencies, ConnectionStates.noError, "");
    } else if(event is ErrorEvent){
      yield CurrenciesState([], ConnectionStates.hasError, event.statusCode);
    }
  }
}
