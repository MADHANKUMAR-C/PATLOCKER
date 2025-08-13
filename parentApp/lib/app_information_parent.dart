

class AppInformationParent{
  String appName;
  String appPackageName;
  String screenTime;
  String lastUsed;


  AppInformationParent(this.appName, this.appPackageName, this.screenTime, this.lastUsed,);
  Map<String, dynamic>toJSON(){
    return{
      'appName':appName,
      'appPackageName':appPackageName,
      'screenTime':screenTime,
      'lastUsed':lastUsed,
    };
  }
  factory AppInformationParent.fromMap(Map<String, dynamic> data){
    return AppInformationParent(data['appName'] ?? '', data['appPackageName']?? '', data['screenTime']?? '', data['lastUsed']?? '',
      );
  }
}