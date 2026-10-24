/// Khớp giao kèo: id, name, price, imageUrl, description (camelCase, không null).
class Phone {
  final int id;
  final String name;
  final int price; // VND
  final String imageUrl;
  final String description;

  const Phone({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  factory Phone.fromJson(Map<String, dynamic> json) => Phone(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        imageUrl: json['imageUrl'] as String,
        description: json['description'] as String,
      );
}
