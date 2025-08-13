import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parent_control/app_information.dart';
import 'package:parent_control/app_usage_details.dart';
import 'package:parent_control/blocked.dart';
import 'package:usage_stats/usage_stats.dart';

class MyHomePage extends StatefulWidget {
  final bool isParent;
  final String title;

  const MyHomePage({Key? key, required this.title, required this.isParent}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AppInformation> appInformation = [];
  String? docId;
  List<Map<String, dynamic>> blockedapps = [];
  bool blocked = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getAllInstalledApps();
  }

  Future<void> getCurrentUser() async {
    var user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        docId = user.uid;
      });
      _setupListener(docId);
    }
  }

  Future<void> getAllInstalledApps() async {
    appInformation = [];
    List<Application> apps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );

    var docSnapshot = await FirebaseFirestore.instance.collection('childrens').doc(docId).get();
    List<Map<String, dynamic>> appInformationFromFirebase = [];
    if (docSnapshot.exists) {
      var data = docSnapshot.data();
      if (data != null && data.containsKey('appInformation') && data['appInformation'] != null) {
        appInformationFromFirebase = List<Map<String, dynamic>>.from(data['appInformation']);
      }
    }

    if (apps.isNotEmpty) {
      List<Future<AppInformation?>> futures = apps.map((app) async {
        var usageInfo = await getUsage(app);
        if (usageInfo != null) {
          var existingAppInfo = appInformationFromFirebase.firstWhere(
            (appInfo) => appInfo['appPackageName'] == app.packageName,
            orElse: () => <String, dynamic>{},
          );

          return AppInformation(
            app.appName,
            app.packageName,
            usageInfo.totalTimeInForeground.toString(),
            usageInfo.lastTimeUsed.toString(),
            existingAppInfo['limitTime'] ?? 0,
            existingAppInfo['isBlocked'] ?? false,
          );
        }
        return null;
      }).toList();

      var results = await Future.wait(futures);
      results.removeWhere((item) => item == null);

      setState(() {
        appInformation = results.cast<AppInformation>();
      });

      await updateChildInformation(docId!);
    }
  }

  Future<void> updateChildInformation(String docId) async {
    await FirebaseFirestore.instance.collection('childrens').doc(docId).update({
      'appInformation': appInformation.map((e) => e.toJSON()).toList(),
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

  void _setupListener(String? docId) {
    blockedapps = [];
    FirebaseFirestore.instance.collection('childrens').doc(docId).snapshots().listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        var appInformationList = List<Map<String, dynamic>>.from(documentSnapshot['appInformation']);
        for (var app in appInformationList) {
          if (app['isBlocked'] || (int.parse(app['screenTime']) >= app['limitTime'] && app['limitTime'] != 0)) {
            setState(() {
              blockedapps.add(app);
            });
          }
        }
      }
    });
  }

  void updateAppInformation(Application element, UsageInfo usageInfo) async {
    var docSnapshot = await FirebaseFirestore.instance.collection('childrens').doc(docId).get();
    if (docSnapshot.exists) {
      var appInformationList = List<Map<String, dynamic>>.from(docSnapshot['appInformation']);
      var appInfoIndex = appInformationList.indexWhere((app) => app['appPackageName'] == element.packageName);

      if (appInfoIndex != -1) {
        var appInfo = appInformationList[appInfoIndex];
        appInfo['screenTime'] = usageInfo.totalTimeInForeground.toString();
        appInfo['lastUsed'] = usageInfo.lastTimeUsed.toString();
        appInformationList[appInfoIndex] = appInfo;
      } else {
        appInformationList.add({
          'appName': element.appName,
          'appPackageName': element.packageName,
          'screenTime': usageInfo.totalTimeInForeground.toString(),
          'lastUsed': usageInfo.lastTimeUsed.toString(),
          'limitTime': 0,
          'isBlocked': false,
        });
      }

      await FirebaseFirestore.instance.collection('childrens').doc(docId).update({
        'appInformation': appInformationList,
      });
    }
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
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            List<Application> apps = snapshot.data as List<Application>;
            return Container(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      var usageInfo = await getUsage(apps[index]);
                      if (usageInfo != null) {
                        updateAppInformation(apps[index], usageInfo);
                      }
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
                                var isBlocked = blockedapps.any((app) => app['appPackageName'] == apps[index].packageName);
                                if (isBlocked) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return blockedPage(title: apps[index].appName);
                                    },
                                  ));
                                } else {
                                  apps[index].openApp();
                                }
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
