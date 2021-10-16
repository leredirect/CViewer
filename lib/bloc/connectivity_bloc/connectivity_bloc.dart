import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_event.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, bool> {
  ConnectivityBloc() : super(false);

  @override
  Stream<bool> mapEventToState(ConnectivityEvent event) async* {
    if (event is OnlineEvent) {
      yield true;
    } else if (event is OfflineEvent) {
      yield false;
    }
  }
}
