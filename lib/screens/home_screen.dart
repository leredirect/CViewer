import 'dart:convert';
import 'dart:io';

import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_event.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_state.dart';
import 'package:currencies_viewer_test/bloc/filtered_currencies_bloc/filtered_currencies_bloc.dart';
import 'package:currencies_viewer_test/models/currencies.dart';
import 'package:currencies_viewer_test/widgets/currencies_list_widget.dart';
import 'package:currencies_viewer_test/widgets/error_widget.dart';
import 'package:currencies_viewer_test/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Data> sorter(List<Data> data, List<String> values) {
    List<Data> result = [];

    for (int i = 0; i < values.length; i++) {
      result.add(
          data.firstWhere((element) => element.curAbbreviation == values[i]));
    }

    return result;
  }

  Future<void> responseTransformer() async {
    /// Loading and parsing logic:
    /// 1. The NBRB API blocks requests using a
    /// firewall for multiple requests within a minute. Therefore, a user
    /// with frequent use of PullToRefresh will be highly likely to
    /// frequently catch the HTTP 403 error. Using Future.Delayed allows
    /// you to reduce the probability of catching an error.
    ///
    /// 2. I'm not sure if this is this because I did a test task on
    /// the weekend, but the API returns exactly the same response for today
    /// and tomorrow (specifically for Saturday and Sunday, in me case).
    /// Therefore, I act according to the following algorithm: if today's
    /// data and tomorrow's data are identical, I put information about
    /// today's and yesterday's exchange rates in the block. If the exchange
    /// rate of at least one currency for tomorrow is different, I return
    /// today's rate and tomorrow's rate.

    Response yesterdayCurrenciesResponse = await Currencies.fetchCurrencies(
        DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 1))));
    await Future.delayed(const Duration(seconds: 3));
    Response todayCurrenciesResponse = await Currencies.fetchCurrencies(
        DateFormat('yyyy-MM-dd').format(DateTime.now()));
    await Future.delayed(const Duration(seconds: 3));
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

        List<double> todayRates =
            todayCurrencies.data.map((e) => e.curOfficialRate).toList();
        List<double> tomorrowRates =
            tomorrowCurrencies.data.map((e) => e.curOfficialRate).toList();

        if (listEquals(todayRates, tomorrowRates) || tomorrowRates.isEmpty) {
          List<Currencies> dataToBloc = [];

          var orderBox = await Hive.openBox('order');
          if (orderBox.isNotEmpty) {
            List<String> order = orderBox.get('list');
            todayCurrencies.data = sorter(todayCurrencies.data, order);
            yesterdayCurrencies.data = sorter(yesterdayCurrencies.data, order);
            orderBox.close();
          }
          dataToBloc = [todayCurrencies, yesterdayCurrencies];
          context.read<CurrenciesBloc>().add(UpdateEvent(dataToBloc));
        } else {
          List<Currencies> dataToBloc = [];

          var orderBox = await Hive.openBox('order');
          if (orderBox.isNotEmpty) {
            List<String> order = orderBox.get('list');
            todayCurrencies.data = sorter(todayCurrencies.data, order);
            tomorrowCurrencies.data = sorter(tomorrowCurrencies.data, order);
            orderBox.close();
          }
          dataToBloc = [todayCurrencies, tomorrowCurrencies];

          context.read<CurrenciesBloc>().add(UpdateEvent(dataToBloc));
        }
        break;
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
        Widget _currentBody;
        if (state.connectionState == ConnectionStates.noError &&
            state.currencies.isNotEmpty) {
          List<Data> firsDayList = [];
          for (var a in state.currencies.first.data) {
            firsDayList.add(a);
          }
          firsDayList
              .removeWhere((e) => !filterState.contains(e.curAbbreviation));
          List<Data> secondDayList = [];
          for (var a in state.currencies.last.data) {
            secondDayList.add(a);
          }
          secondDayList
              .removeWhere((e) => !filterState.contains(e.curAbbreviation));
          _currentBody = CurrenciesListWidget(
            responseTransformer: responseTransformer,
            firstDayCurrenciesBlocData: firsDayList,
            secondDayCurrenciesBlocData: secondDayList,
          );
        } else if (state.connectionState == ConnectionStates.hasError) {
          _currentBody =
              ErrorScreenWidget(responseTransformer: responseTransformer);
        } else {
          _currentBody = const LoadingWidget();
        }
        return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Курсы валют"),
              centerTitle: true,
              actions: [
                Visibility(
                  visible: state.connectionState == ConnectionStates.noError &&
                      state.currencies.isNotEmpty,
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('settings');
                      },
                      icon: const Icon(Icons.settings_sharp)),
                ),
              ],
            ),
            body: _currentBody);
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
