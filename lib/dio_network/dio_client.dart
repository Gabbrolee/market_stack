import 'package:dio/dio.dart';

import '../company_model.dart';

class DioClient {

  Dio dio = Dio();
  final String apiKey = '7a786fbfab497e73df54ec8d70027b35';

  Future<List<Company>> getData(String search) async {

    List<Company> companies = [];
    Response response = await dio.get('http://api.marketstack.com/v1/tickers',
        queryParameters: {'access_key' : apiKey, 'limit' : 10, 'offset' : 0, 'search' : search}
    );

    // Print the response data to the console
    print(response.data);

    // Parse the response data
     companies = (response.data['data'] as List)
        .map((data) => Company.fromJson(data))
        .toList();
    return companies;
  }
}
