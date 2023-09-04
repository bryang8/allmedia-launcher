class ConfigsModel {
  int? launcher;
  List<ConfigsImage>? images;

  ConfigsModel({this.launcher, this.images});

  ConfigsModel.fromJson(Map<String, dynamic> json) {
    launcher = json['launcher_id'] ?? json['launcher'];

    if (json['images'] != null) {
      images = <ConfigsImage>[];
      json['images'].forEach((v) {
        images!.add(ConfigsImage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['launcher_id'] = launcher;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ConfigsImage {
  int? id;
  String? path;
  String? link;
  String? ext;

  ConfigsImage({this.id, this.path, this.link, this.ext});

  ConfigsImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    path = json['path'];
    link = json['link'];
    ext = json['ext'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['path'] = path;
    data['link'] = link;
    data['ext'] = ext;
    return data;
  }
}