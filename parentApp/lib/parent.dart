import 'package:parent_control/app_information_parent.dart';


class Parent{
  String userId;
  String name;
  String age;
  String deviceToken;
  List<AppInformationParent>appInformation;
  String parentId;

  Parent(this.userId, this.name, this.age, this.deviceToken, this.appInformation, this.parentId);

  Map<String,dynamic> toJSON(){
    return{
      "userId":userId,
      "name":name,
      "age":age,
      "deviceToken":deviceToken,
      "appInformation":appInformation.map((e) => e.toJSON()).toList(),
      "parentId":parentId,
    };
  }
}