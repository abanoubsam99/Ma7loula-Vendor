class AddBatteryModel {
  String? message;
  Data? data;

  AddBatteryModel({this.message, this.data});

  AddBatteryModel.fromJson(Map<String, dynamic> json) {
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
  Battery? battery;

  Data({this.battery});

  Data.fromJson(Map<String, dynamic> json) {
    battery =
        json['battery'] != null ? Battery.fromJson(json['battery']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (battery != null) {
      data['battery'] = battery!.toJson();
    }
    return data;
  }
}

class Battery {
  int? id;
  String? name;
  String? description;
  int? price;
  int? priceBeforeDiscount;
  int? stock;
  String? status;
  Thumbnail? thumbnail;
  List<Thumbnail>? images;
  Brand? brand;
  List<Attributes>? attributes;

  Battery(
      {this.id,
      this.name,
      this.description,
      this.price,
      this.priceBeforeDiscount,
      this.stock,
      this.status,
      this.thumbnail,
      this.images,
      this.brand,
      this.attributes});

  Battery.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    priceBeforeDiscount = json['price_before_discount'];
    stock = json['stock'];
    status = json['status'];
    thumbnail = json['thumbnail'] != null
        ? Thumbnail.fromJson(json['thumbnail'])
        : null;
    if (json['images'] != null) {
      images = <Thumbnail>[];
      json['images'].forEach((v) {
        images!.add(Thumbnail.fromJson(v));
      });
    }
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attributes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['price_before_discount'] = priceBeforeDiscount;
    data['stock'] = stock;
    data['status'] = status;
    if (thumbnail != null) {
      data['thumbnail'] = thumbnail!.toJson();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Brand {
  int? id;
  String? name;

  Brand({this.id, this.name});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Thumbnail {
  int? id;
  String? url;

  Thumbnail({this.id, this.url});

  Thumbnail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    return data;
  }
}

class Attributes {
  String? name;
  String? value;

  Attributes({this.name, this.value});

  Attributes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}
