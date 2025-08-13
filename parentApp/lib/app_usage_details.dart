import 'package:device_apps/device_apps.dart';
import 'package:intl/intl.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:flutter/material.dart';

class AppUsageDetails extends StatefulWidget {
  final Application application;
  const AppUsageDetails({super.key, required this.application});

  @override
  State<AppUsageDetails> createState() => _AppUsageDetailsState();
}

class _AppUsageDetailsState extends State<AppUsageDetails> {
  UsageInfo? appUsageInfo;

  getUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

    // Query usage stats
    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
    if (usageStats.isNotEmpty) {
      usageStats.forEach((element) {
        if (element.packageName == widget.application.packageName) {
          setState(() {
            appUsageInfo = element;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUsage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.application.appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Screen Time:',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  appUsageInfo != null && appUsageInfo!.totalTimeInForeground != null
                      ? '${(int.parse(appUsageInfo!.totalTimeInForeground!) / 1000 / 60).toStringAsFixed(1)} mins'
                      : '0',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last used:',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  appUsageInfo != null && appUsageInfo!.lastTimeUsed != null
                      ? '${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(int.parse(appUsageInfo!.lastTimeUsed!)))}'
                      : '0',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
