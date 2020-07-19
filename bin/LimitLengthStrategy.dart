import 'TextSplitStrategy.dart';

class LimitLengthStrategy implements TextSplitStrategy {
  int lengthMax;

  LimitLengthStrategy(this.lengthMax) {
    if (this.lengthMax <= 0) {
      throw Exception("lengthMax must big than 0");
    }
  }

  @override
  List<String> split(String raw) {
    final List<int> symbolList = [
      '.'.codeUnitAt(0),
      ','.codeUnitAt(0),
      '?'.codeUnitAt(0),
      '!'.codeUnitAt(0),
      ';'.codeUnitAt(0)
    ];

    List<String> result = [];
    if (raw.length <= lengthMax) {
      result.add(raw);
      return result;
    }

    /**最大不超过指定最大长度，并寻找指定的切割符号进行字符串切割*/
    int index = lengthMax - 1;
    var temp = raw.trim();
    while (temp.length > this.lengthMax && index > 0) {
      if (symbolList.contains(temp.codeUnitAt(index))) {
        var subStr = temp.substring(0, index + 1);
        result.add(subStr);
        final int lengthNow = temp.length;
        temp = temp.substring(index + 1, lengthNow);
        index++;
      } else {
        index--;
      }
    }
    if (temp.length < lengthMax) {
      result.add(temp);
    }

    return result;
  }
}
