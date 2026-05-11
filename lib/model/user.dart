// // import 'package:city_crepe/model/address.dart';
//
// class User {
//   int id;
//   String? name;
//   String? email;
//   String? phone;
//   OrderCanceled lastCancel;
//   // List<Address> addresses;
//
//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     // required this.addresses,
//     required this.lastCancel,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       lastCancel: json['last_cancel_order'] == 0
//           ? OrderCanceled.not
//           : OrderCanceled.yup,
//       id: json['id'],
//       name: json['name'],
//       phone: json['phone'],
//       email: json['email'],
//       // addresses: List<Address>.from(
//       //   json['addresses'].map((address) => Address.fromJson(address)),
//       // ),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'last_cancel_order': lastCancel,
//       'id': id,
//       'name': name,
//       'phone': phone,
//       'email': email,
//     };
//   }
// }
//
// enum OrderCanceled { not, yup }

class UserModel {
  String? message;
  Data? data;

  UserModel({this.message, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
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
  User? user;

  Data({this.user});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? authToken;
  Vendor? vendor;

  User(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.authToken,
      this.vendor});

  User.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    authToken = json['auth_token'];
    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['auth_token'] = authToken;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    return data;
  }
}

class Vendor {
  int? id;
  String? name;
  String? address;
  String? lat;
  String? lon;
  String? taxNo;
  String? companyLicenceExpireDate;
  String? companyLicenceNo;
  String? idImage;
  String? companyLicenceImage;

  Vendor(
      {this.id,
      this.name,
      this.address,
      this.lat,
      this.lon,
      this.taxNo,
      this.companyLicenceExpireDate,
      this.companyLicenceNo,
      this.idImage,
      this.companyLicenceImage});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    address = json['address'];
    lat = json['lat'];
    lon = json['lon'];
    taxNo = json['tax_no'];
    companyLicenceExpireDate = json['company_licence_expire_date'];
    companyLicenceNo = json['company_licence_no'];
    idImage = json['id_image'];
    companyLicenceImage = json['company_licence_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['lat'] = lat;
    data['lon'] = lon;
    data['tax_no'] = taxNo;
    data['company_licence_expire_date'] = companyLicenceExpireDate;
    data['company_licence_no'] = companyLicenceNo;
    data['id_image'] = idImage;
    data['company_licence_image'] = companyLicenceImage;
    return data;
  }
}
