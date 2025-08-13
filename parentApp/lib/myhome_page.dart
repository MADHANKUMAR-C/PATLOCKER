import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parent_control/app_information_parent.dart';
import 'package:parent_control/app_usage_details.dart';
import 'package:parent_control/parent.dart';
import 'package:usage_stats/usage_stats.dart';

class MyHomePage extends StatefulWidget {
  final bool isParent;
  const MyHomePage({super.key, required this.title, required this.isParent});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AppInformationParent> appInformationParent = [];
  String? docId;
  Parent? parent;

  @override
  void initState() {
    super.initState();
    parent = Parent('', '', '', '', [], '');
    getCurrentUser();
    getAllInstalledApps();
  }

  getCurrentUser() async {
    var user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        parent!.userId = user.uid;
        docId = user.uid;
      });
    }
  }

  getAllInstalledApps() async {
    appInformationParent = [];
    List<Application> apps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );

    if (apps.isNotEmpty) {
      List<Future<AppInformationParent?>> futures = apps.map((app) async {
        var usageInfo = await getUsage(app);
        if (usageInfo != null) {
          return AppInformationParent(
            app.appName,
            app.packageName,
            usageInfo.totalTimeInForeground.toString(),
            usageInfo.lastTimeUsed.toString(),
          );
        }
        return null;
      }).toList();

      var results = await Future.wait(futures);
      results.removeWhere((item) => item == null);

      setState(() {
        appInformationParent = results.cast<AppInformationParent>();
        parent!.appInformation = appInformationParent;
      });

      await updateParentInformation(docId!);
    }
  }

  updateParentInformation(String docId) async {
    await FirebaseFirestore.instance.collection('parents').doc(docId).update({
      'appInformation': appInformationParent.map((e) => e.toJSON()).toList(),
    });
  }

  Future<UsageInfo?> getUsage(Application application) async {
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
    if (usageStats.isNotEmpty) {
      for (var element in usageStats) {
        if (element.packageName == application.packageName) {
          return element;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.login_rounded, color: Colors.black),
          )
        ],
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.5),
        child: FutureBuilder(
          future: DeviceApps.getInstalledApplications(
            onlyAppsWithLaunchIntent: true,
            includeSystemApps: true,
            includeAppIcons: true,
          ),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(child: Text('Initializing installed apps...')),
              );
            }
            List<Application> apps = snapshot.data as List<Application>;
            return Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return AppUsageDetails(application: apps[index]);
                        }),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black,
                        ),
                        child: Center(
                          child: ListTile(
                            leading: Image.memory((apps[index] as ApplicationWithIcon).icon),
                            title: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                '${apps[index].appName}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                apps[index].openApp();
                              },
                              icon: Icon(Icons.open_in_new_rounded),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
