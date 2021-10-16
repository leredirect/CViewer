import 'dart:convert';
import 'dart:io';

import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_event.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_state.dart';
import 'package:currencies_viewer_test/models/currencies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    Response yesterdayCurrenciesResponse = await Currencies.fetchCurrencies(
        DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 1))));
    Response todayCurrenciesResponse = await Currencies.fetchCurrencies(
        DateFormat('yyyy-MM-dd').format(DateTime.now()));
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

        List<double> todayRates = todayCurrencies.data.map((e) => e.curOfficialRate).toList();
        List<double> tomorrowRates = tomorrowCurrencies.data.map((e) => e.curOfficialRate).toList();

        if (listEquals(todayRates,tomorrowRates)) {
          List<Currencies> dataToBloc = [todayCurrencies, yesterdayCurrencies];
          context.read<CurrenciesBloc>().add(UpdateEvent(dataToBloc));
          return dataToBloc;
        } else {
          List<Currencies> dataToBloc = [todayCurrencies, tomorrowCurrencies];
          context.read<CurrenciesBloc>().add(UpdateEvent(dataToBloc));
          return dataToBloc;
        }
      default:
        context.read<CurrenciesBloc>().add(ErrorEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesBloc, CurrenciesState>(
        builder: (context, state) {
      if (state.connectionState == ConnectionStates.noError &&
          state.currencies.isNotEmpty) {
        return Scaffold(
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
                context.read<CurrenciesBloc>().add(ErrorEvent());
              }
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: context
                      .read<CurrenciesBloc>()
                      .state
                      .currencies
                      .first
                      .data
                      .length,
                  itemBuilder: (BuildContext context, index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      color: Colors.blueGrey,
                      width: 300,
                      height: 30,
                      child: Row(
                        children: [
                          Text(context
                              .read<CurrenciesBloc>()
                              .state
                              .currencies
                              .first
                              .data[index]
                              .curName),
                          Spacer(),
                          Text(context
                              .read<CurrenciesBloc>()
                              .state
                              .currencies
                              .first
                              .data[index]
                              .curOfficialRate
                              .toString()),
                          Spacer(),
                          Text(context
                              .read<CurrenciesBloc>()
                              .state
                              .currencies
                              .last
                              .data[index]
                              .curOfficialRate
                              .toString()),
                        ],
                      ),
                    );
                  }),
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
                context.read<CurrenciesBloc>().add(ErrorEvent());
              }
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/2.5),
                child: Center(child: Text("Не удалось получить курсы валют.")),
              ),
            ),
          )
        );
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
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    try {
      await responseTransformer();
    } on SocketException catch (e) {
      context.read<CurrenciesBloc>().add(ErrorEvent());
    }
  }
}
