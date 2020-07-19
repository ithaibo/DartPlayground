import 'dart:io';
import 'package:http/http.dart' as http;
import 'GoogleTranslation.dart';
import 'LimitLengthStrategy.dart';
import 'TextSplitStrategy.dart';
import 'TranslationImpl.dart';

void main() {
  String toSplit =
      'As Honda Soichiro built his company into a global car making giant, he developed a reputation as a talented engineer. He was also known to be an exacting boss, even a violent one." When he got mad, he started throwing whatever was in reach randomly at people, " one former executive later recalled. Such fiery tempers remain all too common among Japanese managers. A Japanese psychologist even coined a term to describe the particular abuse that the country’s supervisors pile upon some of their employees: pawahara, or power harassment.';

  TranslationImpl translation = TranslationImpl();
  print("prepareToken invoked");

  var url = "https://translate.google.cn/";
  var header = {
    "accept": "*/*",
    "accept-language": "zh-CN,zh;q=0.9",
    "cookie":
        "N_ga=GA1.3.2053936754.1594434963; _gid=GA1.3.768876225.1594434963; NID=204=L-CDmBoC3iL5vcNjeeaUs1Vl9V9BNIfXck5S_ixqsY9AgTU4hsKDcCc1eq19zu5m8SL-m_GK1uERxJi43SMPKgj_BZDDsYkukrCWFkofcLRWdSyiBJcUCkT1vvGXfJ8seI5JGaje_mrVEzgotPfktSSCGtV2Xc2YMG1pbksmUXM; 1P_JAR=2020-7-11-5",
    "referer": "https://translate.google.cn/",
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36",
    "x-client-data":
        "CIu2yQEIo7bJAQjEtskBCImSygEIqZ3KAQj/vMoBCJrHygEI6MjKARj7t8oBGJu+ygE=",
  };

  translation.doNetWork(url, header).then((String value) {
    RegExp regExp = RegExp("tkk:'([0-9]+\.[0-9]+)'");
    translation.tkk = regExp.firstMatch(value).group(0);
    print("tkk from google" + translation.tkk);

    readConfigAndSplitLines(translation);
  });

//  readConfigAndSplitLines();
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

void fetchPrintBaidu() {
  var url = "http://www.baidu.com";
  fetchUrl(url).then((body) {
    print("body of baidu:" + body);
  }).catchError((error) => {print(error.toString())});
}

Future<String> fetchUrl(String url) async {
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load baidu.');
  }
}
