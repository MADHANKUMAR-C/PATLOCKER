

class blockedApps{
  String appName;

  blockedApps(this.appName);
  Map<String, dynamic>toJSON(){
    return{
      'appName':appName,
    };
  }
  factory blockedApps.fromMap(Map<String, dynamic> data){
    return blockedApps(data['appName'] ?? '');
  }
}