import 'dart:io';
import 'GoogleTranslation.dart';
import 'LimitLengthStrategy.dart';
import 'TextSplitStrategy.dart';
import 'TranslationImpl.dart';

void main() async {
  TranslationImpl translation = TranslationImpl();
  await translation.prepareToken();
  readConfigAndSplitLines(translation);
}

void readConfigAndSplitLines(GoogleTranslation translation) {
  var listToFetch = [];
  TextSplitStrategy strategy = LimitLengthStrategy(200);
  File('config.txt').readAsLines().then((lines) {
    for (String line in lines) {
      listToFetch.addAll(strategy.split(line));
    }
    List<Future<bool>> fetchTaskList = [];
    for (int i = 0; i < listToFetch.length; i++) {
      fetchTaskList.add(translation.fetchTTSAudio(listToFetch[i], "output/" + i.toString() + ".mp3"));
    }

    Future.wait<bool>(fetchTaskList).then((value){
      print("result:" + value.toString());
    });

    print("size:" + listToFetch.length.toString());
  });
}
