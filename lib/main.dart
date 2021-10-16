import 'package:connectivity/connectivity.dart';
import 'package:currencies_viewer_test/screens/home_screen.dart';
import 'package:currencies_viewer_test/screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/connectivity_bloc/connectivity_bloc.dart';
import 'bloc/connectivity_bloc/connectivity_event.dart';




void main() {
  runApp(MultiBlocProvider(providers: [
    BlocProvider<ConnectivityBloc>(create: (context) => ConnectivityBloc()),
  ], child: const CurrencyViewerApp(key: Key("key"))));
}

class CurrencyViewerApp extends StatefulWidget {
  const CurrencyViewerApp({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CurrencyViewerAppState();
}

class _CurrencyViewerAppState extends State<CurrencyViewerApp> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MaterialApp(
        title: 'CurrencyViewer',
        initialRoute: '/',
        routes: {
          '/': (context) => const SafeArea(child: HomeScreen()),
          'settings': (context) => const SafeArea(child: SettingsScreen()),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    print("DCD+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

    Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        context.read<ConnectivityBloc>().add(OfflineEvent());
      } else {
        context.read<ConnectivityBloc>().add(OnlineEvent());
      }
    });
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        context.read<ConnectivityBloc>().add(OfflineEvent());
      } else {
        context.read<ConnectivityBloc>().add(OnlineEvent());
      }
    });
  }
}
