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

  //异步按行读取config文件
  File('config.txt').readAsLines().then((lines) {
    //执行长行短句逻辑：一次请求的字符串有长度限制
    for (String line in lines) {
      listToFetch.addAll(strategy.split(line));
    }
    //触发所有音频拉取异步任务
    List<Future<bool>> fetchTaskList = [];
    for (int i = 0; i < listToFetch.length; i++) {
      fetchTaskList.add(translation.fetchTTSAudio(listToFetch[i], "output/" + i.toString() + ".mp3"));
    }
    //待异步任务都执行完毕，打印结果
    Future.wait<bool>(fetchTaskList).then((value){
      print("result:" + value.toString());
    });

    print("size:" + listToFetch.length.toString());
  });
}
