import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_event.dart';
import 'package:currencies_viewer_test/bloc/filtered_currencies_bloc/filtered_currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/filtered_currencies_bloc/filtered_currencies_event.dart';
import 'package:currencies_viewer_test/models/currencies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late List<String> currenciesSwitches;

  @override
  void initState() {
    super.initState();
    currenciesSwitches =
        List.from(context.read<FilteredCurrenciesBloc>().state);
  }

  @override
  Widget build(BuildContext context) {
    var currenciesBlocData = context.read<CurrenciesBloc>().state;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Настройка валют"),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () async {
                  context
                      .read<FilteredCurrenciesBloc>()
                      .add(UpdateSettingsEvent(currenciesSwitches));

                  List<String> order = List.from(currenciesBlocData
                      .currencies.first.data
                      .map((e) => e.curAbbreviation));

                  var orderBox = await Hive.openBox('order');
                  orderBox.put('list', order);
                  orderBox.close();

                  var enabledOrderBox = await Hive.openBox('enabledOrder');
                  enabledOrderBox.put(
                      'list', context.read<FilteredCurrenciesBloc>().state);
                  enabledOrderBox.close();

                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.done)),
          ],
        ),
        body: ReorderableListView(
          children: <Widget>[
            for (int index = 0;
                index < currenciesBlocData.currencies.first.data.length;
                index++)
              Row(
                key: Key('$index'),
                children: [
                  Flexible(
                    child: SwitchListTile(
                      title: Text(currenciesBlocData
                          .currencies.first.data[index].curAbbreviation),
                      subtitle: Text(
                          "${currenciesBlocData.currencies.first.data[index].curScale} ${currenciesBlocData.currencies.first.data[index].curName}"),
                      value: currenciesSwitches.contains(currenciesBlocData
                          .currencies.first.data[index].curAbbreviation),
                      onChanged: (bool value) {
                        setState(() {
                          String abbreviation = currenciesBlocData
                              .currencies.first.data[index].curAbbreviation;
                          if (!value) {
                            currenciesSwitches.removeWhere(
                                (element) => element == abbreviation);
                          } else {
                            currenciesSwitches.add(abbreviation);
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width / 15),
                    child: Icon(
                      Icons.menu,
                      key: Key('$index'),
                    ),
                  )
                ],
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final Data item =
                  currenciesBlocData.currencies.first.data.removeAt(oldIndex);
              currenciesBlocData.currencies.first.data.insert(newIndex, item);
              context
                  .read<CurrenciesBloc>()
                  .add(UpdateEvent(currenciesBlocData.currencies));
            });
          },
        ));
  }
}
