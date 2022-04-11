import 'package:flutter/material.dart';

enum IndexPathType {
  Header,
  sectionHeader,
  row,
  sectionFooter,
  Footer,
}

/// [index] listView的index ,起点下标为0
/// [section] 第几组，起点下标为0
/// [row] 某一组的第几个，起点下标为0
class IndexPath {
  IndexPath(this.section, this.row,
      {this.type = IndexPathType.row, this.index});

  int index; //原index
  int section;
  int row;
  IndexPathType type;

  @override
  String toString() {
    return "IndexPath(section:" +
        section.toString() +
        "," +
        "row:" +
        row.toString() +
        "," +
        "type:" +
        type.toString() +
        ",index:" +
        index.toString() +
        ")";
  }
}

typedef HeaderOrFooterCallBack = Widget Function();
typedef HeaderOrFooterForSectionCallBack = Widget Function(int section);
typedef CellForRowCallBack = Widget Function(IndexPath indexPath);
typedef DataCountCallBack = int Function(int section);

/// [numberOfSections] 有几组，起点下标为1
/// [numberOfRowsInSection] 某一组有多少row，起点下标为1
class ListViewGroupHandler {
  ListViewGroupHandler(
      {this.numberOfSections = 1,
      @required this.numberOfRowsInSection,
      @required this.cellForRowAtIndexPath,
      this.headerForSection,
      this.footerForSection,
      this.header,
      this.footer});

  final int numberOfSections;
  final DataCountCallBack numberOfRowsInSection;
  final CellForRowCallBack cellForRowAtIndexPath;

  final HeaderOrFooterForSectionCallBack headerForSection;
  final HeaderOrFooterForSectionCallBack footerForSection;
  final HeaderOrFooterCallBack header;
  final HeaderOrFooterCallBack footer;

  int get allItemCount => _allCount();
  int _allItemCount;

  Widget cellAtIndex(int index) {
    IndexPath indexPath = indexPathFromIndex(index);
    // print(indexPath.toString());
    switch (indexPath.type) {
      case IndexPathType.sectionHeader:
        {
          if (headerForSection != null) {
            return headerForSection(indexPath.section);
          }
        }
        break;
      case IndexPathType.row:
        {
          if (cellForRowAtIndexPath != null) {
            return cellForRowAtIndexPath(indexPath);
          }
        }
        break;
      case IndexPathType.sectionFooter:
        {
          if (footerForSection != null) {
            return footerForSection(indexPath.section);
          }
        }
        break;
      case IndexPathType.Header:
        {
          if (header != null) {
            return header();
          }
        }
        break;
      case IndexPathType.Footer:
        {
          if (footer != null) {
            return footer();
          }
        }
        break;
      default:
        {
          //statements;
        }
        break;
    }
    return Text("IndexPathType is not valid");
  }

  /// listView中的index
  IndexPath indexPathFromIndex(int index) {
    IndexPath indexPath = IndexPath(0, 0, index: index);

    if (index == 0 && header != null) {//第一个
      indexPath.type = IndexPathType.Header;
      return indexPath;
    } else if (_allItemCount == index + 1 && footer != null) {//最后一个
      indexPath.type = IndexPathType.Footer;
      return indexPath;
    } else if (header != null) {
      index -= 1;
    }

    int amount = 0; //当前、之前section的总数
    int lastAmount = 0; //之前section的总数
    int section = -1; //index的section
    int row = 0; //index的row
    int rowsOfLastSection = 0; //最后计算的section的rows

    while (amount <= index || section == -1) {
      section += 1; //从0开始
      lastAmount += rowsOfLastSection;
      rowsOfLastSection = countBySection(section); //计算当前section的rows数量
      amount += rowsOfLastSection;
    }

    indexPath.section = section;
    indexPath.row = index - lastAmount;
    row = indexPath.row;

    if (amount == index + 1) {
      //恰好在当前section的尾部
      //若有header row需减一
      //若有footer row需减一
      indexPath.type = IndexPathType.row;
      if (headerForSection != null) {
        if (row == 0) {
          //只有header
          indexPath.type = IndexPathType.sectionHeader;
        } else {
          row -= 1;
        }
      }
      if (footerForSection != null) {
        row -= 1;
        indexPath.type = IndexPathType.sectionFooter;
      }
      indexPath.row = row;
    } else {
      //若有header row需减一
      indexPath.type = IndexPathType.row;
      if (headerForSection != null) {
        if (row == 0) {
          indexPath.type = IndexPathType.sectionHeader;
        } else {
          row -= 1;
        }
        indexPath.row = row;
      }
    }

    return indexPath;
  }

  ///总item数量，包括header和footer
  int _allCount() {
    int count = 0;

    if (header != null) {
      count += 1;
    }

    if (numberOfSections > 0) {
      count += amountBySection(numberOfSections - 1);
    }

    if (footer != null) {
      count += 1;
    }
    // print("_allCount:" + count.toString());
    _allItemCount = count;
    return count;
  }

  ///到某一组的row总数量
  ///比如 5 等于 1..5 的row总数量
  int amountBySection(int section) {
    int amount = countBySection(section);
    if (section > 0) {
      return amount += amountBySection(section - 1);
    }
    return amount;
  }

  ///某一组的row数量
  int countBySection(int section) {
    int amount = numberOfRowsInSection(section);

    if (headerForSection != null) {
      amount += 1;
    }

    if (footerForSection != null) {
      amount += 1;
    }
    return amount;
  }
}
