import 'package:currencies_viewer_test/screens/home_screen.dart';
import 'package:currencies_viewer_test/screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc/currencies_bloc/currencies_bloc.dart';
import 'bloc/filtered_currencies_bloc/filtered_currencies_bloc.dart';
import 'bloc/filtered_currencies_bloc/filtered_currencies_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    runApp(MultiBlocProvider(providers: [
      BlocProvider<CurrenciesBloc>(create: (context) => CurrenciesBloc()),
      BlocProvider<FilteredCurrenciesBloc>(
          create: (context) => FilteredCurrenciesBloc()),
    ], child: const CurrencyViewerApp(key: Key("key"))));
  });
}

class CurrencyViewerApp extends StatefulWidget {
  const CurrencyViewerApp({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CurrencyViewerAppState();
}

class _CurrencyViewerAppState extends State<CurrencyViewerApp> {
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    var enabledOrderBox = await Hive.openBox('enabledOrder');
    if (enabledOrderBox.isNotEmpty) {
      List<String> enabledOrder = enabledOrderBox.get('list');
      context
          .read<FilteredCurrenciesBloc>()
          .add(UpdateSettingsEvent(enabledOrder));

      enabledOrderBox.close();
    } else {
      const List<String> onFirstExecute = ["USD", "EUR", "RUB"];
      context
          .read<FilteredCurrenciesBloc>()
          .add(UpdateSettingsEvent(onFirstExecute));
    }
  }

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
