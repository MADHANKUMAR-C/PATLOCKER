

class AppInformation{
  String appName;
  String appPackageName;
  String screenTime;
  String lastUsed;
  int limitTime;
  bool isBlocked;

  AppInformation(this.appName, this.appPackageName, this.screenTime, this.lastUsed,  this.limitTime, this.isBlocked);
  Map<String, dynamic>toJSON(){
    return{
      'appName':appName,
      'appPackageName':appPackageName,
      'screenTime':screenTime,
      'lastUsed':lastUsed,
      "limitTime": limitTime,
      "isBlocked": isBlocked
    };
  }
  factory AppInformation.fromMap(Map<String, dynamic> data){
    return AppInformation(data['appName'] ?? '', data['appPackageName']?? '', data['screenTime']?? '', data['lastUsed']?? '', data['limitTime'] ?? 0,
      data['isBlocked'] ?? false);
  }
}