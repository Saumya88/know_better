import 'package:flutter/material.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/services/cloud_database.dart';

class ResultScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;

  const ResultScreen({required this.roomsDetail});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Map<String, List<Map<String, String>>> results = {};
  Map<String, List<String>> feedback = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final feedbackRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('feedback');
    feedbackRef.onValue.listen((event) {
      final data = Map<String, List>.from(event.snapshot.value as Map);
      data.forEach((key, value) {
        final feedResults = List.generate(value.length, (index) {
          final feed = Map<String, String>.from(value[index] as Map);
          feedback[feed['from']!]?.add(feed['value']!);
          return feed;
        });
        setState(() {
          results[key] = feedResults;
        });
      });
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(),
              children: List.generate(results.length + 2, (index) {
                if (index != 0) {
                  return TableRow(
                    children: List.generate(
                        widget.roomsDetail.participants.length + 1, (ind) {
                      final data = results['run 1']![0]['from'];
                      if (ind == 0) {
                        return TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data!,
                              style: const TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        );
                      } else if (index == ind) {
                        return const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '--',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        );
                      }
                      return TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(),
                        ),
                      );
                    }),
                  );
                }
                return TableRow(
                  children: List.generate(
                      widget.roomsDetail.participants.length + 1, (ind) {
                    if (ind != 0) {
                      return TableCell(
                        verticalAlignment: TableCellVerticalAlignment.top,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'index $ind',
                            style: const TextStyle(
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                      );
                    }
                    return TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(),
                      ),
                    );
                  }),
                );
              }),
            ),
            // Column(
            //   children: List.generate(results.length, (index) {
            //     return Column(
            //       children:
            //           List.generate(results['run ${index + 1}']!.length, (ind) {
            //         return Column(
            //           children: [
            //             Row(
            //               children: [
            //                 Text('From: '),
            //                 Text(results['run ${index + 1}']![ind]['from'] ??
            //                     'No Data'),
            //               ],
            //             ),
            //             Row(
            //               children: [
            //                 Text('To: '),
            //                 Text(results['run ${index + 1}']![ind]['to'] ??
            //                     'No Data'),
            //               ],
            //             ),
            //             Row(
            //               children: [
            //                 Text('Value: '),
            //                 Text(results['run ${index + 1}']![ind]['value'] ??
            //                     'No Data'),
            //               ],
            //             ),
            //           ],
            //         );
            //       }),
            //     );
            //   }),
            // ),
          ),
        ),
      ),
    );
  }
}
