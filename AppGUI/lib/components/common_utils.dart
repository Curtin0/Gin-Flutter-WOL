//import 'package:flutter/cupertino.dart';

class CommonUtils {
  /// 判断是否为空
  static isEmpty(dynamic obj) {
    return obj == null || obj == "";
  }

  static safeStr(dynamic str, [dynamic safeValue = ""]) {
    print("str $str");
    return isEmpty(str) ? safeValue : str;
  }

  static bool isJoyMasterDevice(String str) {
    if (isEmpty(str)) return false;
    return RegExp(r'(J|j)(\d{4})-(\d{4})').firstMatch(str) != null ||
        RegExp(r'BJ[0-9A-Za-z]{8}$').firstMatch(str) != null ||
        str.toUpperCase() == 'JOYBLE';
  }

  static bool isBox(String str) {
    if (isEmpty(str)) return false;
    return RegExp(r'BJ[0-9A-Za-z]{8}$').firstMatch(str) != null;
  }

  static bool isEquals(String one, String another) {
    if (another == null) return false;
    return one?.compareTo(another) == 0;
  }

  // 大于某个日期
  static bool isGreaterDay(DateTime a, DateTime b) {
    if (a.year > b.year) {
      // 跨年大
      return true;
    }

    if (a.year < b.year) {
      // 跨年小
      return false;
    }

    /// 以下情况都是同年
    if (a.month > b.month) {
      // 跨月大
      return true;
    }

    if (a.month < b.month) {
      // 跨月小
      return false;
    }

    /// 同年同月
    return a.day > b.day;
  }

  static bool sameList(List a, List b) {
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a.elementAt(i) != b.elementAt(i)) {
        return false;
      }
    }
    return true;
  }

  /// [object]  解析的对象
  /// [deep]  递归的深度，用来获取缩进的空白长度
  /// [isObject] 用来区分当前map或list是不是来自某个字段，则不用显示缩进。单纯的map或list需要添加缩进
  static String convert(dynamic object, {int deep = 0, bool isObject = false}) {
    var buffer = StringBuffer();
    var nextDeep = deep + 1;
    if (object is Map) {
      var list = object.keys.toList();
      if (!isObject) {
        //如果map来自某个字段，则不需要显示缩进
        buffer.write("${getDeepSpace(deep)}");
      }
      buffer.write("{");
      if (list.isEmpty) {
        //当map为空，直接返回‘}’
        buffer.write("}");
      } else {
        buffer.write("\n");
        for (int i = 0; i < list.length; i++) {
          buffer.write("${getDeepSpace(nextDeep)}\"${list[i]}\":");
          buffer
              .write(convert(object[list[i]], deep: nextDeep, isObject: true));
          if (i < list.length - 1) {
            buffer.write(",");
            buffer.write("\n");
          }
        }
        buffer.write("\n");
        buffer.write("${getDeepSpace(deep)}}");
      }
    } else if (object is List) {
      if (!isObject) {
        //如果list来自某个字段，则不需要显示缩进
        buffer.write("${getDeepSpace(deep)}");
      }
      buffer.write("[");
      if (object.isEmpty) {
        //当list为空，直接返回‘]’
        buffer.write("]");
      } else {
        buffer.write("\n");
        for (int i = 0; i < object.length; i++) {
          buffer.write(convert(object[i], deep: nextDeep));
          if (i < object.length - 1) {
            buffer.write(",");
            buffer.write("\n");
          }
        }
        buffer.write("\n");
        buffer.write("${getDeepSpace(deep)}]");
      }
    } else if (object is String) {
      //为字符串时，需要添加双引号并返回当前内容
      buffer.write("\"$object\"");
    } else if (object is num || object is bool) {
      //为数字或者布尔值时，返回当前内容
      buffer.write(object);
    } else {
      //如果对象为空，则返回null字符串
      buffer.write("null");
    }
    return buffer.toString();
  }

  ///获取缩进空白符
  static String getDeepSpace(int deep) {
    var tab = StringBuffer();
    for (int i = 0; i < deep; i++) {
      tab.write("\t");
    }
    return tab.toString();
  }
}

///
/// 截取时间日
extension ShortDate on String {
  String get shortDate {
    if (this == null) return null;
    return this.substring(0, 10);
  }
}

class MyFunc extends Function {
  int token;
  MyFunc(this.token);
}
