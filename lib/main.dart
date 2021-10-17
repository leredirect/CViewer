import 'package:connectivity/connectivity.dart';
import 'package:currencies_viewer_test/screens/home_screen.dart';
import 'package:currencies_viewer_test/screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/connectivity_bloc/connectivity_bloc.dart';
import 'bloc/currencies_bloc/currencies_bloc.dart';
import 'bloc/filtered_currencies_bloc/filtered_currencies_bloc.dart';




void main() {
  runApp(MultiBlocProvider(providers: [
    BlocProvider<ConnectivityBloc>(create: (context) => ConnectivityBloc()),
    BlocProvider<CurrenciesBloc>(create: (context) => CurrenciesBloc()),
    BlocProvider<FilteredCurrenciesBloc>(create: (context) => FilteredCurrenciesBloc()),
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
}
