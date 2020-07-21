import 'package:http/http.dart' as http;
import 'GoogleTranslation.dart';
import 'package:dio/dio.dart';

class TranslationImpl implements GoogleTranslation {
  String tkk;
  final String urlGoogleTTs = 'https://translate.google.cn/translate_tts';

  final data = {
    "client": "webapp", // 基于网页访问服务器
    "tl": "en", // 翻译的目标语言
    "ie": "UTF-8",
    "textlen": "1",
    "idx": "0",
    "total": "1",
    "tk": "", // 谷歌服务器会核对的token
    "q": "" // 待翻译的字符串
  };

  Future<String> doNetWork(String url, Map<String, String> header) async {
    final response = await http.get(url, headers: header);
    print("status code of " + response.statusCode.toString());
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception("Failed to load token");
  }

  void prepareToken() async {
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

    String result = await doNetWork(url, header);
    RegExp regExp = RegExp("tkk:'([0-9]+\.[0-9]+)'");
    this.tkk = regExp.firstMatch(result).group(0);
    print("tkk from google" + tkk);
  }

  @override
  Future<bool> fetchTTSAudio(String content, String filePath) async {
    String encodeTxt = Uri.encodeFull(content);
    data['q'] = encodeTxt;
    String token = getToken(content, tkk);
    data['tk'] = token;
    data['textlen'] = encodeTxt.length.toString();
    print("encode content:" + encodeTxt);
    String url = constructUrl();

    try {
      await Dio().download(url, filePath);
      return true;
    } on Exception catch(e) {
      print(e.toString());
      return false;
    }
  }

  String constructUrl() {
    String base = this.urlGoogleTTs + '?';
    for (String key in data.keys) {
      base = base + key + '=' + data[key] + '&';
    }
    base = base.substring(0, base.length - 1);
    print("constructUrl, result:" + base);
    return base;
  }

  String getToken(String content, String tkk) {
    List<String> array =
        tkk.replaceAll("tkk:", "").replaceAll("'", "").split(".");
    print("getToken invoked, array: " + array.toString());
    print("getToken invoked, array[0]: " + array[0]);
    print("getToken invoked, array[1]: " + array[1]);

    List<int> tkArray = [];
    int a1 = int.parse(array[0]);
    int a2 = int.parse(array[1]);

    tkArray.add(a1);
    tkArray.add(a2);
    List<int> f = [];

    int i = 0;
    while (i < content.length) {
      int l = content.codeUnitAt(i);
      if (128 > l) {
        f.add(l);
      } else {
        if (2048 > l) {
          f.add(l >> 6 | 192);
        } else {
          if (55296 == (l & 64512) &&
              (i + 1 < content.length) &&
              (56320 == content.codeUnitAt(i + 1) & 64512)) {
            i++;
            l = 65536 + ((l & 1023) << 10) + (content.codeUnitAt(i) & 1023);
            f.add(l >> 18 | 240);
            f.add(l >> 12 & 63 | 128);
          } else {
            f.add(l >> 12 | 224);
            f.add(l >> 6 & 63 | 128);
            f.add(l & 63 | 128);
          }
        }
      }
      i++;
    }

    int tkk1 = tkArray[0];
    int tkk2 = tkArray[1];

    int a = tkk1;

    for (int i = 0; i < f.length; i++) {
      a += f[i];
      a = zp(a, "+-a^+6");
    }

    a = zp(a, "+-3^+b+-f");
    a ^= tkk2;

    if (0 > a) {
      a = (a & 2147483647) + 2147483648;
    }

    a = a % 1000000;

    return a.toString() + '.' + (a ^ tkk1).toString();
  }

  int zp(int a, String b) {
    int g = 0;
    int i = 0;
    while (i < (b.length - 2)) {
      String c = "" + b[i + 2];
      String d = b[i + 2];
      g = ("a".codeUnitAt(0) <= d.codeUnitAt(0))
          ? (c.codeUnitAt(0)) - 87
          : int.parse(c); //int.parse(c)
      String x = "" + b[i + 1];
      g = "+" == x ? a >> g : a << g;
      String y = "" + b[i];
      a = "+" == y ? (a + g & 4294967295) : (a ^ g);
      i = i + 3;
    }
    return a;
  }
}
