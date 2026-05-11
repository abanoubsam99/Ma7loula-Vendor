class RequirementsDoc {
  String? message;
  Data? data;

  RequirementsDoc({this.message, this.data});

  RequirementsDoc.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Requirements>? requirements;

  Data({this.requirements});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['requirements'] != null) {
      requirements = <Requirements>[];
      json['requirements'].forEach((v) {
        requirements!.add(Requirements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (requirements != null) {
      data['requirements'] = requirements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Requirements {
  String? title;
  String? body;
  int? id;

  Requirements({this.title, this.body, this.id});

  Requirements.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    return data;
  }
}
