import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parent_control/children.dart';

import 'child_limit.dart';

class ChildrenDetails extends StatelessWidget {
  final Children data;
  final String childId;
  ChildrenDetails({Key? key, required this.data, required this.childId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${data.name.toUpperCase()} Details'),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Container(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: data.appInformation.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AppUsageDetails(
                          childId: childId,
                          appInformation: data.appInformation[index],
                          appIndex: index,
                        );
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color.fromARGB(255, 132, 221, 161),
                    ),
                    child: Center(
                      child: ListTile(
                        title: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            '${data.appInformation[index].appName}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          'Last Used: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(int.parse(data.appInformation[index].lastUsed)))}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 124, 122, 122),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Wrap(
                          direction: Axis.vertical,
                          children: [
                            Text(
                              'Screen Time ',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 124, 122, 122),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(int.parse(data.appInformation[index].screenTime) / 1000 / 60).toStringAsFixed(1)} mins',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

