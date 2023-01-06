import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:market_stack_report/dio_network/dio_client.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'company_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasInternet = false;
  late StreamSubscription internetSubscription;
  bool isLoading = false;
  late List<Company> companies;
  TextEditingController searchSymbol = TextEditingController();

  String? _selectedSuggestion;
  List<String> _suggestions = [];

  DioClient dioClient = DioClient();

  void returnData() async {
    isLoading = true;
    companies = await DioClient().getData(searchSymbol.text);
    isLoading = false;
    companies.shuffle();
    setState(() {});
  }

  void checkInternet() async {
    internetSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      setState(() => this.hasInternet = hasInternet);
    });
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    returnData();
    checkInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        // actions: [
        //   IconButton(onPressed: (){showSearch(context: context, delegate: MySearchDelegate());}, icon: Icon(Icons.search))
        // ],
        actions: [
          Text(
            hasInternet ? "Online" : "Offline",
            style: TextStyle(
                color: hasInternet ? Colors.green.shade900 : Colors.red.shade900,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.right,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 20, top: 10),
              child: Icon(Icons.account_circle_outlined,))
        ],
        title: const Text('Market Stack..'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column (
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: TextField(
                controller: searchSymbol,
                onChanged: (value){
                  _getSuggestions(value);
                 // dioClient.getData(value);
                  print("Hello : $value");
                },
                decoration: InputDecoration(
                  prefixIcon: IconButton(icon: Icon(Icons.search), onPressed: () {},),
                      hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.brown)
                  )
                ),
              ),
            ),
            DropdownButton(
              value: _selectedSuggestion,
              items: _suggestions.map((suggestion) {
                return DropdownMenuItem(
                  value: suggestion,
                  child: Text(suggestion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSuggestion = value;
                  searchSymbol.text = value!;
                });
              },
            ),
            SizedBox(height: 10,),
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(),
                )
                : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  Company company = companies[index];
                  return ListTile(
                    title: Text(company.name),
                    subtitle: Text(company.symbol),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  void searchField(String query){}

  void _getSuggestions(String query) async {
    // Make API call to get suggestions
    const String apiKey = '7a786fbfab497e73df54ec8d70027b35';
    Dio dio = Dio();
    final response = await dio.get('http://api.marketstack.com/v1/tickers',
       queryParameters: {'access_key': apiKey, 'search': query}
    );
    // Parse JSON response and extract list of suggestions
    final suggestions = jsonDecode(response.data);
    // Update list of suggestions and selected suggestion
    print(suggestions);
    setState(() {
      _suggestions = suggestions;
      _selectedSuggestion = suggestions[0];
    });
  }
}

class MySearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget? buildLeading(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {

    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    throw UnimplementedError();
  }
}

