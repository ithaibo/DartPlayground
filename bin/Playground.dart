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
    for (int i = 0; i < listToFetch.length; i++) {
      translation.fetchTTSAudio(
          listToFetch[i],
          "output/" + i.toString() + ".mp3");
    }
    print("size:" + listToFetch.length.toString());
  });
}
