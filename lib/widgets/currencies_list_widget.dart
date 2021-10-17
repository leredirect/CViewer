import 'dart:io';

import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_bloc.dart';
import 'package:currencies_viewer_test/bloc/currencies_bloc/currencies_event.dart';
import 'package:currencies_viewer_test/models/currencies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CurrenciesListWidget extends StatelessWidget {
  final Function responseTransformer;
  final List<Data> firstDayCurrenciesBlocData;
  final List<Data> secondDayCurrenciesBlocData;

  const CurrenciesListWidget(
      {Key? key,
      required this.responseTransformer,
      required this.firstDayCurrenciesBlocData,
      required this.secondDayCurrenciesBlocData})
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
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Table(
              columnWidths: <int, TableColumnWidth>{
                0: FixedColumnWidth(MediaQuery.of(context).size.width / 2),
                1: FixedColumnWidth(MediaQuery.of(context).size.width / 4),
                2: FixedColumnWidth(MediaQuery.of(context).size.width / 4)
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
                          DateTime.parse(context
                              .read<CurrenciesBloc>()
                              .state
                              .currencies
                              .first
                              .data
                              .first
                              .date)))),
                  TableCell(
                      child: Text(DateFormat("dd.mm.yyyy").format(
                          DateTime.parse(context
                              .read<CurrenciesBloc>()
                              .state
                              .currencies
                              .last
                              .data
                              .first
                              .date)))),
                ])
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 47),
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "${firstDayCurrenciesBlocData[index].curScale} ${firstDayCurrenciesBlocData[index].curName}",
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
