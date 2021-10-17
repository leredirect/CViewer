import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Currencies {
  late List<Data> data;

  Currencies({required this.data});

  Currencies.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data.map((v) => v.toJson()).toList();
    return data;
  }

  static Future<Response> fetchCurrencies(String date) async {
    Response response = await http.get(Uri.parse(
        'https://www.nbrb.by/api/exrates/rates?ondate=' +
            date +
            '&periodicity=0'));
    return response;
  }
}

class Data {
  late int curID;
  late String date;
  late String curAbbreviation;
  late int curScale;
  late String curName;
  late double curOfficialRate;

  Data(
      {required this.curID,
      required this.date,
      required this.curAbbreviation,
      required this.curScale,
      required this.curName,
      required this.curOfficialRate});

  Data.fromJson(Map<String, dynamic> json) {
    curID = json['Cur_ID'];
    date = json['Date'];
    curAbbreviation = json['Cur_Abbreviation'];
    curScale = json['Cur_Scale'];
    curName = json['Cur_Name'];
    curOfficialRate = json['Cur_OfficialRate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Cur_ID'] = curID;
    data['Date'] = date;
    data['Cur_Abbreviation'] = curAbbreviation;
    data['Cur_Scale'] = curScale;
    data['Cur_Name'] = curName;
    data['Cur_OfficialRate'] = curOfficialRate;
    return data;
  }
}
