import 'package:ev_simulator/model/news_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  // init hive
  static Box? box;

  static Future<void> openBox() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    box = await Hive.openBox('cache');
    return;
  }

  static Future<void> putData(List<NewsModel> data) async {
    await box!.clear();
    for (NewsModel n in data) {
      box!.add(n.toJson());
    }
  }
}
