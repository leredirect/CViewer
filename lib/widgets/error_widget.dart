import 'dart:io';

import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorScreenWidget extends StatelessWidget {
  final Function responseTransformer;

  const ErrorScreenWidget({Key? key, required this.responseTransformer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await responseTransformer();
        } on SocketException catch (e) {
          context.read<CurrenciesBloc>().add(ErrorEvent(e.message));
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.5),
          child: Center(
              child: Text(
            "Не удалось получить курсы валют.\n${context.read<CurrenciesBloc>().state.statusCode}",
            textAlign: TextAlign.center,
          )),
        ),
      ),
    );
  }
}
