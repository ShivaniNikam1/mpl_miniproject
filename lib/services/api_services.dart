import 'dart:convert';

import 'package:ev_simulator/controllers/caching.dart';
import 'package:ev_simulator/model/news_model.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  // final apiKEY = "c705bc7c6d6547d98342f44c4ee66baf";
  final apiKEY = "4222fb1bba5d41cea8c02b0f81819f32";
  //"aadf90d688ae4b29b5ba3eaa7497a12c";

  Future<List<NewsModel>> getNews() async {
    List<NewsModel> newsList = [];
    await DbHelper.openBox();

    try {
      final response = await http.get(
        Uri.parse(
            "https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKEY"),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)["articles"];
        for (var i in result) {
          newsList.add(NewsModel.fromJson(i));
        }
        await DbHelper.putData(newsList);
        return newsList;
      }
    } catch (SocketException) {
      var data = DbHelper.box!.values.toList();
      print("hive data: ${data.runtimeType}");
      if (data.isNotEmpty) {
        print("data is not empty");

        for (var d in data) {
          print("data insider: $d");
          newsList.add(NewsModel(
              title: d['title'],
              description: d['description'],
              url: d['url'],
              urlToImage: d['urlToImage'],
              publishedAt: DateTime.parse(d['publishedAt']),
              content: d['content'],
              source: Source(name: d['source']['name'])));
          print("newsList: $newsList");
        }
        print("newsList: $newsList");
        return newsList;
      } else {
        data.add('empty');
      }
    }
    print("newsList the end: $newsList");
    return newsList;
  }
}
