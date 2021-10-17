import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_event.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_state.dart';
import 'package:currencies_viewer_test/bloc/filtered_currencies_bloc/filtered_currencies_bloc.dart';
import 'package:currencies_viewer_test/models/currencies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<dynamic> responseTransformer() async {
    //TODO: comment about logic

    await Future.delayed(Duration(seconds: 3));
    Response yesterdayCurrenciesResponse = await Currencies.fetchCurrencies(
        DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 1))));
    await Future.delayed(Duration(seconds: 3));
    Response todayCurrenciesResponse = await Currencies.fetchCurrencies(
        DateFormat('yyyy-MM-dd').format(DateTime.now()));
    await Future.delayed(Duration(seconds: 3));
    Response tomorrowCurrenciesResponse = await Currencies.fetchCurrencies(
        DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 1))));

    switch (yesterdayCurrenciesResponse.statusCode &
        todayCurrenciesResponse.statusCode &
        tomorrowCurrenciesResponse.statusCode) {
      case 200:
        Currencies yesterdayCurrencies = Currencies.fromJson(
            json.decode('{"data" : ' + yesterdayCurrenciesResponse.body + '}'));
        Currencies todayCurrencies = Currencies.fromJson(
            json.decode('{"data" : ' + todayCurrenciesResponse.body + '}'));
        Currencies tomorrowCurrencies = Currencies.fromJson(
            json.decode('{"data" : ' + tomorrowCurrenciesResponse.body + '}'));

        //TODO: comment about logic

        List<double> todayRates =
            todayCurrencies.data.map((e) => e.curOfficialRate).toList();
        List<double> tomorrowRates =
            tomorrowCurrencies.data.map((e) => e.curOfficialRate).toList();

        if (listEquals(todayRates, tomorrowRates)) {
          List<Currencies> dataToBloc = [todayCurrencies, yesterdayCurrencies];
          context.read<CurrenciesBloc>().add(UpdateEvent(dataToBloc));
          return dataToBloc;
        } else {
          List<Currencies> dataToBloc = [todayCurrencies, tomorrowCurrencies];
          context.read<CurrenciesBloc>().add(UpdateEvent(dataToBloc));
          return dataToBloc;
        }

      default:
        List<int> statusCodes = {
          yesterdayCurrenciesResponse.statusCode,
          todayCurrenciesResponse.statusCode,
          tomorrowCurrenciesResponse.statusCode
        }.toList();
        statusCodes.removeWhere((element) => element == 200);
        context
            .read<CurrenciesBloc>()
            .add(ErrorEvent("Код ошибки: ${statusCodes.toString()}"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesBloc, CurrenciesState>(
        builder: (context, state) {
      return BlocBuilder<FilteredCurrenciesBloc, List<String>>(
          builder: (context, filterState) {
        if (state.connectionState == ConnectionStates.noError &&
            state.currencies.isNotEmpty) {
          List<Data> firsDayList = [];
          for(var a in state.currencies.first.data) {
            firsDayList.add(a);
          }
          firsDayList.removeWhere((e) => !filterState.contains(e.curAbbreviation));

          List<Data> secondDayList = [];
          for(var a in state.currencies.last.data) {
            secondDayList.add(a);
          }
          secondDayList.removeWhere((e) => !filterState.contains(e.curAbbreviation));

          var firstDayCurrenciesBlocData = firsDayList;
          var secondDayCurrenciesBlocData = secondDayList;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Курсы валют"),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('settings');
                    },
                    icon: const Icon(Icons.settings_sharp)),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                try {
                  await responseTransformer();
                } on SocketException catch (e) {
                  context.read<CurrenciesBloc>().add(ErrorEvent(e.message));
                }
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Table(
                      columnWidths: <int, TableColumnWidth>{
                        0: FixedColumnWidth(
                            MediaQuery.of(context).size.width / 2),
                        1: FixedColumnWidth(
                            MediaQuery.of(context).size.width / 4),
                        2: FixedColumnWidth(
                            MediaQuery.of(context).size.width / 4)
                      },
                      children: [
                        TableRow(children: [
                          const TableCell(
                              child: Text(
                            "Валюта",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          TableCell(
                              child: Text(DateFormat("dd.mm.yyyy").format(
                                  DateTime.parse(state
                                      .currencies.first.data.first.date)))),
                          TableCell(
                              child: Text(DateFormat("dd.mm.yyyy").format(
                                  DateTime.parse(
                                      state.currencies.last.data.first.date)))),
                        ])
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 47),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: firstDayCurrenciesBlocData.length,
                        itemBuilder: (BuildContext context, index) {
                          return Container(
                              padding: const EdgeInsets.all(15),
                              width: 300,
                              child: Table(
                                columnWidths: <int, TableColumnWidth>{
                                  0: FixedColumnWidth(
                                      MediaQuery.of(context).size.width / 1.9),
                                  1: FixedColumnWidth(
                                      MediaQuery.of(context).size.width / 4),
                                  2: FixedColumnWidth(
                                      MediaQuery.of(context).size.width / 4)
                                },
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                        child: Column(
                                      children: [
                                        Text(
                                          firstDayCurrenciesBlocData[index]
                                              .curAbbreviation,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            "${firstDayCurrenciesBlocData[index].curScale} ${firstDayCurrenciesBlocData[index].curName}",
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    )),
                                    TableCell(
                                        child: Text(
                                            "${firstDayCurrenciesBlocData[index].curOfficialRate}")),
                                    TableCell(
                                        child: Text(
                                            "${secondDayCurrenciesBlocData[index].curOfficialRate}")),
                                  ])
                                ],
                              ));
                        }),
                  ),
                ],
              ),
            ),
          );
        } else if (state.connectionState == ConnectionStates.hasError) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("Курсы валют"),
                centerTitle: true,
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  try {
                    await responseTransformer();
                  } on SocketException catch (e) {
                    context.read<CurrenciesBloc>().add(ErrorEvent(e.message));
                  }
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 2.5),
                    child: Center(
                        child: Text(
                      "Не удалось получить курсы валют.\n${context.read<CurrenciesBloc>().state.statusCode}",
                      textAlign: TextAlign.center,
                    )),
                  ),
                ),
              ));
        } else {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(color: Colors.blueGrey),
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    try {
      await responseTransformer();
    } on SocketException catch (e) {
      context.read<CurrenciesBloc>().add(ErrorEvent(e.message));
    }
  }
}
