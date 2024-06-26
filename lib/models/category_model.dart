// ignore_for_file: public_member_api_docs, sort_constructors_first
class Category {
  String? name;
  Category({
    this.name,
  });

  Map<String, dynamic> tojson() {
    return <String, dynamic>{
      'name': name,
    };
  }

  Category.fromjson(Map<String, dynamic> json) {
    name = json['name'] != null ? json['name'] as String : null;
  }
}
