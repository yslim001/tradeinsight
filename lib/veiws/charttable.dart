import 'package:easy_table/easy_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InsightView extends StatelessWidget {
  InsightView({Key? key}) : super(key: key);
  var price1 = ''.obs;

  setPrice(String p) {
    price1.value = p;
    print('+++++++++++++++++++++++++++++++$p');
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: EasyTable(EasyTableModel<String>(rows: [
      'Landon',
      'Landon',
      'Landon',
      'Landon',
    ], columns: [
      EasyTableColumn(name: 'Name', stringValue: (row) => price1.value),
      EasyTableColumn(name: 'Age', stringValue: (row) => row)
    ])));
    // return Container(
    //   child: DataTable(
    //     columns: const [
    //       DataColumn(label: Text('M1')),
    //       DataColumn(label: Text('M1')),
    //       DataColumn(label: Text('M1')),
    //       DataColumn(label: Text('M1')),
    //       DataColumn(label: Text('M1'))
    //     ],
    //     rows: const [
    //       DataRow(
    //         cells: [
    //           DataCell(Text('t')),
    //           DataCell(Text('t')),
    //           DataCell(Text('t')),
    //           DataCell(Text('t')),
    //           DataCell(Text('t'))
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
