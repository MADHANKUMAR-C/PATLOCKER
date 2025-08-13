import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  await initializeService();
}

Future<void> initializeService() async {
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'Background Service',
    notificationText: 'Running in the background',
    notificationImportance: AndroidNotificationImportance.normal,
    enableWifiLock: true,
  );

  bool hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
  if (hasPermissions) {
    FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    FlutterBackgroundService().startService();
  }
}

FutureOr<bool> onIosBackground(ServiceInstance service) async {
  // handle iOS background logic
  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is FlutterBackgroundService) {
    service.on('setAsForeground').listen((event) {
      service.setForegroundMode(true);
    });

    service.on('setAsBackground').listen((event) {
      service.setForegroundMode(false);
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    _uploadAppUsage();
  }
}

Future<void> _uploadAppUsage() async {
  await Firebase.initializeApp();
  var user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String? docId = user.uid;

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
      List<Future<Map<String, dynamic>?>> futures = apps.map((app) async {
        var usageInfo = await _getUsage(app);
        if (usageInfo != null) {
          var existingAppInfo = appInformationFromFirebase.firstWhere(
            (appInfo) => appInfo['appPackageName'] == app.packageName,
            orElse: () => <String, dynamic>{},
          );

          return {
            'appName': app.appName,
            'appPackageName': app.packageName,
            'screenTime': usageInfo.totalTimeInForeground.toString(),
            'lastUsed': usageInfo.lastTimeUsed.toString(),
            'limitTime': existingAppInfo['limitTime'] ?? 0,
            'isBlocked': existingAppInfo['isBlocked'] ?? false,
          };
        }
        return null;
      }).toList();

      var results = await Future.wait(futures);
      results.removeWhere((item) => item == null);

      await FirebaseFirestore.instance.collection('childrens').doc(docId).update({
        'appInformation': results,
      });
    }
  }
}

Future<UsageInfo?> _getUsage(Application application) async {
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Background Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Background Service'),
        ),
        body: Center(
          child: Text('Running background service...'),
        ),
      ),
    );
  }
}
