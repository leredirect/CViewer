import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_event.dart';
import 'package:currencies_viewer_test/bloc/filtered_currencies_bloc/filtered_currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/filtered_currencies_bloc/filtered_currencies_event.dart';
import 'package:currencies_viewer_test/models/currencies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/src/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var currenciesBlocData =
        context.read<CurrenciesBloc>().state;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Настройка валют"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.done)),
        ],
      ),
      body: Container(
        child: BlocBuilder<FilteredCurrenciesBloc, List<String>>(
          builder: (context, state) {
            return ReorderableListView(
              //padding: const EdgeInsets.symmetric(horizontal: 40),
              children: <Widget>[
                for (int index = 0; index < currenciesBlocData.currencies.first.data.length; index++)
                  SwitchListTile(
                    key: Key('$index'),
                    // secondary: Container(
                    //   width: MediaQuery.of(context).size.width / 2.5,
                    //   child: Icon(Icons.menu),
                    // ),
                    title: Text("${currenciesBlocData.currencies.first.data[index].curAbbreviation}"),
                    subtitle: Text(
                        "${currenciesBlocData.currencies.first.data[index].curScale} ${currenciesBlocData.currencies.first.data[index].curName}"),
                    value: state.contains(currenciesBlocData.currencies.first.data[index].curAbbreviation),
                    onChanged: (bool value) {
                      setState(() {
                        print("$value $index");
                       context.read<FilteredCurrenciesBloc>().add(UpdateSettingsEvent(currenciesBlocData.currencies.first.data[index].curAbbreviation));
                      });
                    },
                  ),
              ],
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Data item = currenciesBlocData.currencies.first.data.removeAt(oldIndex);
                  currenciesBlocData.currencies.first.data.insert(newIndex, item);
                  context.read<CurrenciesBloc>().add(UpdateEvent(currenciesBlocData.currencies));
                });
              },
            );
          }
        ),
      ),
    );
  }
}
