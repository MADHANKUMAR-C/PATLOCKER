import 'package:parent_control/app_information.dart';

class Children {
  String userId;
  String name;
  String age;
  String deviceToken;
  List<AppInformation> appInformation;
  String parentCode;
  String parentUserId;

  Children(this.userId, this.name, this.age, this.deviceToken, this.appInformation, this.parentCode, this.parentUserId,);

  Map<String, dynamic> toJSON() {
    return {
      "userId": userId,
      "name": name,
      "age": age,
      "deviceToken": deviceToken,
      "appInformation": appInformation.map((e) => e.toJSON()).toList(),
      "parentCode": parentCode,
      "parentUserId": parentUserId,
      
    };
  }

  factory Children.fromMap(Map<String, dynamic> data) {
    return Children(
      data['userId'] ?? '',
      data['name'] ?? '',
      data['age'] ?? '',
      data['deviceToken'] ?? '',
      (data['appInformation'] as List<dynamic>)
          .map((e) => AppInformation.fromMap(e as Map<String, dynamic>))
          .toList(),
      data['parentCode'] ?? '',
      data['parentUserId'] ?? '',
      
    );
  }
}
